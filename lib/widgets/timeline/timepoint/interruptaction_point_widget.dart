import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/interruptaction_point_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_schedule_model.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';
import 'package:signals/signals_flutter.dart';

class InterruptActionPointWidget extends StatefulWidget {
  final TimepointModel timepointModel;
  final TimelineEditorSignal signals;

  const InterruptActionPointWidget({
    super.key,
    required this.timepointModel,
    required this.signals,
  });

  @override
  State<InterruptActionPointWidget> createState() => _InterruptActionPointWidgetState();
}

class _InterruptActionPointWidgetState extends State<InterruptActionPointWidget> {
  late InterruptActionPointModel pointData = widget.timepointModel.data as InterruptActionPointModel;
  
  @override
  Widget build(BuildContext context) {
    final signals = widget.signals;
    return Watch((context) {
      final actor = signals.selectedActor.value;
      final schedule = signals.selectedSchedule.value;

      var validActors = List<String>.from(actor.subactors)..insert(0, actor.name);

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
                  initialValue: validActors.firstWhereOrNull((e) => e == pointData.sourceActor),
                  onChanged: (newValue) {
                    pointData.sourceActor = newValue;
                    _updateTimepoint(signals, actor, schedule);
                    },
                ),
              ),
              const SizedBox(width: 18.0,),
              SizedBox(
                width: 140,
                child: SimpleNumberField(
                  label: "Action ID",
                  initialValue: pointData.actionId,
                  onChanged: (value) {
                    pointData.actionId = value;
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