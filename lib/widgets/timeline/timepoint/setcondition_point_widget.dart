import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/condition/condition_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/setcondition_point_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_schedule_model.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/signals_provider.dart';
import 'package:sapphire_editor/widgets/switch_text_widget.dart';
import 'package:signals/signals_flutter.dart';

class SetConditionPointWidget extends StatefulWidget {
  final TimepointModel timepointModel;

  const SetConditionPointWidget({super.key, required this.timepointModel});

  @override
  State<SetConditionPointWidget> createState() => _SetConditionPointWidgetState();
}

class _SetConditionPointWidgetState extends State<SetConditionPointWidget> {
  late SetConditionPointModel pointData = widget.timepointModel.data as SetConditionPointModel;

  @override
  Widget build(BuildContext context) {
    final signals = SignalsProvider.of(context);
    return Watch((context) {
      final actor = signals.selectedActor.value;
      final schedule = signals.selectedSchedule.value;
      final timeline = signals.timeline.value;

      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 500,
            child: GenericItemPickerWidget<ConditionModel>(
              label: "Condition",
              items: timeline.conditions,
              initialValue: timeline.conditions.firstWhereOrNull((e) => e.id == pointData.conditionId) ?? timeline.conditions.first,
              propertyBuilder: (value) {
                return "(ID: ${value.id}) ${value.getReadableConditionStr()}";
              },
              onChanged: (newValue) {
                pointData.conditionId = newValue.id;
                pointData.conditionStr = newValue.getReadableConditionStr();
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
    final oldTimepoint = schedule.timepoints
    .firstWhere((t) => t.id == widget.timepointModel.id);
    final newTimepoint = TimepointModel(
      id: oldTimepoint.id,
      type: oldTimepoint.type,
      startTime: oldTimepoint.startTime,
      data: pointData,
    );
    signals.updateTimepoint(actor.id, schedule.id, oldTimepoint.id, newTimepoint);
  }
}