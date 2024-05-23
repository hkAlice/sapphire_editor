import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/timeline_phase_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/widgets/add_generic_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/generic_timepoint_item.dart';

class TimelinePhaseItem extends StatefulWidget {
  final TimelinePhaseModel phaseModel;
  final int index;
  final Function(TimelinePhaseModel) onUpdate;

  const TimelinePhaseItem({super.key, required this.phaseModel, required this.index, required this.onUpdate});

  @override
  State<TimelinePhaseItem> createState() => _TimelinePhaseItemState();
}

class _TimelinePhaseItemState extends State<TimelinePhaseItem> {
  String _calcDuration() {
    int durationTotalMs = 0;
    for(var timepoint in widget.phaseModel.timepoints) {
      durationTotalMs += timepoint.duration;
    }

    Duration duration = Duration(milliseconds: durationTotalMs);

    String twoDigits(int n) {
      if(n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if(duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "$twoDigitMinutes:$twoDigitSeconds";
    }
  }

  void _addNewTimepoint() {
    widget.phaseModel.timepoints.add(TimepointModel(type: TimepointType.idle));
    setState(() {
      
    });

    widget.onUpdate(widget.phaseModel);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      shadowColor: Colors.transparent,
      borderOnForeground: false,
      elevation: 1.0,
      child: ExpansionTile(
        shape: const Border(),
        initiallyExpanded: true,
        title: ReorderableDragStartListener(index: widget.index, child: Text(widget.phaseModel.name)),
        subtitle: Text("${widget.phaseModel.timepoints.length} timepoint ${(widget.phaseModel.timepoints.length != 1 ? 's' : '')}"),
        trailing: Text(_calcDuration()),
        children: [
          for(var point in widget.phaseModel.timepoints)
            GenericTimepointItem(
              timepointModel: point,
              phaseModel: widget.phaseModel,
              onUpdate: (timepoint) {
                setState(() {
        
                });

                widget.onUpdate(widget.phaseModel);
                },
            ),
          AddGenericWidget(text: "Add new timepoint", onTap: _addNewTimepoint)
        ],
      ),
    );
  }
}