import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/castaction_point_model.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';

class CastActionPointWidget extends StatefulWidget {
  final TimelineModel timelineModel;
  final TimepointModel timepointModel;
  final Function() onUpdate;

  const CastActionPointWidget({super.key, required this.timelineModel, required this.timepointModel, required this.onUpdate});

  @override
  State<CastActionPointWidget> createState() => _CastActionPointWidgetState();
}

class _CastActionPointWidgetState extends State<CastActionPointWidget> {
  late CastActionPointModel pointData = widget.timepointModel.data as CastActionPointModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: GenericItemPickerWidget<ActorModel>(
            label: "Source Actor",
            items: widget.timelineModel.actors,
            onChanged: (newValue) {
              pointData.sourceActor = newValue.name;
              widget.onUpdate();
              setState(() {
                
              });
            },
          ),
        ),
        const SizedBox(width: 18.0,),
        SizedBox(
          width: 150,
          child: SimpleNumberField(
            label: "Action ID",
            initialValue: pointData.actionId,
            onChanged: (newValue) {
              pointData.actionId = newValue;
              widget.onUpdate();
            }
          ),
        ),
      ],
    );
  }
}