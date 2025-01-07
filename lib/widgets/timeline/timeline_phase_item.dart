import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_phase_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
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
    int timeElapsedMs = 0;
    Map<int, int> timeElapsedMap = {};

    for(int i = 0; i < widget.phaseModel.timepoints.length; i++) {
      timeElapsedMap[i] = timeElapsedMs;
      timeElapsedMs += widget.phaseModel.timepoints[i].duration;
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
                final items = widget.phaseModel.timepoints.removeAt(oldindex);
                widget.phaseModel.timepoints.insert(newindex, items);
              });
          
              widget.onUpdate(widget.phaseModel);
            },
            itemCount: widget.phaseModel.timepoints.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, i) {
              var timepointModel = widget.phaseModel.timepoints[i];

              return GenericTimepointItem(
                key: Key("timepoint_${timepointModel.hashCode}"),
                timelineModel: widget.timelineModel,
                timepointModel: timepointModel,
                phaseModel: widget.phaseModel,
                selectedActor: widget.selectedActor,
                timeElapsedMs: timeElapsedMap[i]!,
                index: i,
                onUpdate: (timepoint) {
                  setState(() {
          
                  });

                  widget.onUpdate(widget.phaseModel);
                },
              );
            }
          ),
          InkWell(
            onTap: () => _addNewTimepoint(),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade800.withAlpha(150), width: 1.0),
                )
              ),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: Center(
                              child: Opacity(
                                opacity: 0.8,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add, size: 14,),
                                    SizedBox(width: 4.0, height: 24.0,),
                                    Text("Add Timepoint", style: Theme.of(context).textTheme.bodySmall,),
                                  ],
                                ),
                              )
                            )
                          ),
                          const SizedBox(width: 4.0,),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ),
          ),
        ],
      ),
    );
  }
}