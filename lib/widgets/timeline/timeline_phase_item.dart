import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:sapphirexiv_timeline_editor/models/timeline/timeline_phase_model.dart';
import 'package:sapphirexiv_timeline_editor/models/timeline/timepoint_model.dart';
import 'package:sapphirexiv_timeline_editor/widgets/add_generic_widget.dart';
import 'package:sapphirexiv_timeline_editor/widgets/timeline/generic_timepoint_item.dart';

class TimelinePhaseItem extends StatefulWidget {
  final TimelinePhaseModel phaseModel;
  final int index;
  final Function(TimelinePhaseModel) onUpdate;

  const TimelinePhaseItem({super.key, required this.phaseModel, required this.index, required this.onUpdate});

  @override
  State<TimelinePhaseItem> createState() => _TimelinePhaseItemState();
}

class _TimelinePhaseItemState extends State<TimelinePhaseItem> {
  void _addNewTimepoint() {
    widget.phaseModel.timepoints.add(TimepointModel(type: TimepointType.idle));
    setState(() {
      
    });

    widget.onUpdate(widget.phaseModel);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.0),
      shadowColor: Colors.transparent,
      borderOnForeground: false,
      elevation: 1.0,
      child: ExpansionTile(
        shape: const Border(),
        initiallyExpanded: true,
        title: ReorderableDragStartListener(index: widget.index, child: Text(widget.phaseModel.name)),
        subtitle: Text(widget.phaseModel.timepoints.length.toString() + " timepoint" + (widget.phaseModel.timepoints.length != 1 ? "s" : "")),
        trailing: Text("00:00"),
        children: [
          for(var point in widget.phaseModel.timepoints)
            GenericTimepointItem(timepointModel: point, onUpdate: (timepoint) {
              setState(() {
      
              });

              widget.onUpdate(widget.phaseModel);
            },),
          AddGenericWidget(text: "Add new timepoint", onTap: _addNewTimepoint)
        ],
      ),
    );
  }
}