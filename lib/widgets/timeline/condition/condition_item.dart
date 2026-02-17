import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/condition/condition_model.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';
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
  final ConditionModel conditionModel;
  final int index;

  const ConditionItem({super.key, required this.conditionModel, required this.index});

  @override
  State<ConditionItem> createState() => _ConditionItemState();
}

class _ConditionItemState extends State<ConditionItem> {
  late ActorModel _selectedActor;

  Widget _getCondDataWidget() {
    final signals = SignalsProvider.of(context);
    
    if(widget.conditionModel.condition == ConditionType.combatState) {
      return CombatStateConditionWidget(paramData: widget.conditionModel.paramData);
    } else if(widget.conditionModel.condition == ConditionType.getAction) {
      return GetActionConditionWidget(paramData: widget.conditionModel.paramData);
    } else if(widget.conditionModel.condition == ConditionType.hpPctBetween) {
      return HPMinMaxConditionWidget(paramData: widget.conditionModel.paramData);
    } else if(widget.conditionModel.condition == ConditionType.scheduleActive) {
      return ScheduleActiveConditionWidget(paramData: widget.conditionModel.paramData);
    } else if(widget.conditionModel.condition == ConditionType.interruptedAction) {
      return InterruptedActionConditionWidget(paramData: widget.conditionModel.paramData);
    } else if(widget.conditionModel.condition == ConditionType.varEquals) {
      return VarEqualsConditionWidget(paramData: widget.conditionModel.paramData);
    } else {
      return Text("Unimplemented condition type ${widget.conditionModel.condition}");
    }
  }

  @override
  void initState() {
    // hack: lol
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final signals = SignalsProvider.of(context);
      _selectedActor = signals.timeline.value.actors.first;
    });
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final signals = SignalsProvider.of(context);
    
    return Watch((context) {
      final timeline = signals.timeline.value;
      var selectedTargetActor = timeline.actors.firstWhereOrNull((e) => e.name == widget.conditionModel.targetActor);

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
                enabled: widget.conditionModel.enabled,
                onPressed: () {
                  widget.conditionModel.enabled = !widget.conditionModel.enabled;
                  signals.timeline.value = timeline;
                },
              ),
              const VerticalDivider(),
            ],
          ),
          title: Text(widget.conditionModel.getReadableConditionStr()),
          subtitle: widget.conditionModel.description?.isNotEmpty ?? false ? Text(widget.conditionModel.description!) : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchIconWidget(
                icon: Icons.loop_rounded,
                enabled: widget.conditionModel.loop,
                onPressed: () {
                  widget.conditionModel.loop = !widget.conditionModel.loop;
                  signals.timeline.value = timeline;
                }
              ),
              IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () {
                  timeline.conditions.removeAt(widget.index);
                  signals.timeline.value = timeline;
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
                            initialValue: widget.conditionModel.condition,
                            propertyBuilder: (value) {
                              return treatEnumName(value);
                            },
                            onChanged: (newValue) {
                              widget.conditionModel.changeType(newValue);
                              signals.timeline.value = timeline;
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
                            initialValue: timeline.actors.firstWhereOrNull((e) => e.name == widget.conditionModel.targetActor),
                            onChanged: (newValue) {
                              _selectedActor = newValue as ActorModel;
                              
                              widget.conditionModel.targetActor = _selectedActor.name;
                              
                              if(_selectedActor.schedules.isEmpty) {
                                widget.conditionModel.targetSchedule = null;
                              }
                              else {
                                widget.conditionModel.targetSchedule = _selectedActor.schedules.first.name;
                              }
                              
                              signals.timeline.value = timeline;
                            },
                          )
                        ),
                        const SizedBox(width: 18.0,),
                        SizedBox(
                          width: 240,
                          child: GenericItemPickerWidget<String>(
                            label: "Schedule",
                            items: selectedTargetActor == null ? [] : selectedTargetActor.schedules.map((e) => e.name).toList(),
                            initialValue: widget.conditionModel.targetSchedule,
                            onChanged: (value) {
                              widget.conditionModel.targetSchedule = value;
                              signals.timeline.value = timeline;
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
                      child: _getCondDataWidget(),
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