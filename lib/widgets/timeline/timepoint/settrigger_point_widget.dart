import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/condition/trigger_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/settrigger_point_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_phase_model.dart';
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
  late SetTriggerPointModel pointData =
      widget.timepointModel.data as SetTriggerPointModel;

  void _normalizePointData(
      TimelineEditorSignal signals, ActorModel fallbackActor) {
    final targetActor =
        TimelineNodeLookup.findActorByName(signals, pointData.targetActor) ??
            fallbackActor;
    pointData.targetActor = targetActor.name;

    final targetPhase = TimelineNodeLookup.resolveSetTriggerTargetPhase(
      targetActor,
      pointData.targetPhaseId,
      pointData.triggerId,
    );
    if(targetPhase == null) {
      return;
    }

    final phaseNumber = TimelineNodeLookup.phaseNumberForActorPhase(
      targetActor,
      targetPhase,
    );
    if(phaseNumber > 0) {
      pointData.targetPhaseId = phaseNumber;
    }

    final targetTrigger = targetPhase.triggers.firstWhereOrNull(
          (trigger) => trigger.id == pointData.triggerId,
        ) ??
        targetPhase.triggers.firstWhereOrNull((_) => true);

    if(targetTrigger != null) {
      pointData.triggerId = targetTrigger.id;
      pointData.triggerStr = targetTrigger.getReadableConditionStr();
    }
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

      final targetActor =
          TimelineNodeLookup.findActorByName(signals, pointData.targetActor) ??
              actor;
      final targetPhase = TimelineNodeLookup.resolveSetTriggerTargetPhase(
        targetActor,
        pointData.targetPhaseId,
        pointData.triggerId,
      );
      final targetTrigger = TimelineNodeLookup.resolveSetTriggerTarget(
        targetActor,
        pointData.targetPhaseId,
        pointData.triggerId,
      );

      final phaseTriggers = targetPhase?.triggers ?? const <TriggerModel>[];
      final targetPhases = targetActor.phases;

      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 220,
                child: GenericItemPickerWidget<ActorModel>(
                  label: "Target Actor",
                  items: timeline.actors,
                  initialValue: timeline.actors
                      .firstWhereOrNull((entry) => entry.id == targetActor.id),
                  onChanged: (newValue) {
                    pointData.targetActor = newValue.name;
                    final newPhase =
                        newValue.phases.firstWhereOrNull((_) => true);
                    if(newPhase != null) {
                      pointData.targetPhaseId =
                          TimelineNodeLookup.phaseNumberForActorPhase(
                              newValue, newPhase);

                      final firstTrigger =
                          newPhase.triggers.firstWhereOrNull((_) => true);
                      if(firstTrigger != null) {
                        pointData.triggerId = firstTrigger.id;
                        pointData.triggerStr =
                            firstTrigger.getReadableConditionStr();
                      }
                    }

                    _updateTimepoint(signals, actor, schedule);
                  },
                ),
              ),
              const SizedBox(
                width: 18.0,
              ),
              SizedBox(
                width: 260,
                child: GenericItemPickerWidget<TimelinePhaseModel>(
                  label: "Target Phase",
                  items: targetPhases,
                  enabled: targetPhases.isNotEmpty,
                  initialValue: targetPhase,
                  propertyBuilder: (phase) {
                    final phaseNumber =
                        TimelineNodeLookup.phaseNumberForActorPhase(
                      targetActor,
                      phase,
                    );
                    if(phaseNumber > 0) {
                      return "[$phaseNumber] ${phase.name}";
                    }

                    return phase.name;
                  },
                  onChanged: (newValue) {
                    pointData.targetActor = targetActor.name;
                    pointData.targetPhaseId =
                        TimelineNodeLookup.phaseNumberForActorPhase(
                      targetActor,
                      newValue,
                    );

                    final phaseTrigger = newValue.triggers.firstWhereOrNull(
                          (trigger) => trigger.id == pointData.triggerId,
                        ) ??
                        newValue.triggers.firstWhereOrNull((_) => true);

                    if(phaseTrigger != null) {
                      pointData.triggerId = phaseTrigger.id;
                      pointData.triggerStr =
                          phaseTrigger.getReadableConditionStr();
                    }

                    _updateTimepoint(signals, actor, schedule);
                  },
                ),
              ),
              const SizedBox(
                width: 18.0,
              ),
              SwitchTextWidget(
                  enabled: pointData.enabled,
                  onPressed: () {
                    pointData.enabled = !pointData.enabled;
                    _updateTimepoint(signals, actor, schedule);
                  })
            ],
          ),
          const SizedBox(
            height: 18.0,
          ),
          Row(
            children: [
              SizedBox(
                width: 500,
                child: GenericItemPickerWidget<TriggerModel>(
                  label: "Trigger",
                  items: phaseTriggers,
                  enabled: phaseTriggers.isNotEmpty,
                  initialValue: targetTrigger ??
                      phaseTriggers.firstWhereOrNull((_) => true),
                  propertyBuilder: (value) {
                    return "(ID: ${value.id}) ${value.getReadableConditionStr()}";
                  },
                  onChanged: (newValue) {
                    pointData.targetActor = targetActor.name;
                    if(targetPhase != null) {
                      pointData.targetPhaseId =
                          TimelineNodeLookup.phaseNumberForActorPhase(
                        targetActor,
                        targetPhase,
                      );
                    }

                    pointData.triggerId = newValue.id;
                    pointData.triggerStr = newValue.getReadableConditionStr();
                    _updateTimepoint(signals, actor, schedule);
                  },
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  void _updateTimepoint(TimelineEditorSignal signals, ActorModel actor,
      TimelineScheduleModel schedule) {
    _normalizePointData(signals, actor);

    final oldTimepoint = TimelineNodeLookup.findTimepointInSchedule(
        schedule, widget.timepointModel.id);
    if(oldTimepoint == null) {
      return;
    }

    final newTimepoint = TimepointModel(
      id: oldTimepoint.id,
      type: oldTimepoint.type,
      startTime: oldTimepoint.startTime,
      data: pointData,
    );
    signals.updateTimepoint(
        actor.id, schedule.id, oldTimepoint.id, newTimepoint);
  }
}
