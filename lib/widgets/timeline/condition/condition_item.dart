import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/condition/trigger_model.dart';
import 'package:sapphire_editor/models/timeline/condition/trigger_action_model.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';
import 'package:sapphire_editor/models/timeline/timeline_phase_model.dart';
import 'package:sapphire_editor/utils/text_utils.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/timeline/condition/condition_editor_registry.dart';
import 'package:sapphire_editor/widgets/timeline/condition/condition_editor_scope.dart';
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
  String _defaultActionTargetForPhase(
      String phaseId, List<TimelinePhaseModel> phases) {
    final currentIndex = phases.indexWhere((phase) => phase.id == phaseId);
    if(currentIndex != -1 && currentIndex + 1 < phases.length) {
      return phases[currentIndex + 1].id;
    }

    if(phases.isNotEmpty) {
      return phases.first.id;
    }

    return "";
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
      final defaultActionTarget =
          _defaultActionTargetForPhase(phase.id, phaseTargets);
      final actionModel = conditionModel.action ??
          TriggerActionModel(
              type: "transitionPhase", target: defaultActionTarget);
      final actionTargetItems = phaseTargets.map((p) => p.id).toList();

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
          title: Text(conditionModel.getReadableConditionStr()),
          subtitle: conditionModel.description?.isNotEmpty ?? false
              ? Text(conditionModel.description!)
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () {
                  signals.removeCondition(actor.id, phase.id, widget.conditionId);
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
                              final updatedCondition =
                                  conditionModel.action == null
                                      ? conditionModel.copyWith(
                                          action: TriggerActionModel(
                                              type: "transitionPhase",
                                              target: defaultActionTarget),
                                        )
                                      : conditionModel;

                              signals.updateCondition(
                                              actor.id,
                                              phase.id,
                                  widget.conditionId,
                                  updatedCondition);
                            },
                          ),
                        ),
                        const SizedBox(width: 18.0),
                        SizedBox(
                          width: 220,
                          child: GenericItemPickerWidget<String>(
                            label: "Action",
                            items: const ["transitionPhase"],
                            initialValue: actionModel.type,
                            propertyBuilder: (value) => value,
                            onChanged: (newValue) {
                              final updatedAction =
                                  actionModel.copyWith(type: newValue);
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
                        SizedBox(
                          width: 260,
                          child: GenericItemPickerWidget<String>(
                            label: "Target Phase",
                            items: actionTargetItems,
                            initialValue:
                                actionTargetItems.contains(actionModel.target)
                                    ? actionModel.target
                                    : defaultActionTarget,
                            propertyBuilder: (value) {
                              final targetPhase = phaseTargets
                                      .firstWhereOrNull((phaseItem) => phaseItem.id == value) ??
                                  phase;
                              return targetPhase.name;
                            },
                            onChanged: (newValue) {
                              final updatedAction =
                                  actionModel.copyWith(target: newValue);
                              signals.updateCondition(
                                actor.id,
                                phase.id,
                                widget.conditionId,
                                conditionModel.copyWith(action: updatedAction),
                              );
                            },
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
                      ))
                ],
              ),
            )
          ],
        ),
      );
    });
  }
}
