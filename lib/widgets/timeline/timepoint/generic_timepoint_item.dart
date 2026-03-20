import 'package:disable_web_context_menu/disable_web_context_menu.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final int? phaseId;
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
      if(TimelineNodeLookup.isPhaseHookScheduleId(scheduleId)) {
        final resolvedPhaseId = phaseId ?? signals.selectedPhaseId.value;
        return TimelineNodeLookup.findPhaseHookTimepoint(
          signals,
          actorId,
          resolvedPhaseId,
          scheduleId,
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
            final RenderBox overlay =
                Overlay.of(context).context.findRenderObject() as RenderBox;
            showMenu<String>(
              context: context,
              position: RelativeRect.fromRect(
                Rect.fromLTWH(
                    details.globalPosition.dx, details.globalPosition.dy, 0, 0),
                Offset.zero & overlay.size,
              ),
              items: [
                const PopupMenuItem(
                    value: 'duplicate',
                    child: Row(children: [
                      Icon(Icons.copy_rounded, size: 16),
                      SizedBox(width: 8),
                      Text('Duplicate')
                    ])),
                const PopupMenuDivider(),
                const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_rounded,
                          size: 16, color: Colors.redAccent),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.redAccent))
                    ])),
              ],
            ).then((value) {
              if(value == null) return;
              final resolvedPhaseId = phaseId ?? signals.selectedPhaseId.value;
              if(resolvedPhaseId == null) {
                return;
              }

              final resolvedScheduleId = scheduleId;
              if(value == 'duplicate') {
                signals.duplicateTimepointInPhase(actorId, resolvedPhaseId,
                    resolvedScheduleId, timepointModel);
              } else if(value == 'delete') {
                signals.removeTimepointInPhase(actorId, resolvedPhaseId,
                    resolvedScheduleId, timepointModel);
              }
            });
          },
          child: Material(
            color: const Color(0xFF1E1E1E),
            shape: Border(
              left: BorderSide(
                  color: timepointModel.getColorForTimepointType(),
                  width: 2.0),
              top: const BorderSide(color: Color(0xFF333333), width: 1.0),
              right: const BorderSide(color: Color(0xFF333333), width: 1.0),
              bottom: const BorderSide(color: Color(0xFF333333), width: 1.0),
            ),
            child: InkWell(
              hoverColor: const Color(0xFF2C2C2C),
              splashColor: const Color(0xFF444444),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 45,
                        alignment: Alignment.centerRight,
                        child: Text(
                          _formatTime(timepointModel.startTime),
                          style: GoogleFonts.lilex(
                            textStyle: const TextStyle(
                              color: Color(0xFFAAAAAA),
                              fontSize: 12.0,
                            ),
                          ),
                          maxLines: 1,
                        ),
                      ),
                      const VerticalDivider(width: 8.0, thickness: 1.0, color: Color(0xFF333333)),
                      Container(
                        width: 110,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          treatEnumName(timepointModel.type),
                          style: GoogleFonts.lilex(
                            textStyle: const TextStyle(
                              color: Color(0xFFDDDDDD),
                              fontSize: 12.0,
                            ),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const VerticalDivider(width: 8.0, thickness: 1.0, color: Color(0xFF333333)),
                      Expanded(
                        child: Text(
                          timepointModel.data.toString(),
                          style: GoogleFonts.lilex(
                            textStyle: const TextStyle(
                              color: Color(0xFFDDDDDD),
                              fontSize: 12.0,
                            ),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          ),
      );
    });
  }
}

class TimepointEditorWidget extends StatefulWidget {
  final int? phaseId;
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
      final isPhaseHook =
          TimelineNodeLookup.isPhaseHookScheduleId(widget.scheduleId);
      final resolvedPhaseId = widget.phaseId ?? signals.selectedPhaseId.value;
      final actor = TimelineNodeLookup.findActor(signals, widget.actorId);
      final phase = isPhaseHook
          ? TimelineNodeLookup.findPhase(
              signals, widget.actorId, resolvedPhaseId)
          : null;
      final lookup = isPhaseHook
          ? null
          : TimelineNodeLookup.resolveTimepoint(
              signals, widget.actorId, widget.scheduleId, widget.timepointId);
      final timepointModel = isPhaseHook
          ? TimelineNodeLookup.findPhaseHookTimepoint(signals, widget.actorId,
              resolvedPhaseId, widget.scheduleId, widget.timepointId)
          : lookup?.timepoint;
      final schedule = lookup?.schedule;
      final updatePhaseId =
          widget.phaseId ?? phase?.id ?? signals.selectedPhaseId.value;

      if(updatePhaseId == null ||
          actor == null ||
          timepointModel == null ||
          (!isPhaseHook && schedule == null) ||
          (isPhaseHook && phase == null)) {
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
            Text(timepointModel.data.toString()),
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
                              isPhaseHook ? widget.scheduleId : schedule!.id,
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
                                isPhaseHook ? widget.scheduleId : schedule!.id,
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
                                isPhaseHook ? widget.scheduleId : schedule!.id,
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
                    scheduleId: schedule?.id ?? widget.scheduleId,
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
