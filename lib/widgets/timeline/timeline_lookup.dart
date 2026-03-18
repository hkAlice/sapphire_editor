import 'package:collection/collection.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/condition/trigger_model.dart';
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
  static ActorModel? findActor(TimelineEditorSignal signals, int? actorId) {
    if(actorId == null) {
      return null;
    }

    return signals.timeline.value.actors.firstWhereOrNull((a) => a.id == actorId);
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
    TimelineEditorSignal signals,
    int? actorId,
    int? scheduleId,
    [String? phaseId]
  ) {
    if(scheduleId == null) {
      return null;
    }

    final actor = findActor(signals, actorId);
    if(actor == null) {
      return null;
    }

    if(scheduleId < 0) {
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

      final onEnterSchedule = TimelineScheduleModel(
        id: scheduleId,
        name: 'On Enter',
        timepointList: phase.onEnter,
      );

      return ActorScheduleLookup(actor: actor, schedule: onEnterSchedule);
    }

    final schedule = actor.schedules.firstWhereOrNull((s) => s.id == scheduleId);
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
    final phase = findPhase(signals, actorId, phaseId);
    if(phase == null) {
      return null;
    }

    return phase.onEnter.firstWhereOrNull((t) => t.id == timepointId);
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

    final timepoint = findTimepointInSchedule(actorSchedule.schedule, timepointId);
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