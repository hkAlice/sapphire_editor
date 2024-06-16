import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/hppctbetween_condition_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';

class HPMinMaxConditionWidget extends StatefulWidget {
  final TimelineModel timelineModel;
  final HPPctBetweenConditionModel paramData;
  final Function(HPPctBetweenConditionModel) onUpdate;
  
  const HPMinMaxConditionWidget({super.key, required this.timelineModel, required this.paramData, required this.onUpdate});

  @override
  State<HPMinMaxConditionWidget> createState() => _HPMinMaxConditionWidgetState();
}

class _HPMinMaxConditionWidgetState extends State<HPMinMaxConditionWidget> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 150,
          child: GenericItemPickerWidget<ActorModel>(
            label: "Source Actor",
            items: widget.timelineModel.actors,
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
            label: "HP Min",
            initialValue: widget.paramData.hpMin,
            onChanged: (newValue) {
              widget.paramData.hpMin = newValue;
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
            label: "HP Max",
            initialValue: widget.paramData.hpMax,
            onChanged: (newValue) {
              widget.paramData.hpMax = newValue;
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