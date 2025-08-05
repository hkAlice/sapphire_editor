import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_schedule_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/widgets/add_generic_widget.dart';
import 'package:sapphire_editor/widgets/text_modal_editor_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/generic_timepoint_item.dart';

class TimelineScheduleItem extends StatefulWidget {
  final TimelineModel timelineModel;
  final TimelineScheduleModel scheduleModel;
  final ActorModel selectedActor;
  final int index;
  final Function(TimelineScheduleModel) onUpdate;

  const TimelineScheduleItem({
    super.key,
    required this.timelineModel,
    required this.scheduleModel,
    required this.index,
    required this.selectedActor,
    required this.onUpdate
  });

  @override
  State<TimelineScheduleItem> createState() => _TimelineScheduleItemState();
}

class _TimelineScheduleItemState extends State<TimelineScheduleItem> {
  String _calcDuration() {
    int durationTotalMs = 0;
    for(var timepoint in widget.scheduleModel.timepoints) {
      durationTotalMs += timepoint.startTime;
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
    widget.scheduleModel.timepoints.add(TimepointModel(type: TimepointType.idle));
    setState(() {
      
    });

    widget.onUpdate(widget.scheduleModel);
  }

  @override
  Widget build(BuildContext context) {
    var timepointCountStr = "${widget.scheduleModel.timepoints.length} timepoint${(widget.scheduleModel.timepoints.length != 1 ? 's' : '')}";
    int timeElapsedMs = 0;
    Map<int, int> timeElapsedMap = {};

    for(int i = 0; i < widget.scheduleModel.timepoints.length; i++) {
      timeElapsedMap[i] = timeElapsedMs;
      //timeElapsedMs += widget.scheduleModel.timepoints[i].startTime;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      borderOnForeground: false,
      elevation: 1.0,
      child: ExpansionTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        initiallyExpanded: true,
        title: ReorderableDragStartListener(index: widget.index, child: Text(widget.scheduleModel.name)),
        subtitle: Text(widget.scheduleModel.description.isNotEmpty ? widget.scheduleModel.description : timepointCountStr),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 54.0,
              child: TextModalEditorWidget(
                text: widget.scheduleModel.description,
                headerText: "Edit timepoint description",
                onChanged: (description) {
                  widget.scheduleModel.description = description;
                  widget.onUpdate(widget.scheduleModel);
                }
              ),
            ),
            const SizedBox(width: 8.0,),
            SizedBox(
              width: 32.0,
              height: 32.0,
              child: TextModalEditorWidget(
                text: widget.scheduleModel.name,
                headerText: "Edit schedule name",
                icon: const Icon(Icons.edit_rounded),
                minLines: 1,
                maxLines: 1,
                onChanged: (value) {
                  setState(() {
                    widget.scheduleModel.name = value;
                  });
                  widget.onUpdate(widget.scheduleModel);
                }
              ),
            ),
            const SizedBox(width: 8.0,),
            SizedBox(
              width: 48.0,
              child: Text(_calcDuration(), style: Theme.of(context).textTheme.labelLarge, textAlign: TextAlign.right,)
            ),
          ],
        ),
        children: [
          ReorderableListView.builder(
            buildDefaultDragHandles: false,
            onReorder: (int oldindex, int newindex) {
              setState(() {
                if(newindex > oldindex) {
                  newindex -= 1;
                }
                final items = widget.scheduleModel.timepoints.removeAt(oldindex);
                widget.scheduleModel.timepoints.insert(newindex, items);
              });
          
              widget.onUpdate(widget.scheduleModel);
            },
            itemCount: widget.scheduleModel.timepoints.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, i) {
              var timepointModel = widget.scheduleModel.timepoints[i];

              return GenericTimepointItem(
                key: Key("timepoint_${timepointModel.hashCode}"),
                timelineModel: widget.timelineModel,
                timepointModel: timepointModel,
                scheduleModel: widget.scheduleModel,
                selectedActor: widget.selectedActor,
                timeElapsedMs: timeElapsedMap[i]!,
                index: i,
                onUpdate: (timepoint) {
                  setState(() {
          
                  });

                  widget.onUpdate(widget.scheduleModel);
                },
              );
            }
          ),
          SmallAddGenericWidget(
            onTap: () => _addNewTimepoint(),
            text: "Add new timepoint",
          )
        ],
      ),
    );
  }
}