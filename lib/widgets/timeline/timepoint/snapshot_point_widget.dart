import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/selector/selector_filter_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/snapshot_point_model.dart';
import 'package:sapphire_editor/utils/text_utils.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';

class SnapshotPointWidget extends StatefulWidget {
  final TimelineModel timelineModel;
  final TimepointModel timepointModel;
  final ActorModel selectedActor;
  final Function() onUpdate;

  const SnapshotPointWidget({super.key, required this.timelineModel, required this.timepointModel, required this.selectedActor, required this.onUpdate});

  @override
  State<SnapshotPointWidget> createState() => _SnapshotPointWidgetState();
}

class _SnapshotPointWidgetState extends State<SnapshotPointWidget> {
  late SnapshotPointModel pointData = widget.timepointModel.data as SnapshotPointModel;

  @override
  Widget build(BuildContext context) {
    var validActors = List<String>.from(widget.selectedActor.subactors)..insert(0, widget.selectedActor.name);

    return Row(
      children: [
        SizedBox(
          width: 200,
          child: GenericItemPickerWidget<String>(
            label: "Selector",
            items: widget.timelineModel.selectors.map((e) => e.name).toList(),
            onChanged: (newValue) {
              pointData.selector = newValue;
              widget.onUpdate();
              setState(() {
                
              });
            },
          ),
        ),
        const SizedBox(width: 18.0),
        SizedBox(
          width: 200,
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
      ],
    );
  }
}