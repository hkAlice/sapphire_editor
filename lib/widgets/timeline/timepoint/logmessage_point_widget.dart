import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/logmessage_point_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_schedule_model.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';
import 'package:signals/signals_flutter.dart';

class LogMessagePointWidget extends StatefulWidget {
  final TimepointModel timepointModel;
  final TimelineEditorSignal signals;

  const LogMessagePointWidget({super.key, required this.timepointModel, required this.signals});

  @override
  State<LogMessagePointWidget> createState() => _LogMessagePointWidgetState();
}

class _LogMessagePointWidgetState extends State<LogMessagePointWidget> {
  late TextEditingController _logMsgTextEditingController;
  late TextEditingController _paramsTextEditingController;

  late LogMessagePointModel pointData = widget.timepointModel.data as LogMessagePointModel;

  @override
  void initState() {
    _logMsgTextEditingController = TextEditingController(text: pointData.messageId.toString());
    _paramsTextEditingController = TextEditingController(text: pointData.params.join(", "));

    super.initState();
  }

  @override
  void dispose() {
    _logMsgTextEditingController.dispose();
    _paramsTextEditingController.dispose();

    super.dispose();
  }

  Widget _generateStrSplitInput({required TextEditingController textEditingController, required String label, required Function(String) onChanged}) {
    return SizedBox(
      width: 180,
      child: TextFormField(
        maxLines: 1,
        controller: textEditingController,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          label: Text(label),
        ),
        onChanged: (value) { onChanged(value); }
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final signals = widget.signals;
    return Watch((context) {
      final actor = signals.selectedActor.value;
      final schedule = signals.selectedSchedule.value;

      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: SimpleNumberField(
              label: "Message ID",
              initialValue: pointData.messageId,
              onChanged: (value) {
                pointData.messageId = value;
                _updateTimepoint(signals, actor, schedule);
              }
            ),
          ),
          const SizedBox(width: 18.0,),
          _generateStrSplitInput(
            textEditingController: _paramsTextEditingController,
            label: "Params (split by ,)",
            onChanged: (value) {
              try {
                var listParams = value.split(",").map((e) => int.parse(e)).toList();
                pointData.params = listParams;
                _updateTimepoint(signals, actor, schedule);
              }
              catch(_) { }

              }
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