import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/actiontimeline_point_model.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';

class ActionTimelinePointWidget extends StatefulWidget {
  final TimelineModel timelineModel;
  final TimepointModel timepointModel;
  final Function() onUpdate;

  const ActionTimelinePointWidget({super.key, required this.timelineModel, required this.timepointModel, required this.onUpdate});

  @override
  State<ActionTimelinePointWidget> createState() => _ActionTimelinePointWidgetState();
}

class _ActionTimelinePointWidgetState extends State<ActionTimelinePointWidget> {
  late ActionTimelinePointModel pointData = widget.timepointModel.data as ActionTimelinePointModel;
  
  @override
  Widget build(BuildContext context) {
    var validActors = List<String>.from(widget.timelineModel.actors.map((e) => e.name));

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
                initialValue: validActors.firstWhereOrNull((e) => e == pointData.actorName),
                onChanged: (newValue) {
                  pointData.actorName = newValue;
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
                label: "ActionTimeline ID",
                initialValue: pointData.actionTimelineId,
                onChanged: (value) {
                  pointData.actionTimelineId = value;
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