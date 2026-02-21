import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/bnpcspawn_point_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_schedule_model.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/bnpcflags_toggle.dart';
import 'package:signals/signals_flutter.dart';
class BNpcSpawnPointWidget extends StatefulWidget {
  final TimepointModel timepointModel;
  final TimelineEditorSignal signals;
  final int? actorId;
  final int? scheduleId;

  const BNpcSpawnPointWidget(
      {super.key,
      required this.timepointModel,
      required this.signals,
      this.actorId,
      this.scheduleId});

  @override
  State<BNpcSpawnPointWidget> createState() => _BNpcSpawnPointWidgetState();
}

class _BNpcSpawnPointWidgetState extends State<BNpcSpawnPointWidget> {
  late BNpcSpawnPointModel pointData =
      widget.timepointModel.data as BNpcSpawnPointModel;

  @override
  Widget build(BuildContext context) {
    final signals = widget.signals;
    return Watch((context) {
      final timeline = signals.timeline.value;
      final actor = widget.actorId != null
          ? timeline.actors.firstWhere((a) => a.id == widget.actorId)
          : signals.selectedActor.value;
      final schedule = widget.scheduleId != null
          ? actor.schedules.firstWhere((s) => s.id == widget.scheduleId)
          : signals.selectedSchedule.value;

      return Row(
        children: [
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 180,
                    child: GenericItemPickerWidget<ActorModel>(
                      label: "Actor",
                      items: timeline.actors,
                      initialValue: timeline.actors.firstWhereOrNull(
                          (e) => e.name == pointData.spawnActor),
                      onChanged: (newValue) {
                        pointData.spawnActor = newValue.name;
                        _updateTimepoint(signals, actor, schedule);
                      },
                    ),
                  )
                ],
              )
            ],
          )),
          BNpcFlagsToggle(
              flags: pointData.flags,
              flagsMask: pointData.flagsMask,
              invulnType: pointData.invulnType,
              isDense: true,
              onUpdate: (flags, mask, invulnType) {
                pointData.flags = flags;
                pointData.flagsMask = mask;
                pointData.invulnType = invulnType;
                _updateTimepoint(signals, actor, schedule);
              }),
        ],
      );
    });
  }

  void _updateTimepoint(TimelineEditorSignal signals, ActorModel actor,
      TimelineScheduleModel schedule) {
    final oldTimepoint =
        schedule.timepoints.firstWhere((t) => t.id == widget.timepointModel.id);
    final newTimepoint = TimepointModel(
      id: oldTimepoint.id,
      type: oldTimepoint.type,
      startTime: oldTimepoint.startTime,
      data: pointData,
    );
    signals.updateTimepoint(
        actor.id, schedule.id, oldTimepoint.id, newTimepoint);
  }
}
