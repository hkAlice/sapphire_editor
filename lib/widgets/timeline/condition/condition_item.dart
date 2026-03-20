import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/condition/trigger_model.dart';
import 'package:sapphire_editor/models/timeline/condition/trigger_action_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';
import 'package:sapphire_editor/models/timeline/timeline_phase_model.dart';
import 'package:sapphire_editor/utils/text_utils.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/number_button.dart';
import 'package:sapphire_editor/widgets/text_modal_editor_widget.dart';
import 'package:sapphire_editor/widgets/timeline/condition/condition_editor_registry.dart';
import 'package:sapphire_editor/widgets/timeline/condition/condition_editor_scope.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/timepoint_editor_registry.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/timepoint_editor_scope.dart';
import 'package:sapphire_editor/widgets/timeline/timeline_lookup.dart';
import 'package:signals/signals_flutter.dart';

class ConditionItem extends StatefulWidget {
  final int conditionId;
  final int index;
  final TimelineEditorSignal signals;

  const ConditionItem(
      {super.key,
      required this.conditionId,
      required this.index,
      required this.signals});

  @override
  State<ConditionItem> createState() => _ConditionItemState();
}

class _ConditionItemState extends State<ConditionItem> {
  int? _defaultTransitionPhaseForPhase(
      int phaseId, List<TimelinePhaseModel> phases) {
    final currentIndex = phases.indexWhere((phase) => phase.id == phaseId);
    if(currentIndex != -1 && currentIndex + 1 < phases.length) {
      return phases[currentIndex + 1].id;
    }

    if(phases.isNotEmpty) {
      return phases.first.id;
    }

    return null;
  }

  TimepointModel _defaultTriggerTimepoint() {
    return TimepointModel(
      id: 1,
      type: TimepointType.idle,
      description: "Triggered timepoint",
      startTime: 0,
    );
  }

  String _timepointSummary(TimepointModel model) {
    final seconds = (model.startTime / 1000).toStringAsFixed(1);
    return "${seconds}s • ${treatEnumName(model.type)} • ${model.data}";
  }

  @override
  Widget build(BuildContext context) {
    final signals = widget.signals;

    return Watch((context) {
      final actor = signals.selectedActor.value;
      final phase = signals.selectedPhase.value;
      final conditionModel =
          TimelineNodeLookup.findConditionInPhase(phase, widget.conditionId);
      if(conditionModel == null) {
        return const SizedBox.shrink();
      }

      final phaseTargets = actor.phases;
      final defaultTransitionPhaseId =
          _defaultTransitionPhaseForPhase(phase.id, phaseTargets);
      final actionModel = conditionModel.action ??
          TriggerActionModel(
              type: "transitionPhase", phaseId: defaultTransitionPhaseId);
      final actionTargetItems = phaseTargets.map((p) => p.id).toList();
      final actionTimepoint =
          actionModel.timepoint ?? _defaultTriggerTimepoint();
      final triggerActionScheduleId =
          TimelineNodeLookup.triggerActionScheduleIdForCondition(
              widget.conditionId);

      return Card(
        borderOnForeground: false,
        elevation: 1.0,
        margin: const EdgeInsets.only(bottom: 8.0),
        child: ExpansionTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ReorderableDragStartListener(
                  index: widget.index,
                  child: Text(
                    widget.index.toString().padLeft(2, "0"),
                    style: Theme.of(context).textTheme.displaySmall!.apply(
                        fontSizeFactor: 0.70,
                        color: Theme.of(context).primaryColor),
                  )),
              const VerticalDivider(),
            ],
          ),
          title: Text(conditionModel.getReadableConditionStr(actor)),
          subtitle: conditionModel.description?.isNotEmpty ?? false
              ? Text(conditionModel.description!)
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () {
                  signals.removeCondition(
                      actor.id, phase.id, widget.conditionId);
                },
              ),
            ],
          ),
          children: [
            Container(
              color: Colors.black26,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 220,
                          child: GenericItemPickerWidget<ConditionType>(
                            label: "Condition",
                            items: ConditionType.values,
                            initialValue: conditionModel.condition,
                            propertyBuilder: (value) {
                              return treatEnumName(value);
                            },
                            onChanged: (newValue) {
                              conditionModel.changeType(newValue!);
                              final updatedCondition = conditionModel.action ==
                                      null
                                  ? conditionModel.copyWith(
                                      action: TriggerActionModel(
                                          type: "transitionPhase",
                                          phaseId: defaultTransitionPhaseId),
                                    )
                                  : conditionModel;

                              signals.updateCondition(actor.id, phase.id,
                                  widget.conditionId, updatedCondition);
                            },
                          ),
                        ),
                        const SizedBox(width: 18.0),
                        SizedBox(
                          width: 220,
                          child: GenericItemPickerWidget<String>(
                            label: "Action",
                            items: const ["transitionPhase", "timepoint"],
                            initialValue: actionModel.type,
                            propertyBuilder: (value) => value,
                            onChanged: (newValue) {
                              if(newValue == null) {
                                return;
                              }

                              final updatedAction = newValue == "timepoint"
                                  ? TriggerActionModel(
                                      type: newValue,
                                      timepoint: actionModel.timepoint ??
                                          _defaultTriggerTimepoint(),
                                    )
                                  : TriggerActionModel(
                                      type: newValue,
                                      phaseId: actionModel.phaseId ??
                                          defaultTransitionPhaseId,
                                      timepoint: null,
                                    );

                              signals.updateCondition(
                                actor.id,
                                phase.id,
                                widget.conditionId,
                                conditionModel.copyWith(action: updatedAction),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 18.0),
                        if(actionModel.type == "transitionPhase")
                          SizedBox(
                            width: 260,
                            child: GenericItemPickerWidget<int>(
                              label: "Target Phase",
                              items: actionTargetItems,
                              initialValue: actionTargetItems
                                      .contains(actionModel.phaseId)
                                  ? actionModel.phaseId
                                  : defaultTransitionPhaseId,
                              propertyBuilder: (value) {
                                final targetPhase =
                                    phaseTargets.firstWhereOrNull((phaseItem) =>
                                            phaseItem.id == value) ??
                                        phase;
                                return targetPhase.name;
                              },
                              onChanged: (newValue) {
                                signals.updateCondition(
                                  actor.id,
                                  phase.id,
                                  widget.conditionId,
                                  conditionModel.copyWith(
                                    action: TriggerActionModel(
                                      type: actionModel.type,
                                      phaseId: newValue,
                                      timepoint: null,
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        else
                          SizedBox(
                            width: 260,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                filled: false,
                                labelText: "Timepoint Summary",
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.all(10.5),
                              ),
                              child: Text(
                                _timepointSummary(actionTimepoint),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                      color: Colors.black12,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ConditionEditorScope(
                          signals: signals,
                          actorId: actor.id,
                          phaseId: phase.id,
                          conditionId: widget.conditionId,
                          child: ConditionEditorRegistry.buildEditor(
                            ConditionEditorContext(
                              conditionModel: conditionModel,
                            ),
                          ),
                        ),
                      )),
                  if(actionModel.type == "timepoint")
                    Container(
                      color: Colors.black12,
                      margin: const EdgeInsets.only(top: 8.0),
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NumberButton(
                            min: 0,
                            max: 60000,
                            value: actionTimepoint.startTime,
                            label: "Start time",
                            builder: (value) {
                              var seconds = value / 1000;
                              return "${seconds.toStringAsFixed(1)}s";
                            },
                            stepCount: 100,
                            onChanged: (value) {
                              final newTimepoint =
                                  actionTimepoint.copyWith(startTime: value);
                              signals.updateCondition(
                                actor.id,
                                phase.id,
                                widget.conditionId,
                                conditionModel.copyWith(
                                  action: actionModel.copyWith(
                                      timepoint: newTimepoint),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 18.0),
                          SizedBox(
                            width: 220,
                            child: DropdownButtonFormField<TimepointType>(
                                decoration: const InputDecoration(
                                    filled: false,
                                    labelText: "Point type",
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.all(10.5)),
                                initialValue: actionTimepoint.type,
                                isDense: true,
                                onChanged: (TimepointType? value) {
                                  if(value == null) {
                                    return;
                                  }

                                  final newTimepoint =
                                      actionTimepoint.copyWith();
                                  newTimepoint.changeType(value);
                                  signals.updateCondition(
                                    actor.id,
                                    phase.id,
                                    widget.conditionId,
                                    conditionModel.copyWith(
                                      action: actionModel.copyWith(
                                        timepoint: newTimepoint,
                                      ),
                                    ),
                                  );
                                },
                                items: TimepointType.values
                                    .map((TimepointType type) {
                                  return DropdownMenuItem<TimepointType>(
                                      value: type,
                                      child: Text(treatEnumName(type)));
                                }).toList()),
                          ),
                          const SizedBox(width: 18.0),
                          Expanded(
                            child: SizedBox(
                                height: 54.0,
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      actionTimepoint.description,
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.fade,
                                    ))),
                          ),
                          SizedBox(
                            height: 54.0,
                            child: TextModalEditorWidget(
                                text: actionTimepoint.description,
                                headerText:
                                    "Edit trigger timepoint description",
                                onChanged: (description) {
                                  final newTimepoint = actionTimepoint.copyWith(
                                      description: description);
                                  signals.updateCondition(
                                    actor.id,
                                    phase.id,
                                    widget.conditionId,
                                    conditionModel.copyWith(
                                      action: actionModel.copyWith(
                                        timepoint: newTimepoint,
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        ],
                      ),
                    ),
                  if(actionModel.type == "timepoint")
                    Container(
                      color: Colors.black12,
                      padding: actionTimepoint.type == TimepointType.idle
                          ? null
                          : const EdgeInsets.all(8.0),
                      child: TimepointEditorScope(
                        signals: signals,
                        actorId: actor.id,
                        phaseId: phase.id,
                        scheduleId: triggerActionScheduleId,
                        timepointId: actionTimepoint.id,
                        child: KeyedSubtree(
                          key: ValueKey(
                              '${widget.conditionId}-${actionTimepoint.type.name}'),
                          child: TimepointEditorRegistry.buildEditor(
                            TimepointEditorContext(
                              timepointModel: actionTimepoint,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
      );
    });
  }
}
