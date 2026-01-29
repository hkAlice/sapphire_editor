import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/interruptedaction_condition_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';

class InterruptedActionConditionWidget extends StatefulWidget {
  final TimelineModel timelineModel;
  final InterruptedActionConditionModel paramData;
  final Function(InterruptedActionConditionModel) onUpdate;
  
  const InterruptedActionConditionWidget({super.key, required this.timelineModel, required this.paramData, required this.onUpdate});

  @override
  State<InterruptedActionConditionWidget> createState() => _InterruptedActionConditionWidgetState();
}

class _InterruptedActionConditionWidgetState extends State<InterruptedActionConditionWidget> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 180,
          child: GenericItemPickerWidget<ActorModel>(
            label: "Source Actor",
            items: widget.timelineModel.actors,
            initialValue: widget.timelineModel.actors.firstWhereOrNull((e) => e.name == widget.paramData.sourceActor),
            onChanged: (newValue) {
              widget.paramData.sourceActor = newValue.name;
              widget.onUpdate(widget.paramData);
              setState(() {
                
              });
            },
          )
        ),
        const SizedBox(width: 18.0,),
        SizedBox(
          width: 150,
          child: SimpleNumberField(
            label: "Action ID",
            initialValue: widget.paramData.actionId,
            onChanged: (newValue) {
              widget.paramData.actionId = newValue;
              widget.onUpdate(widget.paramData);
              setState(() {
                
              });
            },
          )
        ),
      ],
    );
  }
}