import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/bnpcspawn_point_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_schedule_model.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/timepoint_editor_scope.dart';
import 'package:sapphire_editor/widgets/timeline/timeline_lookup.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/bnpcflags_toggle.dart';
import 'package:signals/signals_flutter.dart';
class BNpcSpawnPointWidget extends StatefulWidget {
  final TimepointModel timepointModel;

  const BNpcSpawnPointWidget(
      {super.key,
  required this.timepointModel});

  @override
  State<BNpcSpawnPointWidget> createState() => _BNpcSpawnPointWidgetState();
}

class _BNpcSpawnPointWidgetState extends State<BNpcSpawnPointWidget> {
  late BNpcSpawnPointModel pointData =
      widget.timepointModel.data as BNpcSpawnPointModel;

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final scope = TimepointEditorScope.of(context);
      final signals = scope.signals;
      final timeline = signals.timeline.value;
      final lookup = TimelineNodeLookup.findActorSchedule(
          signals, scope.actorId, scope.scheduleId, scope.phaseId);
      if(lookup == null) {
        return const SizedBox.shrink();
      }

      final actor = lookup.actor;
      final schedule = lookup.schedule;

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
                child: GenericItemPickerWidget<String>(
                  label: "Spawn Actor",
                  items: timeline.actors.map((e) => e.name).toList(),
                  initialValue: pointData.spawnActor,
                  onChanged: (newValue) {
                    pointData.spawnActor = newValue;
                    _updateTimepoint(signals, actor, schedule);
                  }
                ),
              ),
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
        TimelineNodeLookup.findTimepointInSchedule(schedule, widget.timepointModel.id);
    if(oldTimepoint == null) {
      return;
    }

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
