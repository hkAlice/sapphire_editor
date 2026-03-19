import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/condition/trigger_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/combatstate_condition_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/getaction_condition_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/hppctbetween_condition_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/interruptedaction_condition_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/phaseactive_condition_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/varequals_condition_model.dart';
import 'package:sapphire_editor/models/timeline/selector/selector_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/actiontimeline_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/battletalk_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/bnpcdespawn_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/bnpcspawn_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/castaction_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/interruptaction_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/rollrng_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/setpos_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/settrigger_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/snapshot_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/statuseffect_point_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_phase_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_schedule_model.dart';

class TimelineSanitySvc {
  static const Set<String> _placeholderRefs = {
    '',
    '<unknown>',
    '<unset>',
    '<none>',
    '<to-be-defined>',
    '<to-de-befined>',
  };

  static const Set<ConditionType> _editorSupportedConditions = {
    ConditionType.combatState,
    ConditionType.eObjInteract,
    ConditionType.getAction,
    ConditionType.hpPctBetween,
    ConditionType.phaseActive,
    ConditionType.interruptedAction,
    ConditionType.varEquals,
  };

  static List<SanityItem> run(TimelineModel timeline) {
    final items = <SanityItem>[];
    final sink = _SanitySink(items);

    final actorByName = <String, ActorModel>{};
    final actorNameCounts = <String, int>{};
    final selectorByName = <String, SelectorModel>{};
    final selectorNameCounts = <String, int>{};
    final triggerIdCounts = <int, int>{};
    final usedSelectors = <String>{};

    _checkTimelineBasics(timeline, sink);
    _indexActors(timeline, sink, actorByName, actorNameCounts);
    _indexSelectors(
      timeline,
      sink,
      selectorByName,
      selectorNameCounts,
      usedSelectors,
    );
    _indexTriggers(timeline, sink, triggerIdCounts);

    final lookup = _SanityLookup(
      actorByName: actorByName,
      actorNameCounts: actorNameCounts,
      selectorByName: selectorByName,
      selectorNameCounts: selectorNameCounts,
      triggerIdCounts: triggerIdCounts,
      triggerIds: triggerIdCounts.keys.toSet(),
      usedSelectors: usedSelectors,
    );

    for(final actor in timeline.actors) {
      _checkActor(actor, sink);
      _checkActorPhases(actor, lookup, sink);
    }

    if(timeline.conditions.isEmpty) {
      sink.warning(
        'NoTriggersDefined',
        'Timeline has no triggers. Phase transitions or trigger actions will never execute.',
      );
    }

    _checkUnusedSelectors(timeline, lookup, sink);

    items.sort((left, right) {
      final severityCmp = left.severity.index.compareTo(right.severity.index);
      if(severityCmp != 0) {
        return severityCmp;
      }

      final typeCmp = left.type.compareTo(right.type);
      if(typeCmp != 0) {
        return typeCmp;
      }

      return left.desc.compareTo(right.desc);
    });

    return items;
  }

  static void _checkTimelineBasics(TimelineModel timeline, _SanitySink sink) {
    if(_isMissingRef(timeline.name)) {
      sink.warning('MissingTimelineName', 'Timeline name is empty.');
    }

    if(timeline.version < TimelineModel.VERSION_MODEL) {
      sink.info(
        'TimelineVersion',
        'Timeline schema version ${timeline.version} is older than editor version ${TimelineModel.VERSION_MODEL}.',
      );
    }

    if(timeline.actors.isEmpty) {
      sink.error('NoActors', 'Timeline has no actors.');
    }
  }

  static void _indexActors(
    TimelineModel timeline,
    _SanitySink sink,
    Map<String, ActorModel> actorByName,
    Map<String, int> actorNameCounts,
  ) {
    final actorIdCounts = <int, int>{};

    for(final actor in timeline.actors) {
      _incrementCount(actorIdCounts, actor.id);
      _incrementCount(actorNameCounts, actor.name);
      actorByName.putIfAbsent(actor.name, () => actor);
    }

    for(final entry in actorIdCounts.entries) {
      if(entry.value > 1) {
        sink.error(
          'DuplicateActorId',
          'Actor id ${entry.key} is used ${entry.value} times.',
        );
      }

      if(entry.key <= 0) {
        sink.error(
          'InvalidActorId',
          'Actor id ${entry.key} must be greater than 0.',
        );
      }
    }

    for(final entry in actorNameCounts.entries) {
      if(_isMissingRef(entry.key)) {
        sink.error(
          'MissingActorName',
          'An actor has an empty or placeholder name.',
        );
      }

      if(entry.value > 1) {
        sink.error(
          'DuplicateActorName',
          'Actor name \'${entry.key}\' is used ${entry.value} times.',
        );
      }
    }
  }

  static void _indexSelectors(
    TimelineModel timeline,
    _SanitySink sink,
    Map<String, SelectorModel> selectorByName,
    Map<String, int> selectorNameCounts,
    Set<String> usedSelectors,
  ) {
    final selectorIdCounts = <int, int>{};

    for(final selector in timeline.selectors) {
      _incrementCount(selectorIdCounts, selector.id);
      _incrementCount(selectorNameCounts, selector.name);
      selectorByName.putIfAbsent(selector.name, () => selector);

      if(_isMissingRef(selector.name)) {
        sink.error(
          'MissingSelectorName',
          'Selector #${selector.id} has an empty or placeholder name.',
        );
      }

      if(selector.count < 1) {
        sink.error(
          'InvalidSelectorCount',
          'Selector \'${selector.name}\' has count ${selector.count}. Count must be at least 1.',
        );
      }

      if(selector.filters.isEmpty) {
        sink.warning(
          'SelectorNoFilters',
          'Selector \'${selector.name}\' has no filters and may be too broad.',
        );
      }

      if(!_isMissingRef(selector.excludeSelectorName)) {
        usedSelectors.add(selector.excludeSelectorName);
      }

      if(selector.excludeSelectorName == selector.name &&
          !_isMissingRef(selector.excludeSelectorName)) {
        sink.warning(
          'SelectorSelfExclude',
          'Selector \'${selector.name}\' excludes itself.',
        );
      }
    }

    for(final entry in selectorIdCounts.entries) {
      if(entry.value > 1) {
        sink.error(
          'DuplicateSelectorId',
          'Selector id ${entry.key} is used ${entry.value} times.',
        );
      }

      if(entry.key <= 0) {
        sink.error(
          'InvalidSelectorId',
          'Selector id ${entry.key} must be greater than 0.',
        );
      }
    }

    for(final entry in selectorNameCounts.entries) {
      if(entry.value > 1) {
        sink.error(
          'DuplicateSelectorName',
          'Selector name \'${entry.key}\' is used ${entry.value} times.',
        );
      }
    }

    for(final selector in timeline.selectors) {
      if(_isMissingRef(selector.excludeSelectorName)) {
        continue;
      }

      if(!selectorByName.containsKey(selector.excludeSelectorName)) {
        sink.error(
          'InvalidSelectorExclude',
          'Selector \'${selector.name}\' excludes unknown selector \'${selector.excludeSelectorName}\'.',
        );
      } else if((selectorNameCounts[selector.excludeSelectorName] ?? 0) > 1) {
        sink.error(
          'AmbiguousSelectorExclude',
          'Selector \'${selector.name}\' excludes selector name \'${selector.excludeSelectorName}\' which is duplicated.',
        );
      }
    }
  }

  static void _indexTriggers(
    TimelineModel timeline,
    _SanitySink sink,
    Map<int, int> triggerIdCounts,
  ) {
    for(final actor in timeline.actors) {
      for(final phase in actor.phases) {
        for(final trigger in phase.triggers) {
          _incrementCount(triggerIdCounts, trigger.id);

          if(trigger.id <= 0) {
            sink.error(
              'InvalidTriggerId',
              '${_phasePath(actor, phase)} has trigger id ${trigger.id}. Trigger ids must be greater than 0.',
            );
          }
        }
      }
    }

    for(final entry in triggerIdCounts.entries) {
      if(entry.value > 1) {
        sink.error(
          'DuplicateTriggerId',
          'Trigger id ${entry.key} is used ${entry.value} times.',
        );
      }
    }
  }

  static void _checkActor(ActorModel actor, _SanitySink sink) {
    if(actor.hp <= 0) {
      sink.error(
        'InvalidActorHP',
        'Actor \'${actor.name}\' has HP ${actor.hp}. HP must be greater than 0.',
      );
    }

    final localNames = <String>{};
    for(final subactor in actor.subactors) {
      if(_isMissingRef(subactor)) {
        sink.warning(
          'MissingSubactorName',
          'Actor \'${actor.name}\' contains a subactor with an empty or placeholder name.',
        );
        continue;
      }

      if(subactor == actor.name) {
        sink.warning(
          'SubactorMatchesActor',
          'Actor \'${actor.name}\' has subactor \'$subactor\' matching the main actor name.',
        );
      }

      if(!localNames.add(subactor)) {
        sink.warning(
          'DuplicateSubactorName',
          'Actor \'${actor.name}\' repeats subactor name \'$subactor\'.',
        );
      }
    }
  }

  static void _checkActorPhases(
    ActorModel actor,
    _SanityLookup lookup,
    _SanitySink sink,
  ) {
    if(actor.phases.isEmpty) {
      sink.warning(
        'ActorNoPhases',
        'Actor \'${actor.name}\' has no phases.',
      );
      return;
    }

    final phaseIdCounts = <String, int>{};
    final phaseNameCounts = <String, int>{};
    final scheduleIdCounts = <int, int>{};

    for(final phase in actor.phases) {
      _incrementCount(phaseIdCounts, phase.id);
      _incrementCount(phaseNameCounts, phase.name);

      for(final schedule in phase.schedules) {
        _incrementCount(scheduleIdCounts, schedule.id);
      }
    }

    for(final entry in phaseIdCounts.entries) {
      if(_isMissingRef(entry.key)) {
        sink.error(
          'MissingPhaseId',
          'Actor \'${actor.name}\' has a phase with an empty or placeholder id.',
        );
      }

      if(entry.value > 1) {
        sink.error(
          'DuplicatePhaseId',
          'Actor \'${actor.name}\' uses phase id \'${entry.key}\' ${entry.value} times.',
        );
      }
    }

    for(final entry in phaseNameCounts.entries) {
      if(_isMissingRef(entry.key)) {
        sink.warning(
          'MissingPhaseName',
          'Actor \'${actor.name}\' has a phase with an empty or placeholder name.',
        );
      }

      if(entry.value > 1) {
        sink.warning(
          'DuplicatePhaseName',
          'Actor \'${actor.name}\' repeats phase name \'${entry.key}\' ${entry.value} times.',
        );
      }
    }

    for(final entry in scheduleIdCounts.entries) {
      if(entry.key <= 0) {
        sink.error(
          'InvalidScheduleId',
          'Actor \'${actor.name}\' has schedule id ${entry.key}. Schedule ids must be greater than 0.',
        );
      }

      if(entry.value > 1) {
        sink.error(
          'DuplicateScheduleId',
          'Actor \'${actor.name}\' uses schedule id ${entry.key} ${entry.value} times across phases.',
        );
      }
    }

    for(final phase in actor.phases) {
      _checkPhase(actor, phase, lookup, sink);
    }
  }

  static void _checkPhase(
    ActorModel actor,
    TimelinePhaseModel phase,
    _SanityLookup lookup,
    _SanitySink sink,
  ) {
    final phasePath = _phasePath(actor, phase);

    if(phase.schedules.isEmpty &&
        phase.triggers.isEmpty &&
        phase.onEnter.isEmpty &&
        phase.onExit.isEmpty) {
      sink.warning(
        'EmptyPhase',
        '$phasePath has no schedules, hooks, or triggers.',
      );
    }

    final timepointIds = <int, String>{};

    void registerTimepointIds(List<TimepointModel> points, String source) {
      for(final point in points) {
        if(point.id <= 0) {
          sink.error(
            'InvalidTimepointId',
            '$phasePath has $source timepoint id ${point.id}. Timepoint ids must be greater than 0.',
          );
        }

        final previousSource = timepointIds[point.id];
        if(previousSource != null) {
          sink.error(
            'DuplicateTimepointId',
            '$phasePath reuses timepoint id ${point.id} in $source and $previousSource.',
          );
        } else {
          timepointIds[point.id] = source;
        }
      }
    }

    registerTimepointIds(phase.onEnter, 'onEnter');
    registerTimepointIds(phase.onExit, 'onExit');
    for(final schedule in phase.schedules) {
      registerTimepointIds(
        schedule.timepoints,
        'schedule \'${schedule.name}\'',
      );
    }

    _checkTimepointList(
      actor: actor,
      phase: phase,
      scopeLabel: '$phasePath onEnter',
      points: phase.onEnter,
      lookup: lookup,
      sink: sink,
    );

    _checkTimepointList(
      actor: actor,
      phase: phase,
      scopeLabel: '$phasePath onExit',
      points: phase.onExit,
      lookup: lookup,
      sink: sink,
    );

    final scheduleNameCounts = <String, int>{};
    for(final schedule in phase.schedules) {
      _incrementCount(scheduleNameCounts, schedule.name);
    }

    for(final entry in scheduleNameCounts.entries) {
      if(_isMissingRef(entry.key)) {
        sink.warning(
          'MissingScheduleName',
          '$phasePath has a schedule with an empty or placeholder name.',
        );
      } else if(entry.value > 1) {
        sink.warning(
          'DuplicateScheduleName',
          '$phasePath repeats schedule name \'${entry.key}\' ${entry.value} times.',
        );
      }
    }

    final hasLoopingSchedule = phase.schedules
        .any((schedule) => schedule.loopType != TimelineScheduleLoopType.none);

    for(final schedule in phase.schedules) {
      final schedulePath = _schedulePath(actor, phase, schedule);

      if(schedule.timepoints.isEmpty) {
        sink.warning(
          'EmptySchedule',
          '$schedulePath has no timepoints.',
        );
      }

      if(schedule.loopCount < 1) {
        sink.error(
          'InvalidLoopCount',
          '$schedulePath has loopCount ${schedule.loopCount}. loopCount must be at least 1.',
        );
      }

      if(schedule.loopType == TimelineScheduleLoopType.none &&
          schedule.loopCount != 1) {
        sink.info(
          'LoopCountIgnored',
          '$schedulePath has loopType \'none\' with loopCount ${schedule.loopCount}. loopCount is ignored unless loopType is finite.',
        );
      }

      if(schedule.loopType == TimelineScheduleLoopType.finite &&
          schedule.loopCount < 1) {
        sink.error(
          'InvalidFiniteLoopCount',
          '$schedulePath is finite loop with loopCount ${schedule.loopCount}.',
        );
      }

      if(schedule.timepoints.isNotEmpty) {
        final maxStartTime = schedule.timepoints
            .map((point) => point.startTime)
            .reduce((left, right) => left > right ? left : right);

        if(schedule.loopType == TimelineScheduleLoopType.infinite &&
            maxStartTime == 0) {
          sink.warning(
            'InfiniteZeroDurationLoop',
            '$schedulePath loops infinitely with zero-duration timepoints (all at 0ms).',
          );
        }

        if(schedule.loopType == TimelineScheduleLoopType.finite &&
            schedule.loopCount > 1 &&
            maxStartTime == 0) {
          sink.warning(
            'FiniteZeroDurationLoop',
            '$schedulePath loops ${schedule.loopCount} times with zero-duration timepoints (all at 0ms).',
          );
        }

        if(schedule.timepoints
            .every((point) => point.type == TimepointType.idle)) {
          sink.warning(
            'IdleOnlySchedule',
            '$schedulePath only contains idle timepoints.',
          );
        }
      }

      _checkTimepointList(
        actor: actor,
        phase: phase,
        scopeLabel: schedulePath,
        points: schedule.timepoints,
        lookup: lookup,
        sink: sink,
      );
    }

    final triggerSummary = _checkTriggers(actor, phase, lookup, sink);

    if(phase.schedules.isNotEmpty &&
        !triggerSummary.hasTransitionOut &&
        !hasLoopingSchedule) {
      sink.warning(
        'StallNoContinuation',
        '$phasePath has only non-looping schedules and no transitionPhase trigger to another phase.',
      );
    }

    if(phase.schedules.any(
          (schedule) => schedule.loopType == TimelineScheduleLoopType.infinite,
        ) &&
        !triggerSummary.hasTransitionOut) {
      sink.warning(
        'InfiniteLoopNoExit',
        '$phasePath contains infinite loop schedules but no transitionPhase trigger to another phase.',
      );
    }

    if(triggerSummary.hasTransitionAction &&
        triggerSummary.selfTransitionCount > 0 &&
        !triggerSummary.hasTransitionOut &&
        !hasLoopingSchedule) {
      sink.warning(
        'SelfTransitionOnly',
        '$phasePath has transitionPhase triggers that only point back to the same phase.',
      );
    }
  }

  static _PhaseTriggerSummary _checkTriggers(
    ActorModel actor,
    TimelinePhaseModel phase,
    _SanityLookup lookup,
    _SanitySink sink,
  ) {
    var hasTransitionAction = false;
    var hasTransitionOut = false;
    var selfTransitionCount = 0;

    final phaseIds = actor.phases.map((entry) => entry.id).toSet();

    for(final trigger in phase.triggers) {
      final triggerPath = '${_phasePath(actor, phase)} trigger #${trigger.id}';

      if(!_editorSupportedConditions.contains(trigger.condition)) {
        sink.warning(
          'UnsupportedConditionEditor',
          '$triggerPath uses condition \'${trigger.condition.name}\' which currently has no editor UI support.',
        );
      }

      _checkCondition(trigger, actor, phase, lookup, sink);

      final action = trigger.action;
      if(action == null) {
        sink.warning(
          'MissingTriggerAction',
          '$triggerPath has no action.',
        );
        continue;
      }

      if(action.type == 'transitionPhase') {
        hasTransitionAction = true;

        if(_isMissingRef(action.phaseId)) {
          sink.error(
            'MissingTransitionPhase',
            '$triggerPath has transitionPhase action with an empty target phase id.',
          );
          continue;
        }

        final targetPhaseId = action.phaseId!;
        if(!phaseIds.contains(targetPhaseId)) {
          sink.error(
            'InvalidTransitionPhase',
            '$triggerPath targets missing phase \'$targetPhaseId\'.',
          );
          continue;
        }

        if(targetPhaseId == phase.id) {
          selfTransitionCount += 1;
        } else {
          hasTransitionOut = true;
        }
      } else if(action.type == 'timepoint') {
        final timepoint = action.timepoint;
        if(timepoint == null) {
          sink.error(
            'MissingTriggerActionTimepoint',
            '$triggerPath has timepoint action without a timepoint payload.',
          );
          continue;
        }

        _checkTimepoint(
          actor: actor,
          phase: phase,
          scopeLabel: '$triggerPath action timepoint',
          point: timepoint,
          ownerTriggerId: trigger.id,
          lookup: lookup,
          sink: sink,
        );
      } else {
        sink.warning(
          'UnsupportedTriggerActionType',
          '$triggerPath uses unsupported action type \'${action.type}\'.',
        );
      }
    }

    return _PhaseTriggerSummary(
      hasTransitionAction: hasTransitionAction,
      hasTransitionOut: hasTransitionOut,
      selfTransitionCount: selfTransitionCount,
    );
  }

  static void _checkCondition(
    TriggerModel trigger,
    ActorModel ownerActor,
    TimelinePhaseModel ownerPhase,
    _SanityLookup lookup,
    _SanitySink sink,
  ) {
    final context =
        '${_phasePath(ownerActor, ownerPhase)} trigger #${trigger.id}';

    switch (trigger.condition) {
      case ConditionType.combatState:
        final data = _asConditionData<CombatStateConditionModel>(
          trigger,
          context,
          sink,
        );
        if(data == null) {
          return;
        }

        _checkGlobalActorRef(
          actorName: data.sourceActor,
          context: '$context combatState condition',
          lookup: lookup,
          sink: sink,
        );
        break;
      case ConditionType.eObjInteract:
        break;
      case ConditionType.directorVarGreaterThan:
        break;
      case ConditionType.elapsedTimeGreaterThan:
        break;
      case ConditionType.getAction:
        final data = _asConditionData<GetActionConditionModel>(
          trigger,
          context,
          sink,
        );
        if(data == null) {
          return;
        }

        _checkGlobalActorRef(
          actorName: data.sourceActor,
          context: '$context getAction condition',
          lookup: lookup,
          sink: sink,
        );

        if(data.actionId <= 0) {
          sink.error(
            'InvalidActionId',
            '$context getAction condition has actionId ${data.actionId}.',
          );
        }
        break;
      case ConditionType.hpPctBetween:
        final data = _asConditionData<HPPctBetweenConditionModel>(
          trigger,
          context,
          sink,
        );
        if(data == null) {
          return;
        }

        _checkGlobalActorRef(
          actorName: data.sourceActor,
          context: '$context hpPctBetween condition',
          lookup: lookup,
          sink: sink,
        );

        final hpMin = data.hpMin;
        final hpMax = data.hpMax;
        if(hpMin == null || hpMax == null) {
          sink.error(
            'MissingHpBounds',
            '$context hpPctBetween condition is missing hpMin or hpMax.',
          );
          return;
        }

        if(hpMin > hpMax) {
          sink.error(
            'InvalidHpRange',
            '$context hpPctBetween condition has hpMin $hpMin greater than hpMax $hpMax.',
          );
        }

        if(hpMin < 0 || hpMin > 100 || hpMax < 0 || hpMax > 100) {
          sink.error(
            'InvalidHpBounds',
            '$context hpPctBetween condition has bounds outside 0-100 ($hpMin-$hpMax).',
          );
        }
        break;
      case ConditionType.hpPctLessThan:
        final raw = trigger.paramData;
        if(raw is Map) {
          final hpValue = raw['hpLessThan'];
          if(hpValue is num) {
            if(hpValue < 0 || hpValue > 100) {
              sink.error(
                'InvalidHpBound',
                '$context hpPctLessThan condition has hpLessThan $hpValue outside 0-100.',
              );
            }
          }

          final sourceActor = raw['sourceActor'];
          if(sourceActor is String) {
            _checkGlobalActorRef(
              actorName: sourceActor,
              context: '$context hpPctLessThan condition',
              lookup: lookup,
              sink: sink,
            );
          }
        }
        break;
      case ConditionType.phaseActive:
        final data = _asConditionData<PhaseActiveConditionModel>(
          trigger,
          context,
          sink,
        );
        if(data == null) {
          return;
        }

        final actorIsValid = _checkGlobalActorRef(
          actorName: data.sourceActor,
          context: '$context phaseActive condition',
          lookup: lookup,
          sink: sink,
        );

        if(!actorIsValid) {
          return;
        }

        final sourceActor = lookup.actorByName[data.sourceActor];
        if(sourceActor == null) {
          return;
        }

        if(_isMissingRef(data.phaseId)) {
          sink.error(
            'MissingPhaseRef',
            '$context phaseActive condition has an empty phase reference.',
          );
          return;
        }

        if(!sourceActor.phases.any((phase) => phase.id == data.phaseId)) {
          sink.error(
            'InvalidPhaseRef',
            '$context phaseActive condition references missing phase \'${data.phaseId}\' on actor \'${data.sourceActor}\'.',
          );
        }
        break;
      case ConditionType.interruptedAction:
        final data = _asConditionData<InterruptedActionConditionModel>(
          trigger,
          context,
          sink,
        );
        if(data == null) {
          return;
        }

        _checkGlobalActorRef(
          actorName: data.sourceActor,
          context: '$context interruptedAction condition',
          lookup: lookup,
          sink: sink,
        );

        if(data.actionId <= 0) {
          sink.error(
            'InvalidActionId',
            '$context interruptedAction condition has actionId ${data.actionId}.',
          );
        }
        break;
      case ConditionType.varEquals:
        final data = _asConditionData<VarEqualsConditionModel>(
          trigger,
          context,
          sink,
        );
        if(data == null) {
          return;
        }

        if(data.index < 0) {
          sink.error(
            'InvalidVarIndex',
            '$context varEquals condition has negative index ${data.index}.',
          );
        }
        break;
    }
  }

  static void _checkTimepointList({
    required ActorModel actor,
    required TimelinePhaseModel phase,
    required String scopeLabel,
    required List<TimepointModel> points,
    required _SanityLookup lookup,
    required _SanitySink sink,
  }) {
    var previousTime = -1;

    for(var index = 0; index < points.length; index++) {
      final point = points[index];

      if(point.startTime < 0) {
        sink.error(
          'NegativeStartTime',
          '$scopeLabel has timepoint #${point.id} with negative startTime ${point.startTime}ms.',
        );
      }

      if(index > 0 && point.startTime < previousTime) {
        sink.warning(
          'NonMonotonicStartTime',
          '$scopeLabel is not sorted by absolute startTime at timepoint #${point.id} (${point.startTime}ms after ${previousTime}ms).',
        );
      }

      previousTime = point.startTime;
      _checkTimepoint(
        actor: actor,
        phase: phase,
        scopeLabel: scopeLabel,
        point: point,
        lookup: lookup,
        sink: sink,
      );
    }
  }

  static void _checkTimepoint({
    required ActorModel actor,
    required TimelinePhaseModel phase,
    required String scopeLabel,
    required TimepointModel point,
    required _SanityLookup lookup,
    required _SanitySink sink,
    int? ownerTriggerId,
  }) {
    final localActorNames = _localActorNames(actor);
    final context = '$scopeLabel timepoint #${point.id} (${point.type.name})';

    switch (point.type) {
      case TimepointType.actionTimeline:
        final data = _asTimepointData<ActionTimelinePointModel>(
          point,
          context,
          sink,
        );
        if(data == null) {
          return;
        }

        _checkGlobalActorRef(
          actorName: data.actorName,
          context: context,
          lookup: lookup,
          sink: sink,
        );

        if(data.actionTimelineId <= 0) {
          sink.error(
            'InvalidActionTimelineId',
            '$context has actionTimelineId ${data.actionTimelineId}.',
          );
        }
        break;
      case TimepointType.battleTalk:
        final data = _asTimepointData<BattleTalkPointModel>(
          point,
          context,
          sink,
        );
        if(data == null) {
          return;
        }

        _checkGlobalActorRef(
          actorName: data.talkerActorName,
          context: context,
          lookup: lookup,
          sink: sink,
        );

        if(data.battleTalkId <= 0) {
          sink.error(
            'InvalidBattleTalkId',
            '$context has battleTalkId ${data.battleTalkId}.',
          );
        }

        if(data.length < 0) {
          sink.error(
            'InvalidBattleTalkLength',
            '$context has negative length ${data.length}ms.',
          );
        }
        break;
      case TimepointType.bNpcDespawn:
        final data = _asTimepointData<BNpcDespawnPointModel>(
          point,
          context,
          sink,
        );
        if(data == null) {
          return;
        }

        _checkGlobalActorRef(
          actorName: data.despawnActor,
          context: context,
          lookup: lookup,
          sink: sink,
        );
        break;
      case TimepointType.bNpcFlags:
        break;
      case TimepointType.bNpcSpawn:
        final data = _asTimepointData<BNpcSpawnPointModel>(
          point,
          context,
          sink,
        );
        if(data == null) {
          return;
        }

        _checkGlobalActorRef(
          actorName: data.spawnActor,
          context: context,
          lookup: lookup,
          sink: sink,
        );
        break;
      case TimepointType.castAction:
        final data = _asTimepointData<CastActionPointModel>(
          point,
          context,
          sink,
        );
        if(data == null) {
          return;
        }

        _checkLocalActorRef(
          actorName: data.sourceActor,
          localActorNames: localActorNames,
          context: '$context sourceActor',
          sink: sink,
        );

        if(data.actionId <= 0) {
          sink.error(
            'InvalidActionId',
            '$context has actionId ${data.actionId}.',
          );
        }

        if(data.snapshot && data.snapshotTime < 0) {
          sink.error(
            'InvalidSnapshotTime',
            '$context has snapshot enabled with negative snapshotTime ${data.snapshotTime}ms.',
          );
        }

        if(data.targetType == ActorTargetType.selectorPos ||
            data.targetType == ActorTargetType.selectorTarget) {
          _checkSelectorRef(
            selectorName: data.selectorName,
            selectorIndex: data.selectorIndex,
            context: '$context target selector',
            lookup: lookup,
            sink: sink,
          );
        }

        if(data.targetType == ActorTargetType.none) {
          sink.warning(
            'UnsupportedTargetType',
            '$context uses targetType none.',
          );
        }
        break;
      case TimepointType.directorFlags:
        break;
      case TimepointType.directorSeq:
        break;
      case TimepointType.directorVar:
        break;
      case TimepointType.idle:
        break;
      case TimepointType.interruptAction:
        final data = _asTimepointData<InterruptActionPointModel>(
          point,
          context,
          sink,
        );
        if(data == null) {
          return;
        }

        _checkLocalActorRef(
          actorName: data.sourceActor,
          localActorNames: localActorNames,
          context: '$context sourceActor',
          sink: sink,
        );

        if(data.actionId <= 0) {
          sink.error(
            'InvalidActionId',
            '$context has actionId ${data.actionId}.',
          );
        }
        break;
      case TimepointType.logMessage:
        break;
      case TimepointType.rollRNG:
        final data = _asTimepointData<RollRNGPointModel>(
          point,
          context,
          sink,
        );
        if(data == null) {
          return;
        }

        if(data.min > data.max) {
          sink.error(
            'InvalidRngRange',
            '$context has min ${data.min} greater than max ${data.max}.',
          );
        }

        if(data.index < 0) {
          sink.error(
            'InvalidRngIndex',
            '$context has negative index ${data.index}.',
          );
        }
        break;
      case TimepointType.setBGM:
        break;
      case TimepointType.setTrigger:
        final data = _asTimepointData<SetTriggerPointModel>(
          point,
          context,
          sink,
        );
        if(data == null) {
          return;
        }

        if(data.triggerId <= 0) {
          sink.error(
            'InvalidTriggerRef',
            '$context has triggerId ${data.triggerId}.',
          );
        } else if(!lookup.triggerIds.contains(data.triggerId)) {
          sink.error(
            'MissingTriggerRef',
            '$context references missing trigger id ${data.triggerId}.',
          );
        } else if((lookup.triggerIdCounts[data.triggerId] ?? 0) > 1) {
          sink.error(
            'AmbiguousTriggerRef',
            '$context references trigger id ${data.triggerId}, but that id is duplicated.',
          );
        }

        if(!_isMissingRef(data.targetActor)) {
          _checkGlobalActorRef(
            actorName: data.targetActor,
            context: '$context targetActor',
            lookup: lookup,
            sink: sink,
          );
        }

        if(ownerTriggerId != null &&
            point.startTime == 0 &&
            data.enabled &&
            data.triggerId == ownerTriggerId) {
          sink.warning(
            'TriggerSelfToggleThrash',
            '$context enables its own trigger id at 0ms, which can repeatedly retrigger.',
          );
        }
        break;
      case TimepointType.setPos:
        final data = _asTimepointData<SetPosPointModel>(
          point,
          context,
          sink,
        );
        if(data == null) {
          return;
        }

        if(data.pos.length != 3) {
          sink.error(
            'InvalidPositionVector',
            '$context has position vector length ${data.pos.length}. Expected 3.',
          );
        }

        _checkLocalActorRef(
          actorName: data.actorName,
          localActorNames: localActorNames,
          context: '$context actor',
          sink: sink,
        );

        if(data.targetType == ActorTargetType.target) {
          _checkGlobalActorRef(
            actorName: data.targetActor,
            context: '$context target actor',
            lookup: lookup,
            sink: sink,
          );
        }

        if(data.targetType == ActorTargetType.selectorPos ||
            data.targetType == ActorTargetType.selectorTarget) {
          _checkSelectorRef(
            selectorName: data.selectorName,
            selectorIndex: data.selectorIndex,
            context: '$context target selector',
            lookup: lookup,
            sink: sink,
          );
        }

        if(data.targetType == ActorTargetType.none) {
          sink.warning(
            'UnsupportedTargetType',
            '$context uses targetType none.',
          );
        }
        break;
      case TimepointType.snapshot:
        final data = _asTimepointData<SnapshotPointModel>(
          point,
          context,
          sink,
        );
        if(data == null) {
          return;
        }

        _checkLocalActorRef(
          actorName: data.sourceActor,
          localActorNames: localActorNames,
          context: '$context sourceActor',
          sink: sink,
        );

        _checkSelectorRef(
          selectorName: data.selectorName,
          context: '$context selector',
          lookup: lookup,
          sink: sink,
        );
        break;
      case TimepointType.statusEffect:
        final data = _asTimepointData<StatusEffectPointModel>(
          point,
          context,
          sink,
        );
        if(data == null) {
          return;
        }

        _checkLocalActorRef(
          actorName: data.sourceActor,
          localActorNames: localActorNames,
          context: '$context sourceActor',
          sink: sink,
        );

        if(data.statusId <= 0) {
          sink.error(
            'InvalidStatusId',
            '$context has statusId ${data.statusId}.',
          );
        }

        if(!data.isRemove && data.duration < 0) {
          sink.error(
            'InvalidStatusDuration',
            '$context has negative duration ${data.duration}ms.',
          );
        }

        if(data.targetType == ActorTargetType.selectorPos ||
            data.targetType == ActorTargetType.selectorTarget) {
          _checkSelectorRef(
            selectorName: data.selectorName,
            selectorIndex: data.selectorIndex,
            context: '$context target selector',
            lookup: lookup,
            sink: sink,
          );
        }

        if(data.targetType == ActorTargetType.none) {
          sink.warning(
            'UnsupportedTargetType',
            '$context uses targetType none.',
          );
        }
        break;
    }
  }

  static void _checkUnusedSelectors(
    TimelineModel timeline,
    _SanityLookup lookup,
    _SanitySink sink,
  ) {
    for(final selector in timeline.selectors) {
      if(_isMissingRef(selector.name)) {
        continue;
      }

      if(!lookup.usedSelectors.contains(selector.name)) {
        sink.warning(
          'UnusedSelector',
          'Selector \'${selector.name}\' is defined but never referenced.',
        );
      }
    }
  }

  static T? _asConditionData<T>(
    TriggerModel trigger,
    String context,
    _SanitySink sink,
  ) {
    final data = trigger.paramData;
    if(data is T) {
      return data;
    }

    sink.error(
      'InvalidConditionPayload',
      '$context has payload type ${data.runtimeType}, expected $T.',
    );
    return null;
  }

  static T? _asTimepointData<T>(
    TimepointModel point,
    String context,
    _SanitySink sink,
  ) {
    final data = point.data;
    if(data is T) {
      return data;
    }

    sink.error(
      'InvalidTimepointPayload',
      '$context has payload type ${data.runtimeType}, expected $T.',
    );
    return null;
  }

  static bool _checkGlobalActorRef({
    required String? actorName,
    required String context,
    required _SanityLookup lookup,
    required _SanitySink sink,
  }) {
    if(_isMissingRef(actorName)) {
      sink.error(
        'MissingActorRef',
        '$context references an empty or placeholder actor.',
      );
      return false;
    }

    final normalizedName = actorName!;
    if((lookup.actorNameCounts[normalizedName] ?? 0) > 1) {
      sink.error(
        'AmbiguousActorRef',
        '$context references actor \'$normalizedName\', but actor names are duplicated.',
      );
      return false;
    }

    if(!lookup.actorByName.containsKey(normalizedName)) {
      sink.error(
        'InvalidActorRef',
        '$context references unknown actor \'$normalizedName\'.',
      );
      return false;
    }

    return true;
  }

  static bool _checkLocalActorRef({
    required String? actorName,
    required Set<String> localActorNames,
    required String context,
    required _SanitySink sink,
  }) {
    if(_isMissingRef(actorName)) {
      sink.error(
        'MissingActorRef',
        '$context references an empty or placeholder actor.',
      );
      return false;
    }

    if(!localActorNames.contains(actorName)) {
      sink.error(
        'InvalidLocalActorRef',
        '$context references actor \'$actorName\', but expected one of ${localActorNames.join(', ')}.',
      );
      return false;
    }

    return true;
  }

  static bool _checkSelectorRef({
    required String? selectorName,
    required String context,
    int? selectorIndex,
    required _SanityLookup lookup,
    required _SanitySink sink,
  }) {
    if(_isMissingRef(selectorName)) {
      sink.error(
        'MissingSelectorRef',
        '$context references an empty or placeholder selector.',
      );
      return false;
    }

    final normalizedName = selectorName!;
    if((lookup.selectorNameCounts[normalizedName] ?? 0) > 1) {
      sink.error(
        'AmbiguousSelectorRef',
        '$context references selector \'$normalizedName\', but selector names are duplicated.',
      );
      return false;
    }

    final selector = lookup.selectorByName[normalizedName];
    if(selector == null) {
      sink.error(
        'InvalidSelectorRef',
        '$context references unknown selector \'$normalizedName\'.',
      );
      return false;
    }

    lookup.usedSelectors.add(normalizedName);

    if(selectorIndex != null &&
        (selectorIndex < 0 || selectorIndex >= selector.count)) {
      sink.error(
        'InvalidSelectorIndex',
        '$context uses selector index ${selectorIndex + 1} but selector \'$normalizedName\' has count ${selector.count}.',
      );
      return false;
    }

    return true;
  }

  static Set<String> _localActorNames(ActorModel actor) {
    final names = <String>{actor.name, ...actor.subactors};
    names.removeWhere(_isMissingRef);
    return names;
  }

  static bool _isMissingRef(String? value) {
    if(value == null) {
      return true;
    }

    final normalized = value.trim().toLowerCase();
    return _placeholderRefs.contains(normalized);
  }

  static void _incrementCount<K>(Map<K, int> counts, K key) {
    counts[key] = (counts[key] ?? 0) + 1;
  }

  static String _phasePath(ActorModel actor, TimelinePhaseModel phase) {
    return 'Actor \'${actor.name}\' phase \'${phase.id}\'';
  }

  static String _schedulePath(
    ActorModel actor,
    TimelinePhaseModel phase,
    TimelineScheduleModel schedule,
  ) {
    return '${_phasePath(actor, phase)} schedule \'${schedule.name}\'';
  }
}

class _SanityLookup {
  final Map<String, ActorModel> actorByName;
  final Map<String, int> actorNameCounts;
  final Map<String, SelectorModel> selectorByName;
  final Map<String, int> selectorNameCounts;
  final Map<int, int> triggerIdCounts;
  final Set<int> triggerIds;
  final Set<String> usedSelectors;

  _SanityLookup({
    required this.actorByName,
    required this.actorNameCounts,
    required this.selectorByName,
    required this.selectorNameCounts,
    required this.triggerIdCounts,
    required this.triggerIds,
    required this.usedSelectors,
  });
}

class _PhaseTriggerSummary {
  final bool hasTransitionAction;
  final bool hasTransitionOut;
  final int selfTransitionCount;

  const _PhaseTriggerSummary({
    required this.hasTransitionAction,
    required this.hasTransitionOut,
    required this.selfTransitionCount,
  });
}

class _SanitySink {
  final List<SanityItem> _items;
  final Set<String> _seen = <String>{};

  _SanitySink(this._items);

  void error(String type, String desc) {
    _add(SanitySeverity.error, type, desc);
  }

  void warning(String type, String desc) {
    _add(SanitySeverity.warning, type, desc);
  }

  void info(String type, String desc) {
    _add(SanitySeverity.info, type, desc);
  }

  void _add(SanitySeverity severity, String type, String desc) {
    final key = '${severity.index}|$type|$desc';
    if(_seen.add(key)) {
      _items.add(SanityItem(severity, type, desc));
    }
  }
}

class SanityItem {
  final SanitySeverity severity;
  final String type;
  final String desc;

  const SanityItem(this.severity, this.type, this.desc);
}

enum SanitySeverity { error, warning, info }
