import 'package:disable_web_context_menu/disable_web_context_menu.dart';
import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/utils/text_utils.dart';
import 'package:sapphire_editor/widgets/number_button.dart';
import 'package:sapphire_editor/widgets/text_modal_editor_widget.dart';
import 'package:sapphire_editor/widgets/signals_provider.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/timepoint_editor_registry.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/timepoint_editor_scope.dart';
import 'package:sapphire_editor/widgets/timeline/timeline_lookup.dart';
import 'package:signals_flutter/signals_flutter.dart';

class GenericTimepointItem extends StatelessWidget {
  final String? phaseId;
  final int timepointId;
  final int scheduleIndex;
  final int scheduleId;
  final int timepointIndex;
  final int timeElapsedMs;
  final int actorId;

  const GenericTimepointItem(
      {super.key,
      this.phaseId,
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
      if(scheduleId < 0) {
        final resolvedPhaseId = phaseId ?? signals.selectedPhaseId.value;
        return TimelineNodeLookup.findOnEnterTimepoint(
          signals,
          actorId,
          resolvedPhaseId,
          timepointId,
        );
      }

      final lookup = TimelineNodeLookup.resolveTimepoint(
          signals, actorId, scheduleId, timepointId);
      return lookup?.timepoint;
    });

    return Watch((context) {
      final timepointModel = timepointSignal.value;
      if(timepointModel == null) {
        return const SizedBox.shrink();
      }

      return DisableWebContextMenu(
        child: GestureDetector(
          onSecondaryTapUp: (details) {
            final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
            showMenu<String>(
              context: context,
              position: RelativeRect.fromRect(
                Rect.fromLTWH(details.globalPosition.dx, details.globalPosition.dy, 0, 0),
                Offset.zero & overlay.size,
              ),
              items: [
                const PopupMenuItem(value: 'duplicate', child: Row(children: [Icon(Icons.copy_rounded, size: 16), SizedBox(width: 8), Text('Duplicate')])),
                const PopupMenuDivider(),
                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_rounded, size: 16, color: Colors.redAccent), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.redAccent))])),
              ],
            ).then((value) {
              if(value == null) return;
              final resolvedPhaseId = phaseId ?? signals.selectedPhaseId.value;
              if(resolvedPhaseId == null) {
                return;
              }

              final resolvedScheduleId = scheduleId < 0 ? null : scheduleId;
              if(value == 'duplicate') {
                signals.duplicateTimepointInPhase(
                    actorId, resolvedPhaseId, resolvedScheduleId, timepointModel);
              }
              else if(value == 'delete') {
                signals.removeTimepointInPhase(
                    actorId, resolvedPhaseId, resolvedScheduleId, timepointModel);
              }
            });
          },
          child: InkWell(
            onTap: () async {
              showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return SignalsProvider(
                    signals: signals,
                    child: TimepointEditorWidget(
                      phaseId: phaseId,
                      scheduleId: scheduleId,
                      timepointId: timepointModel.id,
                      actorId: actorId,
                    ),
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
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ),
        ),
      );
    });
  }
}

class TimepointEditorWidget extends StatefulWidget {
  final String? phaseId;
  final int scheduleId;
  final int timepointId;
  final int actorId;

  const TimepointEditorWidget({
    super.key,
    this.phaseId,
    required this.scheduleId,
    required this.timepointId,
    required this.actorId,
  });

  @override
  State<TimepointEditorWidget> createState() => _TimepointEditorWidgetState();
}

class _TimepointEditorWidgetState extends State<TimepointEditorWidget> {
  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final signals = SignalsProvider.of(context);
      final isOnEnter = widget.scheduleId < 0;
      final resolvedPhaseId = widget.phaseId ?? signals.selectedPhaseId.value;
      final actor = TimelineNodeLookup.findActor(signals, widget.actorId);
      final phase = isOnEnter
          ? TimelineNodeLookup.findPhase(signals, widget.actorId, resolvedPhaseId)
          : null;
      final lookup = isOnEnter
          ? null
          : TimelineNodeLookup.resolveTimepoint(
              signals, widget.actorId, widget.scheduleId, widget.timepointId);
      final timepointModel = isOnEnter
          ? TimelineNodeLookup.findOnEnterTimepoint(
              signals, widget.actorId, resolvedPhaseId, widget.timepointId)
          : lookup?.timepoint;
      final schedule = lookup?.schedule;
          final updatePhaseId =
            widget.phaseId ?? phase?.id ?? signals.selectedPhaseId.value;

          if(updatePhaseId == null ||
            actor == null ||
          timepointModel == null ||
          (!isOnEnter && schedule == null) ||
          (isOnEnter && phase == null)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if(!mounted) {
            return;
          }

          final navigator = Navigator.of(context);
          if(navigator.canPop()) {
            navigator.pop();
          }
        });
        return const SizedBox.shrink();
      }

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
                          signals.updateTimepointInPhase(
                              actor.id,
                              updatePhaseId,
                              isOnEnter ? null : schedule!.id,
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

                            signals.updateTimepointInPhase(
                                actor.id,
                                updatePhaseId,
                                isOnEnter ? null : schedule!.id,
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
                            signals.updateTimepointInPhase(
                                actor.id,
                                updatePhaseId,
                                isOnEnter ? null : schedule!.id,
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
                  child: TimepointEditorScope(
                    signals: signals,
                    actorId: actor.id,
                    phaseId: updatePhaseId,
                    scheduleId: schedule?.id ?? -1,
                    timepointId: timepointModel.id,
                    child: TimepointEditorRegistry.buildEditor(
                      TimepointEditorContext(
                        timepointModel: timepointModel,
                      ),
                    ),
                  ))
            ],
          ),
        ),
      );
    });
  }
}
