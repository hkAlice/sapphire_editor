import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_schedule_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/utils/text_utils.dart';
import 'package:sapphire_editor/widgets/number_button.dart';
import 'package:sapphire_editor/widgets/text_modal_editor_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/actiontimeline_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/battletalk_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/bnpcdespawn_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/bnpcflags_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/castaction_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/directorflags_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/directorseq_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/directorvar_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/idle_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/interruptaction_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/logmessage_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/setpos_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/setbgm_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/setcondition_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/snapshot_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/spawnbnpc_point_widget.dart';

class GenericTimepointItem extends StatefulWidget {
  final TimelineModel timelineModel;
  final TimelineScheduleModel scheduleModel;
  final TimepointModel timepointModel;
  final ActorModel selectedActor;
  final Function(TimepointModel) onUpdate;
  final int timeElapsedMs;
  final int index;

  const GenericTimepointItem({
    super.key,
    required this.timelineModel,
    required this.scheduleModel,
    required this.timepointModel,
    required this.selectedActor,
    required this.onUpdate,
    required this.timeElapsedMs,
    required this.index
  });

  @override
  State<GenericTimepointItem> createState() => _GenericTimepointItemState();
}

class _GenericTimepointItemState extends State<GenericTimepointItem> {
  String twoDigits(int n) {
    if(n >= 10) return "$n";
    return "0$n";
  }
  
  String _calcT() {
    Duration startTime = Duration(milliseconds: widget.timepointModel.startTime);

    String twoDigitMinutes = twoDigits(startTime.inSeconds.remainder(60));
    String twoDigitSeconds = twoDigits(startTime.inMilliseconds.remainder(60));
    if(startTime.inHours > 0) {
      return "${twoDigits(startTime.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "$twoDigitMinutes.${twoDigitSeconds}s";
    }
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableDragStartListener(
      index: widget.index,
      child: InkWell(
        onTap: () async {
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return TimepointEditorWidget(
                timepointModel: widget.timepointModel,
                timelineModel: widget.timelineModel,
                selectedActor: widget.selectedActor,
                onUpdate: (_) {
                  //widget.onUpdate(widget.timepointModel);
                }
              );
            },
          );

          widget.onUpdate(widget.timepointModel);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black12,
            border: Border(
              left: BorderSide(color: widget.timepointModel.getColorForTimepointType(), width: 2.0),
              top: BorderSide(color: Colors.grey.shade800.withAlpha(150), width: 1.0)
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
                      Padding(
                        padding: const EdgeInsets.only(left: 5.5),
                        child: Opacity(
                          opacity: 0.7,
                          child: Text(_calcT(), style: Theme.of(context).textTheme.labelSmall, maxLines: 1, textAlign: TextAlign.right,)
                        ),
                      ),
                      const VerticalDivider(),
                      Container(
                        width: 110,
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(treatEnumName(widget.timepointModel.type), style: Theme.of(context).textTheme.bodyMedium,)
                      ),
                      const VerticalDivider(),
                      Expanded(child: Text(widget.timepointModel.data.toString(), style: Theme.of(context).textTheme.bodySmall,)),
                      const VerticalDivider(),
                      SizedBox(
                        width: 24.0,
                        height: 24.0,
                        child: IconButton(
                          padding: const EdgeInsets.all(0.0),
                          icon: const Icon(Icons.copy, size: 16.0,),
                          splashRadius: 14.0,
                          onPressed: () {
                            var newTimepoint = TimepointModel.fromJson(jsonDecode(jsonEncode(widget.timepointModel)));
                            var index = widget.scheduleModel.timepoints.indexOf(widget.timepointModel);

                            widget.scheduleModel.timepoints.insert(index + 1, newTimepoint);
                            widget.onUpdate(widget.timepointModel);
                          },
                        ),
                      ),
                      const SizedBox(width: 4.0,),
                      SizedBox(
                        width: 24.0,
                        height: 24.0,
                        child: IconButton(
                          padding: const EdgeInsets.all(0.0),
                          icon: const Icon(Icons.clear_rounded, size: 16.0,),
                          splashRadius: 14.0,
                          onPressed: () {
                            widget.scheduleModel.timepoints.remove(widget.timepointModel);
                            widget.onUpdate(widget.timepointModel);
                          },
                        ),
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
    );
  }
}

class TimepointEditorWidget extends StatefulWidget {
  final TimepointModel timepointModel;
  final TimelineModel timelineModel;
  final ActorModel selectedActor;
  final Function(TimepointModel) onUpdate;

  const TimepointEditorWidget({
    super.key,
    required this.timepointModel,
    required this.timelineModel,
    required this.selectedActor,
    required this.onUpdate
  });

  @override
  State<TimepointEditorWidget> createState() => _TimepointEditorWidgetState();
}

class _TimepointEditorWidgetState extends State<TimepointEditorWidget> {
  Widget _generateTypedTimepoint() {
    // todo: can also use cast type "is".. though slower
    var timepointModel = widget.timepointModel;
    var timelineModel = widget.timelineModel;
    var selectedActor = widget.selectedActor;

    onUpdate() {
      widget.onUpdate(widget.timepointModel);
    }

    switch(widget.timepointModel.type) {
      case TimepointType.actionTimeline:
        return ActionTimelinePointWidget(timelineModel: timelineModel, timepointModel: timepointModel, onUpdate: onUpdate);
      case TimepointType.castAction:
        return CastActionPointWidget(timelineModel: timelineModel, timepointModel: timepointModel, selectedActor: selectedActor, onUpdate: onUpdate);
      case TimepointType.battleTalk:
        return BattleTalkPointWidget(timelineModel: timelineModel, timepointModel: timepointModel, onUpdate: onUpdate);
      case TimepointType.bNpcDespawn:
        return BNpcDespawnPointWidget(timelineModel: timelineModel, timepointModel: timepointModel, onUpdate: onUpdate);
      case TimepointType.bNpcFlags:
        return BNpcFlagsPointWidget(timepointModel: timepointModel, onUpdate: onUpdate);
      case TimepointType.bNpcSpawn:
        return BNpcSpawnPointWidget(timelineModel: timelineModel, timepointModel: timepointModel, onUpdate: onUpdate);
      case TimepointType.directorFlags:
        return DirectorFlagsPointWidget(timepointModel: timepointModel, onUpdate: onUpdate);
      case TimepointType.directorSeq:
        return DirectorSeqPointWidget(timepointModel: timepointModel, onUpdate: onUpdate);
      case TimepointType.directorVar:
        return DirectorVarPointWidget(timepointModel: timepointModel, onUpdate: onUpdate);
      case TimepointType.idle:
        return const IdlePointWidget();
      case TimepointType.logMessage:
        return LogMessagePointWidget(timepointModel: timepointModel, onUpdate: onUpdate);
      case TimepointType.setBGM:
        return SetBgmPointWidget(timepointModel: timepointModel, onUpdate: onUpdate);
      case TimepointType.setCondition:
        return SetConditionPointWidget(timelineModel: timelineModel, timepointModel: timepointModel, onUpdate: onUpdate);
      case TimepointType.setPos:
        return SetPosPointWidget(timelineModel: timelineModel, timepointModel: timepointModel, selectedActor: selectedActor, onUpdate: onUpdate);
      case TimepointType.snapshot:
        return SnapshotPointWidget(timelineModel: timelineModel, timepointModel: timepointModel, selectedActor: selectedActor, onUpdate: onUpdate);
      case TimepointType.interruptAction:
        return InterruptActionPointWidget(timelineModel: timelineModel, timepointModel: timepointModel, selectedActor: selectedActor, onUpdate: onUpdate);
      default:
        return Text("Unimplemented timepoint type ${widget.timepointModel.type}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Edit timepoint"),
          SizedBox(
            width: 32.0,
            height: 32.0,
            child: IconButton.outlined(
              padding: const EdgeInsets.all(0.0),
              icon: const Icon(Icons.close),
              splashRadius: 28.0,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          )
        ],
      ),
      content: Container(
        color: Colors.black12,
        constraints: const BoxConstraints(minWidth: 800),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  NumberButton(
                    min: 0,
                    max: 60000,
                    value: widget.timepointModel.startTime,
                    label: "Start time",
                    inputFormatters: <TextInputFormatter>[
                      MaskTextInputFormatter(
                        mask: "##:##", 
                        filter: { "#": RegExp(r'[0-9]') },
                        type: MaskAutoCompletionType.lazy
                      )
                    ],
                    builder: (value) {
                      var seconds = value / 1000;
                      return "${seconds.toStringAsFixed(1)}s";
                    },
                    stepCount: 100,
                    onChanged: (value) {
                      widget.timepointModel.startTime = value;
                      widget.onUpdate(widget.timepointModel);
                    }
                  ),
                  const SizedBox(width: 18.0,),
                  SizedBox(
                    width: 180,
                    child: DropdownButtonFormField<TimepointType>(
                      decoration: const InputDecoration(
                        filled: false,
                        labelText: "Point type",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(10.5)
                      ),
                      value: widget.timepointModel.type,
                      isDense: true,
                      onChanged: (TimepointType? value) {
                        if(value == null) { return; }
              
                        widget.timepointModel.changeType(value);
                        
                        
                        widget.onUpdate(widget.timepointModel);
                        setState(() {
                          
                        });
                      },
                      items: TimepointType.values.map((TimepointType type) {
                        return DropdownMenuItem<TimepointType>(
                          value: type,
                          child: Text(treatEnumName(type)));
                      }).toList()
                    ),
                  ),
                  const SizedBox(width: 18.0,),
                  Expanded(
                    child: SizedBox(
                      height: 54.0,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(widget.timepointModel.description, textAlign: TextAlign.start, overflow: TextOverflow.fade,)
                      )
                    ),
                  ),
                  SizedBox(
                    height: 54.0,
                    child: TextModalEditorWidget(
                      text: widget.timepointModel.description,
                      headerText: "Edit timepoint description",
                      onChanged: (description) {
                        widget.timepointModel.description = description;
                        setState(() {
                          
                        });
                        widget.onUpdate(widget.timepointModel);
                      }
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.black12,
              padding: widget.timepointModel.type == TimepointType.idle ? null : const EdgeInsets.all(8.0),
              child: _generateTypedTimepoint()
            )
          ],
        ),
      ),
    );
  }
}