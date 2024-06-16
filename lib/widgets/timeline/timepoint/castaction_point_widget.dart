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
  final ActorModel selectedActor;
  final Function() onUpdate;

  const CastActionPointWidget({
    super.key,
    required this.timelineModel,
    required this.timepointModel,
    required this.onUpdate,
    required this.selectedActor
  });

  @override
  State<CastActionPointWidget> createState() => _CastActionPointWidgetState();
}

class _CastActionPointWidgetState extends State<CastActionPointWidget> {
  late CastActionPointModel pointData = widget.timepointModel.data as CastActionPointModel;

  @override
  Widget build(BuildContext context) {
    var validActors = List<String>.from(widget.selectedActor.subactors)..insert(0, widget.selectedActor.name);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: 180,
          child: GenericItemPickerWidget<String>(
            label: "Source Actor",
            items: validActors,
            initialValue: pointData.sourceActor,
            onChanged: (newValue) {
              pointData.sourceActor = newValue;
              widget.onUpdate();
              setState(() {
                
              });
            },
          ),
        ),
        const SizedBox(width: 18.0,),
        SizedBox(
          width: 110,
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