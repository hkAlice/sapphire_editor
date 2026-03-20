import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/condition/trigger_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/settrigger_point_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_schedule_model.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/switch_text_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/timepoint_editor_scope.dart';
import 'package:sapphire_editor/widgets/timeline/timeline_lookup.dart';
import 'package:signals/signals_flutter.dart';

class SetTriggerPointWidget extends StatefulWidget {
  final TimepointModel timepointModel;

  const SetTriggerPointWidget({super.key, required this.timepointModel});

  @override
  State<SetTriggerPointWidget> createState() => _SetTriggerPointWidgetState();
}

class _SetTriggerPointWidgetState extends State<SetTriggerPointWidget> {
  SetTriggerPointModel _clonePointData([SetTriggerPointModel? source]) {
    final model = source ?? widget.timepointModel.data as SetTriggerPointModel;
    return SetTriggerPointModel.fromJson(model.toJson());
  }

  SetTriggerPointModel _normalizePointData(
    TimelineEditorSignal signals,
    SetTriggerPointModel source,
    ActorModel fallbackActor,
  ) {
    final normalized = _clonePointData(source);

    final targetActor =
        TimelineNodeLookup.findActorByName(signals, normalized.targetActor) ??
            fallbackActor;
    normalized.targetActor = targetActor.name;

    final targetPhase = TimelineNodeLookup.resolveSetTriggerTargetPhase(
      targetActor,
      normalized.targetPhaseId,
      normalized.triggerId,
    );
    if(targetPhase == null) {
      normalized.targetPhaseId = 0;
      normalized.triggerId = 0;
      normalized.triggerStr = '<unknown>';
      return normalized;
    }

    final phaseNumber = TimelineNodeLookup.phaseNumberForActorPhase(
      targetActor,
      targetPhase,
    );
    normalized.targetPhaseId = phaseNumber > 0 ? phaseNumber : 0;

    final targetTrigger = targetPhase.triggers.firstWhereOrNull(
          (trigger) => trigger.id == normalized.triggerId,
        ) ??
        targetPhase.triggers.firstWhereOrNull((_) => true);

    if(targetTrigger == null) {
      normalized.triggerId = 0;
      normalized.triggerStr = '<unknown>';
      return normalized;
    }

    normalized.triggerId = targetTrigger.id;
    normalized.triggerStr = targetTrigger.getReadableConditionStr(targetActor);
    return normalized;
  }

  String _phaseLabel(ActorModel targetActor, int phaseNumber) {
    final phase =
        TimelineNodeLookup.findPhaseByTargetPhaseId(targetActor, phaseNumber);
    if(phase == null) {
      return 'Phase $phaseNumber';
    }

    return '[$phaseNumber] ${phase.name}';
  }

  String _triggerLabel(
    List<TriggerModel> triggers,
    int triggerId,
    ActorModel targetActor,
  ) {
    final trigger = triggers.firstWhereOrNull((entry) => entry.id == triggerId);
    if(trigger == null) {
      return 'Trigger #$triggerId';
    }

    return '(ID: ${trigger.id}) ${trigger.getReadableConditionStr(targetActor)}';
  }

  void _updateTimepoint(
    TimelineEditorSignal signals,
    ActorModel actor,
    TimelineScheduleModel schedule,
    SetTriggerPointModel nextData,
  ) {
    final normalizedData = _normalizePointData(signals, nextData, actor);

    final oldTimepoint = TimelineNodeLookup.findTimepointInSchedule(
      schedule,
      widget.timepointModel.id,
    );
    if(oldTimepoint == null) {
      return;
    }

    final newTimepoint = oldTimepoint.copyWith(data: normalizedData);
    signals.updateTimepoint(
        actor.id, schedule.id, oldTimepoint.id, newTimepoint);
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final scope = TimepointEditorScope.of(context);
      final signals = scope.signals;
      final lookup = TimelineNodeLookup.findActorSchedule(
          signals, scope.actorId, scope.scheduleId, scope.phaseId);
      if(lookup == null) {
        return const SizedBox.shrink();
      }

      final actor = lookup.actor;
      final schedule = lookup.schedule;
      final timeline = signals.timeline.value;
      final pointData = _normalizePointData(signals, _clonePointData(), actor);

      final actorNames = timeline.actors.map((entry) => entry.name).toList();
      final selectedActorName = actorNames.contains(pointData.targetActor)
          ? pointData.targetActor
          : actor.name;

      final targetActor =
          TimelineNodeLookup.findActorByName(signals, selectedActorName) ??
              actor;
      final targetPhase = TimelineNodeLookup.resolveSetTriggerTargetPhase(
        targetActor,
        pointData.targetPhaseId,
        pointData.triggerId,
      );
      final selectedPhaseNumber = targetPhase == null
          ? null
          : TimelineNodeLookup.phaseNumberForActorPhase(
              targetActor, targetPhase);

      final phaseTriggers = targetPhase?.triggers ?? const <TriggerModel>[];
      final phaseNumbers = targetActor.phases
          .map((phase) =>
              TimelineNodeLookup.phaseNumberForActorPhase(targetActor, phase))
          .where((phaseNumber) => phaseNumber > 0)
          .toList();

      final selectedPhase = selectedPhaseNumber != null &&
              phaseNumbers.contains(selectedPhaseNumber)
          ? selectedPhaseNumber
          : phaseNumbers.firstWhereOrNull((_) => true);

      final triggerIds = phaseTriggers.map((trigger) => trigger.id).toList();
      final selectedTriggerId = triggerIds.contains(pointData.triggerId)
          ? pointData.triggerId
          : triggerIds.firstWhereOrNull((_) => true);

      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 220,
                child: SizedBox(
                  width: 180,
                  child: GenericItemPickerWidget<String>(
                    key: ValueKey(
                      'settrigger-actor-${widget.timepointModel.id}-$selectedActorName-${actorNames.length}',
                    ),
                    label: "Target Actor",
                    items: actorNames,
                    initialValue: actorNames.contains(selectedActorName)
                        ? selectedActorName
                        : actorNames.firstWhereOrNull((_) => true),
                    onChanged: (newValue) {
                      final actorName = newValue as String;
                      final nextData = _clonePointData(pointData);
                      nextData.targetActor = actorName;

                      final newActor = TimelineNodeLookup.findActorByName(
                              signals, actorName) ??
                          actor;
                      final newPhase =
                          newActor.phases.firstWhereOrNull((_) => true);
                      if(newPhase == null) {
                        nextData.targetPhaseId = 0;
                        nextData.triggerId = 0;
                        nextData.triggerStr = '<unknown>';
                      } else {
                        nextData.targetPhaseId =
                            TimelineNodeLookup.phaseNumberForActorPhase(
                                newActor, newPhase);

                        final firstTrigger =
                            newPhase.triggers.firstWhereOrNull((_) => true);
                        if(firstTrigger == null) {
                          nextData.triggerId = 0;
                          nextData.triggerStr = '<unknown>';
                        } else {
                          nextData.triggerId = firstTrigger.id;
                          nextData.triggerStr =
                              firstTrigger.getReadableConditionStr(newActor);
                        }
                      }

                      _updateTimepoint(signals, actor, schedule, nextData);
                    },
                  ),
                ),
              ),
              const SizedBox(
                width: 18.0,
              ),
              SizedBox(
                width: 260,
                child: GenericItemPickerWidget<int>(
                  key: ValueKey(
                    'settrigger-phase-${widget.timepointModel.id}-${targetActor.name}-${selectedPhase ?? 0}-${phaseNumbers.length}',
                  ),
                  label: "Target Phase",
                  items: phaseNumbers,
                  enabled: phaseNumbers.isNotEmpty,
                  initialValue: selectedPhase,
                  propertyBuilder: (phaseNumber) {
                    return _phaseLabel(targetActor, phaseNumber);
                  },
                  onChanged: (newValue) {
                    final phaseNumber = newValue as int;
                    final nextData = _clonePointData(pointData);
                    nextData.targetActor = targetActor.name;
                    nextData.targetPhaseId = phaseNumber;

                    final newPhase =
                        TimelineNodeLookup.findPhaseByTargetPhaseId(
                      targetActor,
                      phaseNumber,
                    );
                    final phaseTrigger = newPhase?.triggers.firstWhereOrNull(
                          (trigger) => trigger.id == nextData.triggerId,
                        ) ??
                        newPhase?.triggers.firstWhereOrNull((_) => true);

                    if(phaseTrigger == null) {
                      nextData.triggerId = 0;
                      nextData.triggerStr = '<unknown>';
                    } else {
                      nextData.triggerId = phaseTrigger.id;
                      nextData.triggerStr =
                          phaseTrigger.getReadableConditionStr(targetActor);
                    }

                    _updateTimepoint(signals, actor, schedule, nextData);
                  },
                ),
              ),
              const SizedBox(
                width: 18.0,
              ),
              SwitchTextWidget(
                  enabled: pointData.enabled,
                  toggleText: ("ENABLED", "DISABLED"),
                  leading: Icon(Icons.flag),
                  onPressed: () {
                    final nextData = _clonePointData(pointData);
                    nextData.enabled = !pointData.enabled;
                    _updateTimepoint(signals, actor, schedule, nextData);
                  })
            ],
          ),
          const SizedBox(
            height: 18.0,
          ),
          Row(
            children: [
              Expanded(
                child: GenericItemPickerWidget<int>(
                  key: ValueKey(
                    'settrigger-trigger-${widget.timepointModel.id}-${targetActor.name}-${selectedPhase ?? 0}-${selectedTriggerId ?? 0}-${triggerIds.length}',
                  ),
                  label: "Trigger",
                  items: triggerIds,
                  enabled: triggerIds.isNotEmpty,
                  initialValue: selectedTriggerId,
                  propertyBuilder: (triggerId) {
                    return _triggerLabel(phaseTriggers, triggerId, targetActor);
                  },
                  onChanged: (newValue) {
                    final triggerId = newValue as int;
                    final nextData = _clonePointData(pointData);
                    nextData.targetActor = targetActor.name;
                    if(selectedPhase != null) {
                      nextData.targetPhaseId = selectedPhase;
                    }

                    nextData.triggerId = triggerId;
                    final trigger = phaseTriggers
                        .firstWhereOrNull((entry) => entry.id == triggerId);
                    if(trigger != null) {
                      nextData.triggerStr =
                          trigger.getReadableConditionStr(targetActor);
                    }

                    _updateTimepoint(signals, actor, schedule, nextData);
                  },
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}
