import 'package:collection/collection.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/condition/trigger_model.dart';
import 'package:sapphire_editor/models/timeline/phase_timepoint_hook.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_phase_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_schedule_model.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';

class ActorScheduleLookup {
  final ActorModel actor;
  final TimelineScheduleModel schedule;

  const ActorScheduleLookup({required this.actor, required this.schedule});
}

class TimepointLookup {
  final ActorModel actor;
  final TimelineScheduleModel schedule;
  final TimepointModel timepoint;

  const TimepointLookup({
    required this.actor,
    required this.schedule,
    required this.timepoint,
  });
}

class TimelineNodeLookup {
  static const int _triggerActionScheduleOffset = 1000000;

  static int get onEnterScheduleId => PhaseHookScheduleIds.onEnter;
  static int get onExitScheduleId => PhaseHookScheduleIds.onExit;

  static int triggerActionScheduleIdForCondition(int conditionId) {
    return -(_triggerActionScheduleOffset + conditionId);
  }

  static bool isTriggerActionScheduleId(int scheduleId) {
    return scheduleId <= -_triggerActionScheduleOffset;
  }

  static bool isPhaseHookScheduleId(int scheduleId) {
    return PhaseHookScheduleIds.isPhaseHookScheduleId(scheduleId);
  }

  static PhaseTimepointHook? hookFromScheduleId(int? scheduleId) {
    return PhaseHookScheduleIds.hookFromScheduleId(scheduleId);
  }

  static int? conditionIdFromTriggerActionScheduleId(int scheduleId) {
    if(!isTriggerActionScheduleId(scheduleId)) {
      return null;
    }

    return -scheduleId - _triggerActionScheduleOffset;
  }

  static ActorModel? findActor(TimelineEditorSignal signals, int? actorId) {
    if(actorId == null) {
      return null;
    }

    return signals.timeline.value.actors
        .firstWhereOrNull((a) => a.id == actorId);
  }

  static ActorModel? findActorByName(
    TimelineEditorSignal signals,
    String? actorName,
  ) {
    if(actorName == null || actorName.trim().isEmpty) {
      return null;
    }

    return signals.timeline.value.actors
        .firstWhereOrNull((a) => a.name == actorName);
  }

  static int phaseNumberForActorPhase(
    ActorModel actor,
    TimelinePhaseModel phase,
  ) {
    final match = RegExp(r'(\d+)$').firstMatch(phase.id);
    final parsed = match == null ? null : int.tryParse(match.group(1)!);
    if(parsed != null && parsed > 0) {
      return parsed;
    }

    final index = actor.phases.indexWhere((entry) => entry.id == phase.id);
    return index >= 0 ? index + 1 : 0;
  }

  static TimelinePhaseModel? findPhaseByTargetPhaseId(
    ActorModel actor,
    int targetPhaseId,
  ) {
    if(targetPhaseId <= 0) {
      return null;
    }

    return actor.phases.firstWhereOrNull(
      (phase) => phaseNumberForActorPhase(actor, phase) == targetPhaseId,
    );
  }

  static TimelinePhaseModel? resolveSetTriggerTargetPhase(
    ActorModel actor,
    int targetPhaseId,
    int triggerId,
  ) {
    final explicitPhase = findPhaseByTargetPhaseId(actor, targetPhaseId);
    if(explicitPhase != null) {
      return explicitPhase;
    }

    if(triggerId > 0) {
      final inferredPhase = actor.phases.firstWhereOrNull(
        (phase) => phase.triggers.any((trigger) => trigger.id == triggerId),
      );
      if(inferredPhase != null) {
        return inferredPhase;
      }
    }

    return actor.phases.firstWhereOrNull((_) => true);
  }

  static TriggerModel? resolveSetTriggerTarget(
    ActorModel actor,
    int targetPhaseId,
    int triggerId,
  ) {
    final phase = resolveSetTriggerTargetPhase(
      actor,
      targetPhaseId,
      triggerId,
    );
    if(phase == null) {
      return null;
    }

    return phase.triggers
        .firstWhereOrNull((trigger) => trigger.id == triggerId);
  }

  static TimelinePhaseModel? findPhase(
    TimelineEditorSignal signals,
    int? actorId,
    String? phaseId,
  ) {
    if(phaseId == null) {
      return null;
    }

    final actor = findActor(signals, actorId);
    if(actor == null) {
      return null;
    }

    return actor.phases.firstWhereOrNull((p) => p.id == phaseId);
  }

  static ActorScheduleLookup? findActorSchedule(
      TimelineEditorSignal signals, int? actorId, int? scheduleId,
      [String? phaseId]) {
    if(scheduleId == null) {
      return null;
    }

    final actor = findActor(signals, actorId);
    if(actor == null) {
      return null;
    }

    if(isTriggerActionScheduleId(scheduleId)) {
      final conditionId = conditionIdFromTriggerActionScheduleId(scheduleId);
      if(conditionId == null) {
        return null;
      }

      TimelinePhaseModel? phase;
      if(phaseId != null) {
        phase = actor.phases.firstWhereOrNull((p) => p.id == phaseId);
      }

      final selectedPhaseId = signals.selectedPhaseId.value;
      if(phase == null && selectedPhaseId != null) {
        phase = actor.phases.firstWhereOrNull((p) => p.id == selectedPhaseId);
      }

      phase ??= actor.phases.firstWhereOrNull((_) => true);
      if(phase == null) {
        return null;
      }

      final condition =
          phase.triggers.firstWhereOrNull((c) => c.id == conditionId);
      final triggerTimepoint = condition?.action?.timepoint;
      if(triggerTimepoint == null) {
        return null;
      }

      final triggerActionSchedule = TimelineScheduleModel(
        id: scheduleId,
        name: 'Trigger Action',
        timepointList: [triggerTimepoint],
      );

      return ActorScheduleLookup(actor: actor, schedule: triggerActionSchedule);
    }

    if(isPhaseHookScheduleId(scheduleId)) {
      TimelinePhaseModel? phase;
      if(phaseId != null) {
        phase = actor.phases.firstWhereOrNull((p) => p.id == phaseId);
      }

      final selectedPhaseId = signals.selectedPhaseId.value;
      if(phase == null && selectedPhaseId != null) {
        phase = actor.phases.firstWhereOrNull((p) => p.id == selectedPhaseId);
      }

      phase ??= actor.phases.firstWhereOrNull((_) => true);
      if(phase == null) {
        return null;
      }

      final hook = hookFromScheduleId(scheduleId);
      if(hook == null) {
        return null;
      }

      final hookSchedule = TimelineScheduleModel(
        id: scheduleId,
        name: hook == PhaseTimepointHook.onEnter ? 'On Enter' : 'On Exit',
        timepointList:
            hook == PhaseTimepointHook.onEnter ? phase.onEnter : phase.onExit,
      );

      return ActorScheduleLookup(actor: actor, schedule: hookSchedule);
    }

    final schedule =
        actor.schedules.firstWhereOrNull((s) => s.id == scheduleId);
    if(schedule == null) {
      return null;
    }

    return ActorScheduleLookup(actor: actor, schedule: schedule);
  }

  static TimepointModel? findTimepointInSchedule(
      TimelineScheduleModel schedule, int timepointId) {
    return schedule.timepoints.firstWhereOrNull((t) => t.id == timepointId);
  }

  static TimepointModel? findOnEnterTimepoint(
    TimelineEditorSignal signals,
    int? actorId,
    String? phaseId,
    int timepointId,
  ) {
    return findPhaseHookTimepoint(
      signals,
      actorId,
      phaseId,
      onEnterScheduleId,
      timepointId,
    );
  }

  static TimepointModel? findPhaseHookTimepoint(
    TimelineEditorSignal signals,
    int? actorId,
    String? phaseId,
    int scheduleId,
    int timepointId,
  ) {
    final phase = findPhase(signals, actorId, phaseId);
    if(phase == null) {
      return null;
    }

    final hook = hookFromScheduleId(scheduleId);
    if(hook == null) {
      return null;
    }

    final hookTimepoints =
        hook == PhaseTimepointHook.onEnter ? phase.onEnter : phase.onExit;
    return hookTimepoints.firstWhereOrNull((t) => t.id == timepointId);
  }

  static TimepointLookup? resolveTimepoint(
    TimelineEditorSignal signals,
    int? actorId,
    int? scheduleId,
    int timepointId,
  ) {
    final actorSchedule = findActorSchedule(signals, actorId, scheduleId);
    if(actorSchedule == null) {
      return null;
    }

    final timepoint =
        findTimepointInSchedule(actorSchedule.schedule, timepointId);
    if(timepoint == null) {
      return null;
    }

    return TimepointLookup(
      actor: actorSchedule.actor,
      schedule: actorSchedule.schedule,
      timepoint: timepoint,
    );
  }

  static TriggerModel? findConditionInPhase(
      TimelinePhaseModel phase, int conditionId) {
    return phase.triggers.firstWhereOrNull((c) => c.id == conditionId);
  }

  static TriggerModel? findConditionInSelectedPhase(
      TimelineEditorSignal signals, int conditionId) {
    return signals.selectedPhase.value.triggers
        .firstWhereOrNull((c) => c.id == conditionId);
  }

  static TriggerModel? findCondition(
    TimelineEditorSignal signals,
    int? actorId,
    String? phaseId,
    int conditionId,
  ) {
    if(phaseId == null) {
      return null;
    }

    final actor = findActor(signals, actorId);
    if(actor == null) {
      return null;
    }

    final phase = actor.phases.firstWhereOrNull((p) => p.id == phaseId);
    if(phase == null) {
      return null;
    }

    return findConditionInPhase(phase, conditionId);
  }
}
