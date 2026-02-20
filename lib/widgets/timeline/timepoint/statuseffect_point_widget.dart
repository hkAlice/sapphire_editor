import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/castaction_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/statuseffect_point_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_schedule_model.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';
import 'package:sapphire_editor/utils/text_utils.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';
import 'package:sapphire_editor/widgets/switch_text_widget.dart';
import 'package:signals/signals_flutter.dart';

class StatusEffectPointWidget extends StatefulWidget {
  final TimepointModel timepointModel;
  final TimelineEditorSignal signals;

  const StatusEffectPointWidget(
      {super.key, required this.timepointModel, required this.signals});

  @override
  State<StatusEffectPointWidget> createState() =>
      _StatusEffectPointWidgetState();
}

class _StatusEffectPointWidgetState extends State<StatusEffectPointWidget> {
  late StatusEffectPointModel pointData =
      widget.timepointModel.data as StatusEffectPointModel;

  @override
  Widget build(BuildContext context) {
    final signals = widget.signals;

    return Watch((context) {
      final actor = signals.selectedActor.value;
      final schedule = signals.selectedSchedule.value;
      final timeline = signals.timeline.value;

      var validActors = List<String>.from(actor.subactors)
        ..insert(0, actor.name);
      var selectedSelector = timeline.selectors
          .where((e) => e.name == pointData.selectorName)
          .firstOrNull;
      var selectorCount = selectedSelector != null ? selectedSelector.count : 0;

      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
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
          const SizedBox(width: 8.0),
          SizedBox(
            width: 110,
            child: GenericItemPickerWidget<ActorTargetType>(
              label: "Target Type",
              items: ActorTargetType.values,
              initialValue: pointData.targetType,
              propertyBuilder: (value) => treatEnumName(value),
              onChanged: (newValue) {
                pointData.targetType = newValue;
                _updateTimepoint(signals, actor, schedule);
              },
            ),
          ),
          const SizedBox(width: 8.0),
          SizedBox(
            width: 140,
            child: GenericItemPickerWidget<String>(
              label: "Target Selector",
              items: timeline.selectors.map((e) => e.name).toList(),
              initialValue: pointData.selectorName,
              enabled: pointData.targetType == ActorTargetType.selectorPos ||
                  pointData.targetType == ActorTargetType.selectorTarget,
              onChanged: (newValue) {
                pointData.selectorName = newValue;
                _updateTimepoint(signals, actor, schedule);
              },
            ),
          ),
          SizedBox(
            width: 60,
            child: GenericItemPickerWidget<String>(
              label: "#",
              items: List.generate(selectorCount, (e) => (e + 1).toString()),
              initialValue: (pointData.selectorIndex + 1).toString(),
              enabled: pointData.targetType == ActorTargetType.selectorPos ||
                  pointData.targetType == ActorTargetType.selectorTarget,
              onChanged: (newValue) {
                pointData.selectorIndex = int.parse(newValue) - 1;
                _updateTimepoint(signals, actor, schedule);
              },
            ),
          ),
          const SizedBox(width: 8.0),
          SizedBox(
            width: 80,
            child: SimpleNumberField(
                label: "Status ID",
                initialValue: pointData.statusId,
                onChanged: (newValue) {
                  pointData.statusId = newValue;
                  _updateTimepoint(signals, actor, schedule);
                }),
          ),
          const SizedBox(width: 8.0),
          SizedBox(
            width: 90,
            child: SimpleNumberField(
                label: "Duration (ms)",
                initialValue: pointData.duration,
                enabled: !pointData.isRemove,
                onChanged: (newValue) {
                  pointData.duration = newValue;
                  _updateTimepoint(signals, actor, schedule);
                }),
          ),
          const SizedBox(width: 8.0),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: SwitchTextWidget(
              enabled: pointData.isRemove,
              onPressed: () {
                pointData.isRemove = !pointData.isRemove;
                _updateTimepoint(signals, actor, schedule);
              },
              toggleText: ("Add", "Remove"),
              leading: const Text("Action"),
            ),
          ),
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
