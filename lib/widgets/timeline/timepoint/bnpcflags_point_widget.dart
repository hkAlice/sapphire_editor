import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/bnpcflags_point_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_schedule_model.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/timepoint_editor_scope.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/bnpcflags_toggle.dart';
import 'package:sapphire_editor/widgets/timeline/timeline_lookup.dart';
import 'package:signals/signals_flutter.dart';

class BNpcFlagsPointWidget extends StatefulWidget {
  final TimepointModel timepointModel;

  const BNpcFlagsPointWidget(
      {super.key,
  required this.timepointModel});

  @override
  State<BNpcFlagsPointWidget> createState() => _BNpcFlagsPointWidgetState();
}

class _BNpcFlagsPointWidgetState extends State<BNpcFlagsPointWidget> {
  late BNpcFlagsPointModel pointData =
      widget.timepointModel.data as BNpcFlagsPointModel;

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final scope = TimepointEditorScope.of(context);
      final signals = scope.signals;
      final lookup = TimelineNodeLookup.findActorSchedule(
          signals, scope.actorId, scope.scheduleId, scope.phaseId);
      if(lookup == null) {
        return const SizedBox.shrink();
      }

      final actor = lookup.actor;
      final schedule = lookup.schedule;

      return BNpcFlagsToggle(
          flags: pointData.flags,
          flagsMask: pointData.flagsMask,
          invulnType: pointData.invulnType,
          onUpdate: (flags, mask, invulnType) {
            pointData.flags = flags;
            pointData.flagsMask = mask;
            pointData.invulnType = invulnType;
            _updateTimepoint(signals, actor, schedule);
          });
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
