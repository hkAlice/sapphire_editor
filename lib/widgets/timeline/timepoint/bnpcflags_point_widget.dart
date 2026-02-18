import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/bnpcflags_point_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_schedule_model.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';
import 'package:sapphire_editor/widgets/signals_provider.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/bnpcflags_toggle.dart';
import 'package:signals/signals_flutter.dart';

class BNpcFlagsPointWidget extends StatefulWidget {
  final TimepointModel timepointModel;

  const BNpcFlagsPointWidget({super.key, required this.timepointModel});

  @override
  State<BNpcFlagsPointWidget> createState() => _BNpcFlagsPointWidgetState();
}

class _BNpcFlagsPointWidgetState extends State<BNpcFlagsPointWidget> {
  late BNpcFlagsPointModel pointData = widget.timepointModel.data as BNpcFlagsPointModel;

  @override
  Widget build(BuildContext context) {
    final signals = SignalsProvider.of(context);
    
    return Watch((context) {
      final actor = signals.selectedActor.value;
      final schedule = signals.selectedSchedule.value;
      
      return BNpcFlagsToggle(
        flags: pointData.flags,
        onUpdate: (newFlags) {
          pointData.flags = newFlags;
          _updateTimepoint(signals, actor, schedule);
        }
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