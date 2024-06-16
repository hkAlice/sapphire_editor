import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/widgets/add_generic_widget.dart';
import 'package:sapphire_editor/widgets/small_heading_widget.dart';
import 'package:sapphire_editor/widgets/timeline/condition/phase_condition_item.dart';

class ConditionTabView extends StatefulWidget {
  final TimelineModel timelineModel;
  final Function() onUpdate;

  const ConditionTabView({super.key, required this.timelineModel, required this.onUpdate});

  @override
  State<ConditionTabView> createState() => _ConditionTabViewState();
}

class _ConditionTabViewState extends State<ConditionTabView> {
  void _addNewPhaseCondition() {
    widget.timelineModel.addNewCondition();

    setState(() {
      
    });

    widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    int conditionCount = widget.timelineModel.conditions.length;
    int enabledConditionsCount = widget.timelineModel.conditions.where((e) => e.enabled).toList().length;

    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SmallHeadingWidget(
              title: "$conditionCount condition${conditionCount == 1 ? '' : 's'} ($enabledConditionsCount enabled)",
              trailing: Row(
                children: [
                  OutlinedButton(
                    onPressed: () {
                      for(var condition in widget.timelineModel.conditions) {
                        condition.enabled = true;
                      }
                      setState(() {
                        
                      });
                      widget.onUpdate();
                    },
                    child: const Text("Enable all")
                  ),
                  const SizedBox(width: 8.0,),
                  OutlinedButton(
                    onPressed: () {
                      for(var condition in widget.timelineModel.conditions) {
                        condition.enabled = false;
                      }
                      setState(() {
                        
                      });
                      widget.onUpdate();
                    },
                    child: const Text("Disable all")
                  ),
                ],
              ),
            ),
            ReorderableListView.builder(
              buildDefaultDragHandles: false,
              onReorder: (int oldindex, int newindex) {
                setState(() {
                  if(newindex > oldindex) {
                    newindex -= 1;
                  }
                  final items = widget.timelineModel.conditions.removeAt(oldindex);
                  widget.timelineModel.conditions.insert(newindex, items);
                  widget.onUpdate();
                });
              },
              itemCount: widget.timelineModel.conditions.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, i) {
                return PhaseConditionItem(
                  key: Key("condition_${widget.timelineModel.conditions[i].id}"),
                  index: i,
                  timelineModel: widget.timelineModel,
                  phaseConditionModel: widget.timelineModel.conditions[i],
                  onUpdate: (phaseConditionModel) {
                    setState(() {
                      
                    });
                    widget.onUpdate();
                  },
                );
              }
            ),
            AddGenericWidget(text: "New condition", onTap: () { _addNewPhaseCondition(); }),
          ],
        ),
      ),
    );
  }
}