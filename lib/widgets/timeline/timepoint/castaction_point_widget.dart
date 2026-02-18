import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/castaction_point_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_schedule_model.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';
import 'package:sapphire_editor/utils/text_utils.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';
import 'package:sapphire_editor/widgets/signals_provider.dart';
import 'package:signals/signals_flutter.dart';

class CastActionPointWidget extends StatefulWidget {
  final TimepointModel timepointModel;

  const CastActionPointWidget({super.key, required this.timepointModel});

  @override
  State<CastActionPointWidget> createState() => _CastActionPointWidgetState();
}

class _CastActionPointWidgetState extends State<CastActionPointWidget> {
  late CastActionPointModel pointData = widget.timepointModel.data as CastActionPointModel;

  @override
  Widget build(BuildContext context) {
    final signals = SignalsProvider.of(context);
    
    return Watch((context) {
      final actor = signals.selectedActor.value;
      final schedule = signals.selectedSchedule.value;
      final timeline = signals.timeline.value;
      
      var validActors = List<String>.from(actor.subactors)..insert(0, actor.name);
      var selectedSelector = timeline.selectors.where((e) => e.name == pointData.selectorName).firstOrNull;
      var selectorCount = selectedSelector != null ? selectedSelector.count : 0;
      
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
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
          const SizedBox(width: 18.0,),
          SizedBox(
            width: 110,
            child: SimpleNumberField(
              label: "Action ID",
              initialValue: pointData.actionId,
              onChanged: (newValue) {
                pointData.actionId = newValue;
                _updateTimepoint(signals, actor, schedule);
              }
            ),
          ),
          const SizedBox(width: 18.0,),
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
          const SizedBox(width: 18.0,),
          SizedBox(
            width: 170,
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
            width: 70,
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