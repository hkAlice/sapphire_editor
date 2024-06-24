import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/getaction_condition_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';

class GetActionConditionWidget extends StatefulWidget {
  final TimelineModel timelineModel;
  final GetActionConditionModel paramData;
  final Function(GetActionConditionModel) onUpdate;
  
  const GetActionConditionWidget({super.key, required this.timelineModel, required this.paramData, required this.onUpdate});

  @override
  State<GetActionConditionWidget> createState() => _GetActionConditionWidgetState();
}

class _GetActionConditionWidgetState extends State<GetActionConditionWidget> {
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