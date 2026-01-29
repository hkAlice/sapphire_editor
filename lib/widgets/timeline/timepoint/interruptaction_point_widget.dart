import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/interruptaction_point_model.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';

class InterruptActionPointWidget extends StatefulWidget {
  final TimelineModel timelineModel;
  final TimepointModel timepointModel;
  final ActorModel selectedActor;
  final Function() onUpdate;

  const InterruptActionPointWidget({
    super.key,
    required this.timelineModel,
    required this.timepointModel,
    required this.onUpdate,
    required this.selectedActor
  });

  @override
  State<InterruptActionPointWidget> createState() => _InterruptActionPointWidgetState();
}

class _InterruptActionPointWidgetState extends State<InterruptActionPointWidget> {
  late InterruptActionPointModel pointData = widget.timepointModel.data as InterruptActionPointModel;
  
  @override
  Widget build(BuildContext context) {
    var validActors = List<String>.from(widget.selectedActor.subactors)..insert(0, widget.selectedActor.name);

    return Row(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 180,
              child: GenericItemPickerWidget<String>(
                label: "Actor",
                items: validActors,
                initialValue: validActors.firstWhereOrNull((e) => e == pointData.sourceActor),
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
              width: 140,
              child: SimpleNumberField(
                label: "Action ID",
                initialValue: pointData.actionId,
                onChanged: (value) {
                  pointData.actionId = value;
                  widget.onUpdate();
                }
              ),
            ),
          ],
        ),
      ],
    );
  }
}