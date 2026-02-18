import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/battletalk_point_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_schedule_model.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/number_button.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';
import 'package:signals/signals_flutter.dart';

class BattleTalkPointWidget extends StatefulWidget {
  final TimepointModel timepointModel;
  final TimelineEditorSignal signals;

  const BattleTalkPointWidget({super.key, required this.timepointModel, required this.signals});

  @override
  State<BattleTalkPointWidget> createState() => _BattleTalkPointWidgetState();
}

class _BattleTalkPointWidgetState extends State<BattleTalkPointWidget> {
  late TextEditingController _paramsTextEditingController;

  late BattleTalkPointModel pointData = widget.timepointModel.data as BattleTalkPointModel;

  @override
  void initState() {
    _paramsTextEditingController = TextEditingController(text: pointData.params.join(", "));

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _generateStrSplitInput({required TextEditingController textEditingController, required String label, required Function(String) onChanged}) {
    return SizedBox(
      width: 306,
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
      final timeline = signals.timeline.value;

      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 180,
                child: SimpleNumberField(
                  label: "BattleTalk ID",
                  initialValue: pointData.battleTalkId,
                  onChanged: (value) {
                    pointData.battleTalkId = value;
                    _updateTimepoint(signals, actor, schedule);
                  }
                ),
              ),
              const SizedBox(width: 18.0,),
              SizedBox(
                width: 90,
                child: SimpleNumberField(
                  label: "Kind",
                  initialValue: pointData.kind,
                  onChanged: (value) {
                    pointData.kind = value;
                    _updateTimepoint(signals, actor, schedule);
                  }
                ),
              ),
              const SizedBox(width: 18.0,),
              SizedBox(
                width: 90,
                child: SimpleNumberField(
                  label: "Name ID",
                  initialValue: pointData.nameId,
                  onChanged: (value) {
                    pointData.nameId = value;
                    _updateTimepoint(signals, actor, schedule);
                  }
                ),
              ),
              const SizedBox(width: 18.0,),
              NumberButton(
                min: 0,
                max: 60000,
                readOnlyField: true,
                value: pointData.length,
                label: "Length",
                builder: (value) {
                  var seconds = value / 1000;
                  return "${seconds.toStringAsFixed(1)}s";
                },
                stepCount: 100,
                onChanged: (value) {
                  pointData.length = value;
                  _updateTimepoint(signals, actor, schedule);
                }
              ),
            ],
          ),
          const SizedBox(height: 18.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 180,
                child: GenericItemPickerWidget<ActorModel>(
                  label: "Talker Actor",
                  items: timeline.actors,
                  initialValue: timeline.actors.firstWhereOrNull((e) => e.name == pointData.talkerActorName),
                  onChanged: (newValue) {
                    pointData.talkerActorName = newValue.name;
                    _updateTimepoint(signals, actor, schedule);
                    },
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