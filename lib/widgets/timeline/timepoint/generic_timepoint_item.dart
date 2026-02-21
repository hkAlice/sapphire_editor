import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';
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
import 'package:sapphire_editor/widgets/timeline/timepoint/statuseffect_point_widget.dart';
import 'package:sapphire_editor/widgets/signals_provider.dart';
import 'package:signals_flutter/signals_flutter.dart';

class GenericTimepointItem extends StatelessWidget {
  final int timepointId;
  final int scheduleIndex;
  final int scheduleId;
  final int timepointIndex;
  final int timeElapsedMs;
  final int actorId;

  const GenericTimepointItem(
      {super.key,
      required this.timepointId,
      required this.scheduleIndex,
      required this.scheduleId,
      required this.timepointIndex,
      required this.timeElapsedMs,
      required this.actorId});

  String _formatTime(int startTimeMs) {
    Duration startTime = Duration(milliseconds: startTimeMs);

    if(startTime.inHours > 0) {
      int hours = startTime.inHours;
      int minutes = startTime.inMinutes % 60;
      int seconds = startTime.inSeconds % 60;
      return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
    } else {
      // Show as decimal seconds (e.g., 3.0s for 3000ms)
      double secondsAsDouble = startTimeMs / 1000.0;
      return "${secondsAsDouble.toStringAsFixed(1)}s";
    }
  }

  @override
  Widget build(BuildContext context) {
    final signals = SignalsProvider.of(context);

    final timepointSignal = computed(() {
      final actor =
          signals.timeline.value.actors.firstWhere((a) => a.id == actorId);
      final schedule = actor.schedules.firstWhere((s) => s.id == scheduleId);
      return schedule.timepoints.firstWhere((t) => t.id == timepointId);
    });

    return Watch((context) {
      final timepointModel = timepointSignal.value;

      return InkWell(
        onTap: () async {
          showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return TimepointEditorWidget(
                scheduleId: scheduleId,
                timepointId: timepointModel.id,
                actorId: actorId,
                signals:
                    signals, // dialog loses context since signalprovider doesn't wrap runApp()
              );
            },
          );
        },
        child: Container(
            decoration: BoxDecoration(
                color: Colors.black12,
                border: Border(
                    left: BorderSide(
                        color: timepointModel.getColorForTimepointType(),
                        width: 2.0),
                    top: BorderSide(
                        color: Colors.grey.shade800.withAlpha(150),
                        width: 1.0))),
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
                          child: SizedBox(
                            width: 40,
                            child: Opacity(
                                opacity: 0.7,
                                child: Text(
                                  _formatTime(timepointModel.startTime),
                                  style:
                                      Theme.of(context).textTheme.labelSmall,
                                  maxLines: 1,
                                  textAlign: TextAlign.right,
                                )),
                          ),
                        ),
                        const VerticalDivider(),
                        Container(
                            width: 110,
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Text(
                              treatEnumName(timepointModel.type),
                              style: Theme.of(context).textTheme.bodyMedium,
                            )),
                        const VerticalDivider(),
                        Expanded(
                            child: Text(
                          timepointModel.data.toString(),
                          style: Theme.of(context).textTheme.bodySmall,
                        )),
                        const VerticalDivider(),
                        SizedBox(
                          width: 24.0,
                          height: 24.0,
                          child: IconButton(
                            padding: const EdgeInsets.all(0.0),
                            icon: const Icon(
                              Icons.copy,
                              size: 16.0,
                            ),
                            splashRadius: 14.0,
                            onPressed: () {
                              signals.duplicateTimepoint(
                                  signals.selectedSchedule.value,
                                  timepointModel,
                                  actorId);
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 4.0,
                        ),
                        SizedBox(
                          width: 24.0,
                          height: 24.0,
                          child: IconButton(
                            padding: const EdgeInsets.all(0.0),
                            icon: const Icon(
                              Icons.clear_rounded,
                              size: 16.0,
                            ),
                            splashRadius: 14.0,
                            onPressed: () {
                              signals.removeTimepoint(
                                  signals.selectedSchedule.value,
                                  timepointModel,
                                  actorId);
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 4.0,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      );
    });
  }
}

class TimepointEditorWidget extends StatefulWidget {
  final int scheduleId;
  final int timepointId;
  final int actorId;
  final TimelineEditorSignal signals;

  const TimepointEditorWidget({
    super.key,
    required this.scheduleId,
    required this.timepointId,
    required this.actorId,
    required this.signals,
  });

  @override
  State<TimepointEditorWidget> createState() => _TimepointEditorWidgetState();
}

class _TimepointEditorWidgetState extends State<TimepointEditorWidget> {
  Widget _generateTypedTimepoint(TimepointModel tp) {
    final signals = widget.signals;

    switch (tp.type) {
      case TimepointType.actionTimeline:
        return ActionTimelinePointWidget(timepointModel: tp, signals: signals);
      case TimepointType.castAction:
        return CastActionPointWidget(timepointModel: tp, signals: signals);
      case TimepointType.battleTalk:
        return BattleTalkPointWidget(timepointModel: tp, signals: signals);
      case TimepointType.bNpcDespawn:
        return BNpcDespawnPointWidget(timepointModel: tp, signals: signals);
      case TimepointType.bNpcFlags:
        return BNpcFlagsPointWidget(
            timepointModel: tp,
            signals: signals,
            actorId: widget.actorId,
            scheduleId: widget.scheduleId);
      case TimepointType.bNpcSpawn:
        return BNpcSpawnPointWidget(
            timepointModel: tp,
            signals: signals,
            actorId: widget.actorId,
            scheduleId: widget.scheduleId);
      case TimepointType.directorFlags:
        return DirectorFlagsPointWidget(timepointModel: tp, signals: signals);
      case TimepointType.directorSeq:
        return DirectorSeqPointWidget(timepointModel: tp, signals: signals);
      case TimepointType.directorVar:
        return DirectorVarPointWidget(timepointModel: tp, signals: signals);
      case TimepointType.idle:
        return IdlePointWidget(timepointModel: tp, signals: signals);
      case TimepointType.logMessage:
        return LogMessagePointWidget(timepointModel: tp, signals: signals);
      case TimepointType.setBGM:
        return SetBgmPointWidget(timepointModel: tp, signals: signals);
      case TimepointType.setCondition:
        return SetConditionPointWidget(timepointModel: tp, signals: signals);
      case TimepointType.setPos:
        return SetPosPointWidget(timepointModel: tp, signals: signals);
      case TimepointType.snapshot:
        return SnapshotPointWidget(timepointModel: tp, signals: signals);
      case TimepointType.interruptAction:
        return InterruptActionPointWidget(timepointModel: tp, signals: signals);
      case TimepointType.rollRNG:
        return RollRNGPointWidget(timepointModel: tp, signals: signals);
      case TimepointType.statusEffect:
        return StatusEffectPointWidget(timepointModel: tp, signals: signals);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final signals = widget.signals;

      final actor = signals.timeline.value.actors
          .firstWhere((a) => a.id == widget.actorId);
      final schedule =
          actor.schedules.firstWhere((s) => s.id == widget.scheduleId);
      final timepointModel =
          schedule.timepoints.firstWhere((t) => t.id == widget.timepointId);

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
                        builder: (value) {
                          var seconds = value / 1000;
                          return "${seconds.toStringAsFixed(1)}s";
                        },
                        stepCount: 100,
                        onChanged: (value) {
                          final newTp =
                              timepointModel.copyWith(startTime: value);
                          signals.updateTimepoint(
                              actor.id,
                              schedule.id,
                              timepointModel.id,
                              newTp);
                        }),
                    const SizedBox(
                      width: 18.0,
                    ),
                    SizedBox(
                      width: 180,
                      child: DropdownButtonFormField<TimepointType>(
                          decoration: const InputDecoration(
                              filled: false,
                              labelText: "Point type",
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(10.5)),
                          initialValue: timepointModel.type,
                          isDense: true,
                          onChanged: (TimepointType? value) {
                            if(value == null) {
                              return;
                            }

                            timepointModel.changeType(value);

                            signals.updateTimepoint(
                                actor.id,
                                schedule.id,
                                timepointModel.id,
                                timepointModel);
                          },
                          items: TimepointType.values.map((TimepointType type) {
                            return DropdownMenuItem<TimepointType>(
                                value: type, child: Text(treatEnumName(type)));
                          }).toList()),
                    ),
                    const SizedBox(
                      width: 18.0,
                    ),
                    Expanded(
                      child: SizedBox(
                          height: 54.0,
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                timepointModel.description,
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.fade,
                              ))),
                    ),
                    SizedBox(
                      height: 54.0,
                      child: TextModalEditorWidget(
                          text: timepointModel.description,
                          headerText: "Edit timepoint description",
                          onChanged: (description) {
                            final newTp = timepointModel.copyWith(
                                description: description);
                            signals.updateTimepoint(
                                actor.id,
                                schedule.id,
                                timepointModel.id,
                                newTp);
                          }),
                    ),
                  ],
                ),
              ),
              Container(
                  color: Colors.black12,
                  padding: timepointModel.type == TimepointType.idle
                      ? null
                      : const EdgeInsets.all(8.0),
                  child: _generateTypedTimepoint(timepointModel))
            ],
          ),
        ),
      );
    });
  }
}
