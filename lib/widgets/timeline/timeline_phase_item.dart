import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_phase_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/widgets/add_generic_widget.dart';
import 'package:sapphire_editor/widgets/text_modal_editor_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/generic_timepoint_item.dart';

class TimelinePhaseItem extends StatefulWidget {
  final TimelineModel timelineModel;
  final TimelinePhaseModel phaseModel;
  final ActorModel selectedActor;
  final int index;
  final Function(TimelinePhaseModel) onUpdate;

  const TimelinePhaseItem({
    super.key,
    required this.timelineModel,
    required this.phaseModel,
    required this.index,
    required this.selectedActor,
    required this.onUpdate
  });

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
    var timepointCountStr = "${widget.phaseModel.timepoints.length} timepoint${(widget.phaseModel.timepoints.length != 1 ? 's' : '')}";
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      borderOnForeground: false,
      elevation: 1.0,
      child: ExpansionTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        initiallyExpanded: true,
        title: ReorderableDragStartListener(index: widget.index, child: Text(widget.phaseModel.name)),
        subtitle: Text(widget.phaseModel.description.isNotEmpty ? widget.phaseModel.description : timepointCountStr),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [

                SizedBox(
                  height: 54.0,
                  child: TextModalEditorWidget(
                    text: widget.phaseModel.description,
                    headerText: "Edit timepoint description",
                    onChanged: (description) {
                      widget.phaseModel.description = description;
                      widget.onUpdate(widget.phaseModel);
                    }
                  ),
                ),
                const SizedBox(width: 8.0,),
            SizedBox(
              width: 32.0,
              height: 32.0,
              child: TextModalEditorWidget(
                text: widget.phaseModel.name,
                headerText: "Edit phase name",
                icon: const Icon(Icons.edit_rounded),
                minLines: 1,
                maxLines: 1,
                onChanged: (value) {
                  setState(() {
                    widget.phaseModel.name = value;
                  });
                  widget.onUpdate(widget.phaseModel);
                }
              ),
            ),
            const SizedBox(width: 8.0,),
            Text(_calcDuration(), style: Theme.of(context).textTheme.labelLarge,),
          ],
        ),
        children: [
          for(var point in widget.phaseModel.timepoints)
            GenericTimepointItem(
              timelineModel: widget.timelineModel,
              timepointModel: point,
              phaseModel: widget.phaseModel,
              selectedActor: widget.selectedActor,
              onUpdate: (timepoint) {
                setState(() {
        
                });

                widget.onUpdate(widget.phaseModel);
                },
            ),
          AddGenericWidget(text: "New timepoint", onTap: _addNewTimepoint)
        ],
      ),
    );
  }
}