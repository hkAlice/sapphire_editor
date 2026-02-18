import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
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
import 'package:sapphire_editor/widgets/timeline/timepoint/rollrng_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/setpos_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/setbgm_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/setcondition_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/snapshot_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/spawnbnpc_point_widget.dart';
import 'package:sapphire_editor/widgets/signals_provider.dart';
import 'package:signals_flutter/signals_flutter.dart';

class GenericTimepointItem extends StatelessWidget {
  final int timepointId;
  final int scheduleIndex;
  final int scheduleId;
  final int timepointIndex;
  final int timeElapsedMs;
  final int actorId;

  const GenericTimepointItem({
    super.key,
    required this.timepointId,
    required this.scheduleIndex,
    required this.scheduleId,
    required this.timepointIndex,
    required this.timeElapsedMs,
    required this.actorId
  });

  String twoDigits(int n) {
    if(n >= 10) return "$n";
    return "0$n";
  }
  
  String _calcT(TimepointModel tp) {
    Duration startTime = Duration(milliseconds: tp.startTime);

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
    final signals = SignalsProvider.of(context);

    return Watch((context) {
      final actor = signals.timeline.value.actors.firstWhere((a) => a.id == actorId);
      final schedule = actor.schedules.firstWhere((s) => s.id == scheduleId);
      final timepointModel = schedule.timepoints.firstWhere((t) => t.id == timepointId);

      return ReorderableDragStartListener(
        index: timepointIndex,
        child: InkWell(
          onTap: () async {
            showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return TimepointEditorWidget(
                  scheduleId: scheduleId,
                  timepointId: timepointModel.id,
                  actorId: actor.id,
                );
              },
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black12,
              border: Border(
                left: BorderSide(color: timepointModel.getColorForTimepointType(), width: 2.0),
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
                            child: Text(
                              _calcT(timepointModel),
                              style: Theme.of(context).textTheme.labelSmall,
                              maxLines: 1,
                              textAlign: TextAlign.right,
                            )
                          ),
                        ),
                        const VerticalDivider(),
                        Container(
                          width: 110,
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Text(treatEnumName(timepointModel.type), style: Theme.of(context).textTheme.bodyMedium,)
                        ),
                        const VerticalDivider(),
                        Expanded(child: Text(timepointModel.data.toString(), style: Theme.of(context).textTheme.bodySmall,)),
                        const VerticalDivider(),
                        SizedBox(
                          width: 24.0,
                          height: 24.0,
                          child: IconButton(
                            padding: const EdgeInsets.all(0.0),
                            icon: const Icon(Icons.copy, size: 16.0,),
                            splashRadius: 14.0,
                            onPressed: () {
                              signals.duplicateTimepoint(
                                signals.selectedSchedule.value,
                                timepointModel,
                                actor.id
                              );
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
                              signals.removeTimepoint(
                                signals.selectedSchedule.value,
                                timepointModel,
                                actor.id
                              );
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
    });
  }
}

class TimepointEditorWidget extends StatefulWidget {
  final int scheduleId;
  final int timepointId;
  final int actorId;

  const TimepointEditorWidget({
    super.key,
    required this.scheduleId,
    required this.timepointId,
    required this.actorId
  });

  @override
  State<TimepointEditorWidget> createState() => _TimepointEditorWidgetState();
}

class _TimepointEditorWidgetState extends State<TimepointEditorWidget> {
  Widget _generateTypedTimepoint(TimepointModel tp) {

    switch(tp.type) {
      case TimepointType.actionTimeline:
        return ActionTimelinePointWidget(timepointModel: tp);
      case TimepointType.castAction:
        return CastActionPointWidget(timepointModel: tp);
      case TimepointType.battleTalk:
        return BattleTalkPointWidget(timepointModel: tp);
      case TimepointType.bNpcDespawn:
        return BNpcDespawnPointWidget(timepointModel: tp);
      case TimepointType.bNpcFlags:
        return BNpcFlagsPointWidget(timepointModel: tp);
      case TimepointType.bNpcSpawn:
        return BNpcSpawnPointWidget(timepointModel: tp);
      case TimepointType.directorFlags:
        return DirectorFlagsPointWidget(timepointModel: tp);
      case TimepointType.directorSeq:
        return DirectorSeqPointWidget(timepointModel: tp);
      case TimepointType.directorVar:
        return DirectorVarPointWidget(timepointModel: tp);
      case TimepointType.idle:
        return const IdlePointWidget();
      case TimepointType.logMessage:
        return LogMessagePointWidget(timepointModel: tp);
      case TimepointType.setBGM:
        return SetBgmPointWidget(timepointModel: tp);
      case TimepointType.setCondition:
        return SetConditionPointWidget(timepointModel: tp);
      case TimepointType.setPos:
        return SetPosPointWidget(timepointModel: tp);
      case TimepointType.snapshot:
        return SnapshotPointWidget(timepointModel: tp);
      case TimepointType.interruptAction:
        return InterruptActionPointWidget(timepointModel: tp);
      case TimepointType.rollRNG:
        return RollRNGPointWidget(timepointModel: tp);
      default:
        return Text("Unimplemented timepoint type ${tp.type}");
    }

  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final signals = SignalsProvider.of(context);

      final actor = signals.timeline.value.actors.firstWhere((a) => a.id == widget.actorId);
      final schedule = actor.schedules.firstWhere((s) => s.id == widget.scheduleId);
      final timepointModel = schedule.timepoints.firstWhere((t) => t.id == widget.timepointId);
      

      return AlertDialog(
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
                      value: timepointModel.startTime,
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
                        final newTp = timepointModel.copyWith(startTime: value);
                        signals.updateTimepoint(
                          signals.selectedActor.value.id,
                          signals.selectedSchedule.value.id,
                          timepointModel.id,
                          newTp
                        );
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
                        initialValue: timepointModel.type,
                        isDense: true,
                        onChanged: (TimepointType? value) {
                          if(value == null) { return; }
          
                          timepointModel.changeType(value);
                          
                          signals.updateTimepoint(
                            signals.selectedActor.value.id,
                            signals.selectedSchedule.value.id,
                            timepointModel.id,
                            timepointModel
                          );
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
                          child: Text(timepointModel.description, textAlign: TextAlign.start, overflow: TextOverflow.fade,)
                        )
                      ),
                    ),
                    SizedBox(
                      height: 54.0,
                      child: TextModalEditorWidget(
                        text: timepointModel.description,
                        headerText: "Edit timepoint description",
                        onChanged: (description) {
                          final newTp = timepointModel.copyWith(description: description);
                          signals.updateTimepoint(
                            signals.selectedActor.value.id,
                            signals.selectedSchedule.value.id,
                            timepointModel.id,
                            newTp
                          );
                        }
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.black12,
                padding: timepointModel.type == TimepointType.idle ? null : const EdgeInsets.all(8.0),
                child: _generateTypedTimepoint(timepointModel)
              )
            ],
          ),
        ),
      );
    });
  }
}
