import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/condition/trigger_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/settrigger_point_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_schedule_model.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/switch_text_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/timepoint_editor_scope.dart';
import 'package:sapphire_editor/widgets/timeline/timeline_lookup.dart';
import 'package:signals/signals_flutter.dart';

class SetTriggerPointWidget extends StatefulWidget {
  final TimepointModel timepointModel;

  const SetTriggerPointWidget({super.key, required this.timepointModel});

  @override
  State<SetTriggerPointWidget> createState() => _SetTriggerPointWidgetState();
}

class _SetTriggerPointWidgetState extends State<SetTriggerPointWidget> {
  late SetTriggerPointModel pointData = widget.timepointModel.data as SetTriggerPointModel;

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

      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 500,
            child: GenericItemPickerWidget<TriggerModel>(
              label: "Trigger",
              items: timeline.conditions,
              initialValue: timeline.conditions.firstWhereOrNull((e) => e.id == pointData.triggerId) ?? timeline.conditions.first,
              propertyBuilder: (value) {
                return "(ID: ${value.id}) ${value.getReadableConditionStr()}";
              },
              onChanged: (newValue) {
                pointData.triggerId = newValue.id;
                pointData.triggerStr = newValue.getReadableConditionStr();
                _updateTimepoint(signals, actor, schedule);
                },
            ),
          ),
          const SizedBox(width: 18.0,),
          SwitchTextWidget(
            enabled: pointData.enabled,
            onPressed: () {
              pointData.enabled = !pointData.enabled;
              _updateTimepoint(signals, actor, schedule);
              }
          )
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