import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/logmessage_point_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_schedule_model.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/timepoint_editor_scope.dart';
import 'package:sapphire_editor/widgets/timeline/timeline_lookup.dart';
import 'package:signals/signals_flutter.dart';

class LogMessagePointWidget extends StatefulWidget {
  final TimepointModel timepointModel;

  const LogMessagePointWidget({super.key, required this.timepointModel});

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