import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/condition/phase_conditions_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_phase_model.dart';
import 'package:sapphire_editor/utils/text_utils.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/switch_icon_widget.dart';
import 'package:sapphire_editor/widgets/switch_text_widget.dart';
import 'package:sapphire_editor/widgets/timeline/condition/combatstate_condition_widget.dart';
import 'package:sapphire_editor/widgets/timeline/condition/hpminmax_condition_widget.dart';

class PhaseConditionItem extends StatefulWidget {
  final TimelineModel timelineModel;
  final PhaseConditionModel phaseConditionModel;
  final int index;
  final Function(PhaseConditionModel) onUpdate;

  const PhaseConditionItem({super.key, required this.timelineModel, required this.phaseConditionModel, required this.index, required this.onUpdate});

  @override
  State<PhaseConditionItem> createState() => _PhaseConditionItemState();
}

class _PhaseConditionItemState extends State<PhaseConditionItem> {
  late TextEditingController _descriptionTextEditingController;
  late ActorModel _selectedActor;

  List<DropdownMenuItem<String>> _generateDropPhaseItems() {
    return _selectedActor.phases.map((TimelinePhaseModel phase) {
      return DropdownMenuItem<String>(
        value: phase.name,
        child: Text(phase.name));
    }).toList();
  }

  Widget _getCondDataWidget() {
    void genericCallback() {
      widget.onUpdate(widget.phaseConditionModel);
      setState(() {
        
      });
    }
    if(widget.phaseConditionModel.condition == PhaseConditionType.hpPctBetween) {
      return HPMinMaxConditionWidget(timelineModel: widget.timelineModel, paramData: widget.phaseConditionModel.paramData, onUpdate: (_) { genericCallback(); });
    } else if(widget.phaseConditionModel.condition == PhaseConditionType.combatState) {
      return CombatStateConditionWidget(timelineModel: widget.timelineModel, paramData: widget.phaseConditionModel.paramData, onUpdate: (_) { genericCallback(); });
    } else {
      return Text("Unimplemented condition type $widget.phaseConditionModel.condition");
    }
  }

  @override
  void initState() {
    _descriptionTextEditingController = TextEditingController(text: widget.phaseConditionModel.description);
    _selectedActor = widget.timelineModel.actors.first;
      
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      borderOnForeground: false,
      shadowColor: Colors.transparent,
      elevation: 1.0,
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ExpansionTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ReorderableDragStartListener(
              index: widget.index,
              child: Text(widget.index.toString().padLeft(2, "0"), style: Theme.of(context).textTheme.displaySmall!.apply(fontSizeFactor: 0.70, color: Theme.of(context).primaryColor),)
            ),
            SwitchTextWidget(
              enabled: widget.phaseConditionModel.enabled,
              onPressed: () {
                setState(() {
                  widget.phaseConditionModel.enabled = !widget.phaseConditionModel.enabled;
                });
                widget.onUpdate(widget.phaseConditionModel);
              },
            ),
            const VerticalDivider(),
          ],
        ),
        title: Text(widget.phaseConditionModel.getReadableConditionStr()),
        subtitle: widget.phaseConditionModel.description?.isNotEmpty ?? false ? Text(widget.phaseConditionModel.description!) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchIconWidget(
              icon: Icons.loop_rounded,
              enabled: widget.phaseConditionModel.loop,
              onPressed: () {
                setState(() {
                  widget.phaseConditionModel.loop = !widget.phaseConditionModel.loop;
                });
                widget.onUpdate(widget.phaseConditionModel);
              }
            ),
            IconButton(
              icon: const Icon(Icons.clear_rounded),
              onPressed: () {
                widget.timelineModel.conditions.removeAt(widget.index);
                widget.onUpdate(widget.phaseConditionModel);
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
                        child: GenericItemPickerWidget<PhaseConditionType>(
                          label: "Condition",
                          items: PhaseConditionType.values,
                          propertyBuilder: (value) {
                            return treatEnumName(value);
                          },
                          onChanged: (newValue) {
                            setState(() {
                              widget.phaseConditionModel.changeType(newValue);
                            });
                            widget.onUpdate(widget.phaseConditionModel);
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
                          items: widget.timelineModel.actors,
                          onChanged: (newValue) {
                            _selectedActor = newValue as ActorModel;
                            
                            widget.phaseConditionModel.targetActor = _selectedActor.name;
                            
                            if(_selectedActor.phases.isEmpty) {
                              widget.phaseConditionModel.targetPhase = null;
                            }
                            else {
                              widget.phaseConditionModel.targetPhase = _selectedActor.phases.first.name;
                            }
                            
                            setState(() {
                              
                            });
                            
                            widget.onUpdate(widget.phaseConditionModel);
                          },
                        )
                      ),
                      const SizedBox(width: 18.0,),
                      SizedBox(
                        width: 240,
                        child: GenericItemPickerWidget<String>(
                          label: "Phase",
                          items: _selectedActor.phases.map((e) => e.name).toList(),
                          initialValue: widget.phaseConditionModel.targetPhase,
                          onChanged: (value) {
                            setState(() {
                              widget.phaseConditionModel.targetPhase = value;
                            });
                            widget.onUpdate(widget.phaseConditionModel);
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
        ]
      ),
    );
  }
}