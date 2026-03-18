import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/actiontimeline_point_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_schedule_model.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/timepoint_editor_scope.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';
import 'package:sapphire_editor/widgets/timeline/timeline_lookup.dart';
import 'package:signals/signals_flutter.dart';

class ActionTimelinePointWidget extends StatefulWidget {
  final TimepointModel timepointModel;

  const ActionTimelinePointWidget({super.key, required this.timepointModel});

  @override
  State<ActionTimelinePointWidget> createState() => _ActionTimelinePointWidgetState();
}

class _ActionTimelinePointWidgetState extends State<ActionTimelinePointWidget> {
  late ActionTimelinePointModel pointData = widget.timepointModel.data as ActionTimelinePointModel;

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
      var validActors = List<String>.from(signals.timeline.value.actors.map((e) => e.name));

      return Row(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 180,
                child: GenericItemPickerWidget<String>(
                  label: "Actor",
                  items: validActors,
                  initialValue: validActors.firstWhereOrNull((e) => e == pointData.actorName),
                  onChanged: (newValue) {
                    pointData.actorName = newValue;
                    _updateTimepoint(signals, actor, schedule);
                  },
                ),
              ),
              const SizedBox(width: 18.0,),
              SizedBox(
                width: 140,
                child: SimpleNumberField(
                  label: "ActionTimeline ID",
                  initialValue: pointData.actionTimelineId,
                  onChanged: (value) {
                    pointData.actionTimelineId = value;
                    _updateTimepoint(signals, actor, schedule);
                  }
                ),
              ),
            ],
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