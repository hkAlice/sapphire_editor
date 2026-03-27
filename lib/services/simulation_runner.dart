import 'dart:convert';

import 'package:sapphire_editor/models/simulator/playback_config.dart';
import 'package:sapphire_editor/models/simulator/simulated_event.dart';
import 'package:sapphire_editor/models/simulator/simulation_state.dart';
import 'package:sapphire_editor/models/simulator/simulation_track_marker.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/condition/trigger_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/combatstate_condition_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/eobjinteract_condition_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/getaction_condition_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/hppctbetween_condition_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/interruptedaction_condition_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/phaseactive_condition_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/varequals_condition_model.dart';
import 'package:sapphire_editor/models/timeline/phase_timepoint_hook.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/castaction_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/directorvar_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/interruptaction_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/settrigger_point_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_phase_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_schedule_model.dart';

class SimulationRunner {
  static const int _maxEvents = 2000;
  static const int _lookBackForTrackMs = 20000;
  static const int _lookAheadForTrackMs = 45000;

  late TimelineModel _timeline;
  PlaybackConfig _config;

  int _elapsedMs = 0;
  bool _isPlaying = false;
  bool _isInSyncWithEditor = true;
  String _syncStatus = 'Ready';

  final List<SimulatedEvent> _events = <SimulatedEvent>[];
  final Map<int, _ActorRuntimeState> _actorsById = <int, _ActorRuntimeState>{};
  final Map<String, _ActorRuntimeState> _actorsByName =
      <String, _ActorRuntimeState>{};
  final Map<String, bool> _triggerEnableOverrides = <String, bool>{};

  String? _lastInteractedObject;

  SimulationRunner(
    TimelineModel timeline, {
    PlaybackConfig? config,
  }) : _config = config ?? const PlaybackConfig() {
    _timeline = _cloneTimeline(timeline);
    _bootstrapRuntimeState();
  }

  PlaybackConfig get config => _config;

  TimelineModel get timeline => _timeline;

  void setPlaying(bool isPlaying) {
    _isPlaying = isPlaying;
  }

  void setSyncStatus({required bool isInSync, required String status}) {
    _isInSyncWithEditor = isInSync;
    _syncStatus = status;
  }

  void setDpsPctPerSecond(double value) {
    _config = _config.copyWith(dpsPctPerSecond: value.clamp(0.0, 100.0));
  }

  void setSpeedMultiplier(double value) {
    _config = _config.copyWith(speedMultiplier: value.clamp(0.1, 10.0));
  }

  void replaceTimeline(TimelineModel timeline) {
    _timeline = _cloneTimeline(timeline);
    reset(keepSyncStatus: true);
    _appendInfoEvent('Timeline changed; simulator state was reset.');
  }

  void reset({bool keepSyncStatus = true}) {
    _elapsedMs = 0;
    _isPlaying = false;
    _events.clear();
    _actorsById.clear();
    _actorsByName.clear();
    _triggerEnableOverrides.clear();
    _lastInteractedObject = null;

    if(!keepSyncStatus) {
      _isInSyncWithEditor = true;
      _syncStatus = 'Ready';
    }

    _bootstrapRuntimeState();
  }

  List<TimelinePhaseModel> phasesForActor(int actorId) {
    final actor = _timeline.actors.firstWhere(
      (item) => item.id == actorId,
      orElse: () => _timeline.actors.first,
    );
    return actor.phases;
  }

  void setActorHpPct(int actorId, double hpPct) {
    final actor = _actorsById[actorId];
    if(actor == null) {
      return;
    }

    actor.hpPct = hpPct.clamp(0.0, 100.0);
    _appendEvent(
      actorState: actor,
      type: SimulatedEventType.manual,
      message: 'Manual HP set to ${actor.hpPct.toStringAsFixed(1)}%',
    );
  }

  void setActorCombatState(int actorId, ActorCombatState combatState) {
    final actor = _actorsById[actorId];
    if(actor == null) {
      return;
    }

    actor.combatState = combatState;
    _appendEvent(
      actorState: actor,
      type: SimulatedEventType.manual,
      message: 'Manual combat state set to ${combatState.name}',
    );
  }

  void transitionActorPhase(int actorId, int targetPhaseId) {
    final actor = _actorsById[actorId];
    if(actor == null) {
      return;
    }

    final targetPhase = _phaseById(actor.actor, targetPhaseId);
    if(targetPhase == null) {
      return;
    }

    _transitionToPhase(
      actor,
      targetPhase.id,
      reason: 'manual override',
    );
  }

  void injectActionCast({required int actorId, required int actionId}) {
    final actor = _actorsById[actorId];
    if(actor == null) {
      return;
    }

    actor.lastActionId = actionId;
    _appendEvent(
      actorState: actor,
      type: SimulatedEventType.manual,
      message: 'Manual cast injection Action#$actionId',
    );
  }

  void injectInterruptedAction({required int actorId, required int actionId}) {
    final actor = _actorsById[actorId];
    if(actor == null) {
      return;
    }

    actor.lastInterruptedActionId = actionId;
    _appendEvent(
      actorState: actor,
      type: SimulatedEventType.manual,
      message: 'Manual interrupted action injection Action#$actionId',
    );
  }

  void injectEObjInteract(String objectName) {
    _lastInteractedObject = objectName.trim();
    for(final actor in _actorsById.values) {
      _appendEvent(
        actorState: actor,
        type: SimulatedEventType.manual,
        message: 'Manual EObj interaction injection "$_lastInteractedObject"',
      );
    }
  }

  void setVarValue({
    required int actorId,
    required VarType type,
    required int index,
    required int value,
  }) {
    final actor = _actorsById[actorId];
    if(actor == null) {
      return;
    }

    actor.varStore.putIfAbsent(type, () => <int, int>{})[index] = value;
    _appendEvent(
      actorState: actor,
      type: SimulatedEventType.manual,
      message: 'Manual ${type.name} var[$index] set to $value',
    );
  }

  List<SimulatedEvent> tick(int deltaMs) {
    final adjustedDelta =
        (deltaMs * _config.speedMultiplier).round().clamp(0, 1000000);
    if(adjustedDelta <= 0) {
      return const <SimulatedEvent>[];
    }

    _elapsedMs += adjustedDelta;
    _applyAutoDps(adjustedDelta);

    final produced = <SimulatedEvent>[];
    for(final actorState in _actorsById.values) {
      _advanceActor(actorState, adjustedDelta, produced);
    }

    _events.addAll(produced);
    if(_events.length > _maxEvents) {
      _events.removeRange(0, _events.length - _maxEvents);
    }

    _clearTransientConditionInputs();
    return produced;
  }

  SimulationState snapshot() {
    final actors = _actorsById.values
        .map((runtime) => ActorSimulationViewState(
              actorId: runtime.actor.id,
              actorName: runtime.actor.name,
              hpPct: runtime.hpPct,
              combatState: runtime.combatState,
              currentPhaseId: runtime.currentPhaseId,
              currentPhaseName: _phaseFor(runtime).name,
              phaseElapsedMs: runtime.phaseElapsedMs,
            ))
        .toList()
      ..sort((left, right) => left.actorId.compareTo(right.actorId));

    final trackMarkers = _buildTrackMarkers();
    return SimulationState(
      isPlaying: _isPlaying,
      isInSyncWithEditor: _isInSyncWithEditor,
      syncStatus: _syncStatus,
      elapsedMs: _elapsedMs,
      config: _config,
      actors: actors,
      events: List<SimulatedEvent>.unmodifiable(_events),
      trackMarkers: List<SimulationTrackMarker>.unmodifiable(trackMarkers),
    );
  }

  void _bootstrapRuntimeState() {
    final bootstrapEvents = <SimulatedEvent>[];

    for(final actor in _timeline.actors) {
      if(actor.phases.isEmpty) {
        continue;
      }

      final initialPhase =
          _phaseById(actor, actor.initialPhaseId) ?? actor.phases.first;
      final runtime = _ActorRuntimeState(
        actor: actor,
        currentPhaseId: initialPhase.id,
      );
      _actorsById[actor.id] = runtime;
      _actorsByName[_keyActorName(actor.name)] = runtime;

      _activatePhase(runtime, initialPhase, bootstrapEvents, isInitial: true);
    }

    _events.addAll(bootstrapEvents);
  }

  void _applyAutoDps(int deltaMs) {
    if(_config.dpsPctPerSecond <= 0) {
      return;
    }

    final tickDrain = _config.dpsPctPerSecond * (deltaMs / 1000.0);
    for(final actorState in _actorsById.values) {
      actorState.hpPct = (actorState.hpPct - tickDrain).clamp(0.0, 100.0);
    }
  }

  void _advanceActor(
    _ActorRuntimeState actorState,
    int deltaMs,
    List<SimulatedEvent> produced,
  ) {
    actorState.phaseElapsedMs += deltaMs;

    final phase = _phaseFor(actorState);
    for(final scheduleState in actorState.scheduleStates.values) {
      _advanceSchedule(actorState, phase, scheduleState, deltaMs, produced);
    }

    _evaluateTriggers(actorState, produced);
  }

  void _advanceSchedule(
    _ActorRuntimeState actorState,
    TimelinePhaseModel phase,
    _ScheduleRuntimeState runtime,
    int deltaMs,
    List<SimulatedEvent> produced,
  ) {
    if(runtime.completed) {
      return;
    }

    final previousElapsed = runtime.elapsedMs;
    runtime.elapsedMs += deltaMs;

    for(final timepoint in runtime.orderedTimepoints) {
      if(timepoint.startTime > previousElapsed &&
          timepoint.startTime <= runtime.elapsedMs) {
        _executeTimepoint(
          actorState: actorState,
          phase: phase,
          point: timepoint,
          scheduleId: runtime.schedule.id,
          produced: produced,
        );
      }
    }

    final loopEndMs = runtime.loopEndMs;
    if(runtime.elapsedMs < loopEndMs) {
      return;
    }

    if(runtime.schedule.loopType == TimelineScheduleLoopType.none) {
      runtime.completed = true;
      return;
    }

    if(runtime.schedule.loopType == TimelineScheduleLoopType.infinite) {
      runtime.loopIteration += 1;
      runtime.elapsedMs = -1;
      return;
    }

    if(runtime.loopIteration >= runtime.schedule.loopCount) {
      runtime.completed = true;
    } else {
      runtime.loopIteration += 1;
      runtime.elapsedMs = -1;
    }
  }

  void _evaluateTriggers(
    _ActorRuntimeState actorState,
    List<SimulatedEvent> produced,
  ) {
    var guard = 0;

    while (guard < 10) {
      guard += 1;
      final phase = _phaseFor(actorState);
      var transitioned = false;

      for(final trigger in phase.triggers) {
        if(!_isTriggerEnabled(actorState.actor.id, phase.id, trigger)) {
          continue;
        }

        if(!trigger.loop && actorState.firedTriggerIds.contains(trigger.id)) {
          continue;
        }

        if(!_isConditionMet(trigger, actorState)) {
          continue;
        }

        if(!trigger.loop) {
          actorState.firedTriggerIds.add(trigger.id);
        }

        _appendEvent(
          actorState: actorState,
          type: SimulatedEventType.triggerMatched,
          triggerId: trigger.id,
          message: 'Trigger #${trigger.id} matched (${trigger.condition.name})',
          produced: produced,
        );

        final actionResult = _applyTriggerAction(
          actorState,
          phase,
          trigger,
          produced,
        );
        if(actionResult.didTransition) {
          transitioned = true;
          break;
        }
      }

      if(!transitioned) {
        break;
      }
    }
  }

  _TriggerActionResult _applyTriggerAction(
    _ActorRuntimeState actorState,
    TimelinePhaseModel phase,
    TriggerModel trigger,
    List<SimulatedEvent> produced,
  ) {
    final action = trigger.action;
    if(action == null) {
      return const _TriggerActionResult(didTransition: false);
    }

    if(action.type == 'transitionPhase') {
      final phaseId = action.phaseId;
      if(phaseId == null) {
        return const _TriggerActionResult(didTransition: false);
      }

      final targetPhase = _phaseById(actorState.actor, phaseId);
      if(targetPhase == null) {
        _appendEvent(
          actorState: actorState,
          type: SimulatedEventType.info,
          triggerId: trigger.id,
          message:
              'Trigger action ignored (phase $phaseId does not exist on actor).',
          produced: produced,
        );
        return const _TriggerActionResult(didTransition: false);
      }

      _transitionToPhase(
        actorState,
        targetPhase.id,
        reason: 'trigger #${trigger.id}',
        produced: produced,
      );
      return const _TriggerActionResult(didTransition: true);
    }

    if(action.type == 'timepoint' && action.timepoint != null) {
      _executeTimepoint(
        actorState: actorState,
        phase: phase,
        point: action.timepoint!,
        triggerId: trigger.id,
        produced: produced,
      );
    }

    return const _TriggerActionResult(didTransition: false);
  }

  void _transitionToPhase(
    _ActorRuntimeState actorState,
    int targetPhaseId, {
    required String reason,
    List<SimulatedEvent>? produced,
  }) {
    final eventSink = produced ?? _events;
    final fromPhase = _phaseFor(actorState);

    _appendEvent(
      actorState: actorState,
      type: SimulatedEventType.phaseTransition,
      message: 'Phase transition ${fromPhase.id} -> $targetPhaseId ($reason)',
      produced: produced,
    );

    _appendEvent(
      actorState: actorState,
      type: SimulatedEventType.phaseExit,
      phaseId: fromPhase.id,
      phaseName: fromPhase.name,
      message: 'Phase exit ${fromPhase.name}',
      produced: produced,
    );

    final onExit = _orderedTimepoints(fromPhase.onExit);
    for(final point in onExit) {
      _executeTimepoint(
        actorState: actorState,
        phase: fromPhase,
        point: point,
        scheduleId: PhaseHookScheduleIds.onExit,
        produced: eventSink,
      );
    }

    final targetPhase = _phaseById(actorState.actor, targetPhaseId);
    if(targetPhase == null) {
      return;
    }

    _activatePhase(actorState, targetPhase, eventSink);
  }

  void _activatePhase(
    _ActorRuntimeState actorState,
    TimelinePhaseModel targetPhase,
    List<SimulatedEvent> produced, {
    bool isInitial = false,
  }) {
    actorState.currentPhaseId = targetPhase.id;
    actorState.phaseElapsedMs = 0;
    actorState.firedTriggerIds.clear();
    actorState.scheduleStates
      ..clear()
      ..addEntries(targetPhase.schedules.map(
        (schedule) => MapEntry(schedule.id, _ScheduleRuntimeState(schedule)),
      ));

    _appendEvent(
      actorState: actorState,
      type: SimulatedEventType.phaseEnter,
      phaseId: targetPhase.id,
      phaseName: targetPhase.name,
      message: isInitial
          ? 'Initial phase ${targetPhase.name}'
          : 'Phase enter ${targetPhase.name}',
      produced: produced,
    );

    final onEnter = _orderedTimepoints(targetPhase.onEnter);
    for(final point in onEnter) {
      _executeTimepoint(
        actorState: actorState,
        phase: targetPhase,
        point: point,
        scheduleId: PhaseHookScheduleIds.onEnter,
        produced: produced,
      );
    }
  }

  void _executeTimepoint({
    required _ActorRuntimeState actorState,
    required TimelinePhaseModel phase,
    required TimepointModel point,
    int? scheduleId,
    int? triggerId,
    required List<SimulatedEvent> produced,
  }) {
    _appendEvent(
      actorState: actorState,
      type: SimulatedEventType.timepoint,
      phaseId: phase.id,
      phaseName: phase.name,
      scheduleId: scheduleId,
      triggerId: triggerId,
      timepointId: point.id,
      message: _timepointMessage(point),
      produced: produced,
    );

    switch(point.type) {
      case TimepointType.castAction:
        final payload = point.data;
        if(payload is CastActionPointModel) {
          final sourceActor =
              _resolveActorByName(payload.sourceActor, actorState);
          sourceActor.lastActionId = payload.actionId;
        }
      case TimepointType.interruptAction:
        final payload = point.data;
        if(payload is InterruptActionPointModel) {
          final sourceActor =
              _resolveActorByName(payload.sourceActor, actorState);
          sourceActor.lastInterruptedActionId = payload.actionId;
        }
      case TimepointType.setTrigger:
        final payload = point.data;
        if(payload is SetTriggerPointModel) {
          final targetActor =
              _resolveActorByName(payload.targetActor, actorState);
          final key = _triggerOverrideKey(
            targetActor.actor.id,
            payload.targetPhaseId,
            payload.triggerId,
          );
          _triggerEnableOverrides[key] = payload.enabled;
        }
      case TimepointType.directorVar:
        final payload = point.data;
        if(payload is DirectorVarPointModel) {
          final current =
              actorState.varStore[VarType.director]?[payload.idx] ?? 0;
          final next = _applyOpcode(payload.opc, current, payload.val);
          actorState.varStore.putIfAbsent(
              VarType.director, () => <int, int>{})[payload.idx] = next;
        }
      default:
        break;
    }
  }

  bool _isConditionMet(TriggerModel trigger, _ActorRuntimeState owner) {
    switch(trigger.condition) {
      case ConditionType.combatState:
        final data = trigger.paramData;
        if(data is! CombatStateConditionModel) {
          return false;
        }
        final source = _resolveActorByName(data.sourceActor, owner);
        return source.combatState == data.combatState;
      case ConditionType.eObjInteract:
        final data = trigger.paramData;
        if(data is! EObjInteractConditionModel) {
          return false;
        }
        if(_lastInteractedObject == null || _lastInteractedObject!.isEmpty) {
          return false;
        }
        if(data.eObjName.trim().isEmpty) {
          return true;
        }
        return data.eObjName.trim().toLowerCase() ==
            _lastInteractedObject!.trim().toLowerCase();
      case ConditionType.directorVarGreaterThan:
        final raw = trigger.paramData;
        if(raw is! Map) {
          return false;
        }
        final directorIndex =
            _readInt(raw, <String>['director', 'idx', 'index']);
        final threshold =
            _readInt(raw, <String>['greaterThan', 'value', 'val']) ?? 0;
        if(directorIndex == null) {
          return false;
        }
        final current = owner.varStore[VarType.director]?[directorIndex] ?? 0;
        return current > threshold;
      case ConditionType.elapsedTimeGreaterThan:
        final raw = trigger.paramData;
        if(raw is! Map) {
          return false;
        }
        final threshold = _readInt(
              raw,
              <String>['elapsedTime', 'elapsedMs', 'timeMs', 'ms', 'value'],
            ) ??
            0;
        return owner.phaseElapsedMs > threshold;
      case ConditionType.getAction:
        final data = trigger.paramData;
        if(data is! GetActionConditionModel) {
          return false;
        }
        final source = _resolveActorByName(data.sourceActor, owner);
        return source.lastActionId == data.actionId;
      case ConditionType.hpPctBetween:
        final data = trigger.paramData;
        if(data is! HPPctBetweenConditionModel) {
          return false;
        }
        final source = _resolveActorByName(data.sourceActor, owner);
        final min = (data.hpMin ?? 0).toDouble();
        final max = (data.hpMax ?? 100).toDouble();
        return source.hpPct >= min && source.hpPct <= max;
      case ConditionType.hpPctLessThan:
        final raw = trigger.paramData;
        if(raw is! Map) {
          return false;
        }
        final sourceName = raw['sourceActor'];
        final source = sourceName is String
            ? _resolveActorByName(sourceName, owner)
            : owner;
        final threshold = _readNum(raw, <String>['hpLessThan', 'value']) ?? 0;
        return source.hpPct < threshold;
      case ConditionType.phaseActive:
        final data = trigger.paramData;
        if(data is! PhaseActiveConditionModel || data.phaseId == null) {
          return false;
        }
        final source = _resolveActorByName(data.sourceActor, owner);
        return source.currentPhaseId == data.phaseId;
      case ConditionType.interruptedAction:
        final data = trigger.paramData;
        if(data is! InterruptedActionConditionModel) {
          return false;
        }
        final source = _resolveActorByName(data.sourceActor, owner);
        return source.lastInterruptedActionId == data.actionId;
      case ConditionType.varEquals:
        final data = trigger.paramData;
        if(data is! VarEqualsConditionModel) {
          return false;
        }
        final current = owner.varStore[data.type]?[data.index] ?? 0;
        return current == data.val;
    }
  }

  bool _isTriggerEnabled(int actorId, int phaseId, TriggerModel trigger) {
    final override = _triggerEnableOverrides[
        _triggerOverrideKey(actorId, phaseId, trigger.id)];
    return override ?? trigger.enabled;
  }

  _ActorRuntimeState _resolveActorByName(
    String? actorName,
    _ActorRuntimeState fallback,
  ) {
    final normalized = actorName?.trim() ?? '';
    if(normalized.isEmpty || normalized == '<unknown>') {
      return fallback;
    }

    return _actorsByName[_keyActorName(normalized)] ?? fallback;
  }

  String _timepointMessage(TimepointModel point) {
    final prefix = point.description.trim().isNotEmpty
        ? point.description.trim()
        : point.type.displayName;
    return '$prefix (${point.data})';
  }

  void _clearTransientConditionInputs() {
    for(final actorState in _actorsById.values) {
      actorState.lastActionId = null;
      actorState.lastInterruptedActionId = null;
    }
    _lastInteractedObject = null;
  }

  List<SimulationTrackMarker> _buildTrackMarkers() {
    final markers = <SimulationTrackMarker>[];
    final minPastTs = _elapsedMs - _lookBackForTrackMs;
    final maxFutureTs = _elapsedMs + _lookAheadForTrackMs;

    for(final event in _events) {
      if(event.timestampMs < minPastTs || event.timestampMs > maxFutureTs) {
        continue;
      }

      markers.add(SimulationTrackMarker(
        timestampMs: event.timestampMs,
        label: '${event.actorName}: ${event.message}',
        type: event.type,
        isPast: event.timestampMs <= _elapsedMs,
      ));
    }

    for(final actorState in _actorsById.values) {
      final phase = _phaseFor(actorState);
      for(final runtime in actorState.scheduleStates.values) {
        if(runtime.completed) {
          continue;
        }

        for(final point in runtime.orderedTimepoints) {
          if(point.startTime <= runtime.elapsedMs) {
            continue;
          }

          final targetTs = _elapsedMs + (point.startTime - runtime.elapsedMs);
          if(targetTs > maxFutureTs) {
            break;
          }

          markers.add(SimulationTrackMarker(
            timestampMs: targetTs,
            label:
                '${actorState.actor.name} / ${phase.name}: ${point.type.displayName}',
            type: SimulatedEventType.timepoint,
            isPast: false,
          ));
        }
      }
    }

    markers
        .sort((left, right) => left.timestampMs.compareTo(right.timestampMs));
    if(markers.length > 200) {
      return markers.take(200).toList();
    }

    return markers;
  }

  void _appendInfoEvent(String message) {
    if(_actorsById.isEmpty) {
      return;
    }

    final actorState = _actorsById.values.first;
    _appendEvent(
      actorState: actorState,
      type: SimulatedEventType.info,
      message: message,
    );
  }

  void _appendEvent({
    required _ActorRuntimeState actorState,
    required SimulatedEventType type,
    required String message,
    int? phaseId,
    String? phaseName,
    int? scheduleId,
    int? triggerId,
    int? timepointId,
    List<SimulatedEvent>? produced,
  }) {
    final resolvedPhase = _phaseFor(actorState);
    final event = SimulatedEvent(
      timestampMs: _elapsedMs,
      type: type,
      actorId: actorState.actor.id,
      actorName: actorState.actor.name,
      phaseId: phaseId ?? resolvedPhase.id,
      phaseName: phaseName ?? resolvedPhase.name,
      scheduleId: scheduleId,
      triggerId: triggerId,
      timepointId: timepointId,
      message: message,
    );

    if(produced != null) {
      produced.add(event);
    } else {
      _events.add(event);
      if(_events.length > _maxEvents) {
        _events.removeRange(0, _events.length - _maxEvents);
      }
    }
  }

  TimelinePhaseModel _phaseFor(_ActorRuntimeState actorState) {
    return _phaseById(actorState.actor, actorState.currentPhaseId) ??
        actorState.actor.phases.first;
  }

  TimelinePhaseModel? _phaseById(ActorModel actor, int? phaseId) {
    if(phaseId == null) {
      return null;
    }

    final matches = actor.phases.where((phase) => phase.id == phaseId);
    if(matches.isEmpty) {
      return null;
    }

    return matches.first;
  }

  String _triggerOverrideKey(int actorId, int phaseId, int triggerId) {
    return '$actorId:$phaseId:$triggerId';
  }

  String _keyActorName(String name) {
    return name.trim().toLowerCase();
  }

  static List<TimepointModel> _orderedTimepoints(List<TimepointModel> points) {
    return <TimepointModel>[...points]..sort((left, right) {
        final timeCompare = left.startTime.compareTo(right.startTime);
        if(timeCompare != 0) {
          return timeCompare;
        }

        return left.id.compareTo(right.id);
      });
  }

  int _applyOpcode(DirectorOpcode opcode, int current, int value) {
    switch(opcode) {
      case DirectorOpcode.set:
        return value;
      case DirectorOpcode.add:
        return current + value;
      case DirectorOpcode.sub:
        return current - value;
      case DirectorOpcode.mul:
        return current * value;
      case DirectorOpcode.div:
        return value == 0 ? current : current ~/ value;
      case DirectorOpcode.mod:
        return value == 0 ? current : current % value;
      case DirectorOpcode.or:
        return current | value;
      case DirectorOpcode.xor:
        return current ^ value;
      case DirectorOpcode.nor:
        return ~value;
      case DirectorOpcode.and:
        return current & value;
      case DirectorOpcode.sll:
        return current << value;
      case DirectorOpcode.srl:
        return current >> value;
    }
  }

  int? _readInt(Map raw, List<String> keys) {
    for(final key in keys) {
      final value = raw[key];
      if(value is int) {
        return value;
      }
      if(value is num) {
        return value.toInt();
      }
      if(value is String) {
        final parsed = int.tryParse(value);
        if(parsed != null) {
          return parsed;
        }
      }
    }

    return null;
  }

  double? _readNum(Map raw, List<String> keys) {
    for(final key in keys) {
      final value = raw[key];
      if(value is num) {
        return value.toDouble();
      }
      if(value is String) {
        final parsed = double.tryParse(value);
        if(parsed != null) {
          return parsed;
        }
      }
    }

    return null;
  }

  TimelineModel _cloneTimeline(TimelineModel timeline) {
    final encoded = jsonEncode(timeline.toJson());
    final decoded = jsonDecode(encoded);
    return TimelineModel.fromJson(decoded as Map<String, dynamic>);
  }
}

class _ScheduleRuntimeState {
  final TimelineScheduleModel schedule;
  final List<TimepointModel> orderedTimepoints;

  int elapsedMs = -1;
  int loopIteration = 1;
  bool completed = false;

  _ScheduleRuntimeState(this.schedule)
      : orderedTimepoints = SimulationRunner._orderedTimepoints(
          schedule.timepoints,
        );

  int get loopEndMs {
    if(orderedTimepoints.isEmpty) {
      return 0;
    }

    return orderedTimepoints.last.startTime;
  }
}

class _ActorRuntimeState {
  final ActorModel actor;

  double hpPct;
  ActorCombatState combatState;
  int currentPhaseId;
  int phaseElapsedMs;

  int? lastActionId;
  int? lastInterruptedActionId;

  final Map<VarType, Map<int, int>> varStore;
  final Set<int> firedTriggerIds;
  final Map<int, _ScheduleRuntimeState> scheduleStates;

  _ActorRuntimeState({
    required this.actor,
    required this.currentPhaseId,
  })  : hpPct = 100,
        combatState = ActorCombatState.idle,
        phaseElapsedMs = 0,
        varStore = <VarType, Map<int, int>>{
          VarType.director: <int, int>{},
          VarType.custom: <int, int>{},
          VarType.pack: <int, int>{},
        },
        firedTriggerIds = <int>{},
        scheduleStates = <int, _ScheduleRuntimeState>{};
}

class _TriggerActionResult {
  final bool didTransition;

  const _TriggerActionResult({required this.didTransition});
}
