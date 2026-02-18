import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/bnpcdespawn_point_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_schedule_model.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:signals/signals_flutter.dart';

class BNpcDespawnPointWidget extends StatefulWidget {
  final TimepointModel timepointModel;
  final TimelineEditorSignal signals;

  const BNpcDespawnPointWidget({super.key, required this.timepointModel, required this.signals});

  @override
  State<BNpcDespawnPointWidget> createState() => _BNpcDespawnPointWidgetState();
}

class _BNpcDespawnPointWidgetState extends State<BNpcDespawnPointWidget> {
  late BNpcDespawnPointModel pointData = widget.timepointModel.data as BNpcDespawnPointModel;
  
  @override
  Widget build(BuildContext context) {
    final signals = widget.signals;
    return Watch((context) {
      final actor = signals.selectedActor.value;
      final schedule = signals.selectedSchedule.value;
      final timeline = signals.timeline.value;

      return Row(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 180,
                child: GenericItemPickerWidget<ActorModel>(
                  label: "Actor",
                  items: timeline.actors,
                  initialValue: timeline.actors.firstWhereOrNull((e) => e.name == pointData.despawnActor),
                  onChanged: (newValue) {
                    pointData.despawnActor = newValue.name;
                    _updateTimepoint(signals, actor, schedule);
                    },
                ),
              )
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