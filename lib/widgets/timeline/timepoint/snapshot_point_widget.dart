import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/snapshot_point_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_schedule_model.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/timepoint_editor_scope.dart';
import 'package:sapphire_editor/widgets/timeline/timeline_lookup.dart';
import 'package:signals/signals_flutter.dart';

class SnapshotPointWidget extends StatefulWidget {
  final TimepointModel timepointModel;

  const SnapshotPointWidget({super.key, required this.timepointModel});

  @override
  State<SnapshotPointWidget> createState() => _SnapshotPointWidgetState();
}

class _SnapshotPointWidgetState extends State<SnapshotPointWidget> {
  late SnapshotPointModel pointData = widget.timepointModel.data as SnapshotPointModel;

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
      final timeline = signals.timeline.value;
      
      var validActors = List<String>.from(actor.subactors)..insert(0, actor.name);
      var setSelectorValue = timeline.selectors.firstWhereOrNull((e) => e.name == pointData.selectorName);

      return Row(
        children: [
          SizedBox(
            width: 180,
            child: GenericItemPickerWidget<String>(
              label: "Selector",
              items: timeline.selectors.map((e) => e.name).toList(),
              initialValue: setSelectorValue?.name,
              onChanged: (newValue) {
                pointData.selectorName = newValue;
                _updateTimepoint(signals, actor, schedule);
                },
            ),
          ),
          const SizedBox(width: 18.0),
          SizedBox(
            width: 200,
            child: GenericItemPickerWidget<String>(
              label: "Source Actor",
              items: validActors,
              initialValue: pointData.sourceActor,
              onChanged: (newValue) {
                pointData.sourceActor = newValue;
                _updateTimepoint(signals, actor, schedule);
                },
            ),
          ),
        ],
      );
    });
  }
  
  void _updateTimepoint(TimelineEditorSignal signals, ActorModel actor, TimelineScheduleModel schedule) {
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
    signals.updateTimepoint(actor.id, schedule.id, oldTimepoint.id, newTimepoint);
  }
}