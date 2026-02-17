import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/setbgm_point_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_schedule_model.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';
import 'package:sapphire_editor/widgets/signals_provider.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';
import 'package:signals/signals_flutter.dart';

class SetBgmPointWidget extends StatefulWidget {
  final TimepointModel timepointModel;

  const SetBgmPointWidget({super.key, required this.timepointModel});

  @override
  State<SetBgmPointWidget> createState() => _SetBgmPointWidgetState();
}

class _SetBgmPointWidgetState extends State<SetBgmPointWidget> {
  late TextEditingController _bgmTextEditingController;

  late SetBgmPointModel pointData = widget.timepointModel.data as SetBgmPointModel;

  @override
  void initState() {
    _bgmTextEditingController = TextEditingController(text: pointData.bgmId.toString());

    super.initState();
  }

  @override
  void dispose() {
    _bgmTextEditingController.dispose();

    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final signals = SignalsProvider.of(context);
    return Watch((context) {
      final actor = signals.selectedActor.value;
      final schedule = signals.selectedSchedule.value;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 180,
            child: SimpleNumberField(
              label: "BGM ID",
              initialValue: pointData.bgmId,
              onChanged: (value) {
                pointData.bgmId = value;
                _updateTimepoint(signals, actor, schedule);
              }
            ),
          ),
        ],
      );
    });
  }

  void _updateTimepoint(TimelineEditorSignal signals, ActorModel actor, TimelineScheduleModel schedule) {
    final oldTimepoint = schedule.timepoints.firstWhere((t) => t == widget.timepointModel);
    final newTimepoint = TimepointModel(
      type: oldTimepoint.type,
      startTime: oldTimepoint.startTime,
      data: pointData,
    );
    signals.updateTimepoint(actor, schedule, oldTimepoint, newTimepoint);
  }
}