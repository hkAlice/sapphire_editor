import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/condition/condition_model.dart';
import 'package:sapphire_editor/utils/text_utils.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/signals_provider.dart';
import 'package:sapphire_editor/widgets/switch_icon_widget.dart';
import 'package:sapphire_editor/widgets/switch_text_widget.dart';
import 'package:sapphire_editor/widgets/timeline/condition/combatstate_condition_widget.dart';
import 'package:sapphire_editor/widgets/timeline/condition/getaction_condition_widget.dart';
import 'package:sapphire_editor/widgets/timeline/condition/hpminmax_condition_widget.dart';
import 'package:sapphire_editor/widgets/timeline/condition/interruptedaction_condition_widget.dart';
import 'package:sapphire_editor/widgets/timeline/condition/scheduleactive_condition_widget.dart';
import 'package:sapphire_editor/widgets/timeline/condition/varequals_condition_widget.dart';
import 'package:signals/signals_flutter.dart';

class ConditionItem extends StatefulWidget {
  final int conditionId;
  final int index;

  const ConditionItem({super.key, required this.conditionId, required this.index});

  @override
  State<ConditionItem> createState() => _ConditionItemState();
}

class _ConditionItemState extends State<ConditionItem> {
  late ActorModel _selectedActor;

  Widget _getCondDataWidget(ConditionModel conditionModel) {
    if(conditionModel.condition == ConditionType.combatState) {
      return CombatStateConditionWidget(
        conditionId: widget.conditionId,
        paramData: conditionModel.paramData,
      );
    } else if(conditionModel.condition == ConditionType.getAction) {
      return GetActionConditionWidget(
        conditionId: widget.conditionId,
        paramData: conditionModel.paramData,
      );
    } else if(conditionModel.condition == ConditionType.hpPctBetween) {
      return HPMinMaxConditionWidget(
        conditionId: widget.conditionId,
        paramData: conditionModel.paramData,
      );
    } else if(conditionModel.condition == ConditionType.scheduleActive) {
      return ScheduleActiveConditionWidget(
        conditionId: widget.conditionId,
        paramData: conditionModel.paramData,
      );
    } else if(conditionModel.condition == ConditionType.interruptedAction) {
      return InterruptedActionConditionWidget(
        conditionId: widget.conditionId,
        paramData: conditionModel.paramData,
      );
    } else if(conditionModel.condition == ConditionType.varEquals) {
      return VarEqualsConditionWidget(
        conditionId: widget.conditionId,
        paramData: conditionModel.paramData,
      );
    } else {
      return Text("Unimplemented condition type ${conditionModel.condition}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final signals = SignalsProvider.of(context);
    
    return Watch((context) {
      final timeline = signals.timeline.value;
      final conditionModel = signals.timeline.value.conditions.firstWhere((c) => widget.conditionId == c.id);
      final selectedTargetActor = signals.timeline.value.actors.first;

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
                child: Text(widget.index.toString().padLeft(2, "0"), style: Theme.of(context).textTheme.displaySmall!.apply(fontSizeFactor: 0.70, color: Theme.of(context).primaryColor),)
              ),
              SwitchTextWidget(
                enabled: conditionModel.enabled,
                onPressed: () {
                  signals.updateCondition(widget.conditionId, conditionModel.copyWith(enabled: !conditionModel.enabled));
                },
              ),
              const VerticalDivider(),
            ],
          ),
          title: Text(conditionModel.getReadableConditionStr()),
          subtitle: conditionModel.description?.isNotEmpty ?? false ? Text(conditionModel.description!) : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchIconWidget(
                icon: Icons.loop_rounded,
                enabled: conditionModel.loop,
                onPressed: () {
                  signals.updateCondition(widget.conditionId, conditionModel.copyWith(loop: !conditionModel.loop));
                }
              ),
              IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () {
                  signals.removeCondition(widget.conditionId);
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
                              conditionModel.changeType(newValue);
                              signals.updateCondition(widget.conditionId, conditionModel);
                            },
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
                          child: Opacity(opacity: 0.5, child: Center(child: Icon(Icons.keyboard_double_arrow_right_outlined))),
                        ),
                        SizedBox(
                          width: 240,
                          child: GenericItemPickerWidget<ActorModel>(
                            label: "Target Actor",
                            items: timeline.actors,
                            initialValue: timeline.actors.firstWhereOrNull((e) => e.name == conditionModel.targetActor),
                            onChanged: (newValue) {
                              _selectedActor = newValue as ActorModel;
                              
                              final newTargetActor = _selectedActor.name;
                              String? newTargetSchedule;
                              
                              if(_selectedActor.schedules.isEmpty) {
                                newTargetSchedule = null;
                              }
                              else {
                                newTargetSchedule = _selectedActor.schedules.first.name;
                              }
                              
                              signals.updateCondition(widget.conditionId, conditionModel.copyWith(
                                targetActor: newTargetActor,
                                targetSchedule: newTargetSchedule,
                              ));
                            },
                          )
                        ),
                        const SizedBox(width: 18.0,),
                        SizedBox(
                          width: 240,
                          child: GenericItemPickerWidget<String>(
                            label: "Schedule",
                            items: selectedTargetActor.schedules.map((e) => e.name).toList(),
                            initialValue: conditionModel.targetSchedule,
                            onChanged: (value) {
                              signals.updateCondition(widget.conditionId, conditionModel.copyWith(targetSchedule: value));
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
                      child: _getCondDataWidget(conditionModel),
                    )
                  )
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}