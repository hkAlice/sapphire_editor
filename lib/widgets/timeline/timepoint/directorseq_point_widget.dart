import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/directorseq_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/directorvar_point_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_schedule_model.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';
import 'package:sapphire_editor/utils/text_utils.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/signals_provider.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';
import 'package:signals/signals_flutter.dart';

class DirectorSeqPointWidget extends StatefulWidget {
  final TimepointModel timepointModel;

  const DirectorSeqPointWidget({super.key, required this.timepointModel});

  @override
  State<DirectorSeqPointWidget> createState() => _DirectorSeqPointWidgetState();
}

class _DirectorSeqPointWidgetState extends State<DirectorSeqPointWidget> {
  late DirectorSeqPointModel pointData = widget.timepointModel.data as DirectorSeqPointModel;

  @override
  Widget build(BuildContext context) {
    final signals = SignalsProvider.of(context);
    return Watch((context) {
      final actor = signals.selectedActor.value;
      final schedule = signals.selectedSchedule.value;

      return Row(
        children: [
          SizedBox(
            width: 180,
            child: GenericItemPickerWidget<DirectorOpcode>(
              label: "Operation",
              items: DirectorOpcode.values,
              initialValue: pointData.opc,
              propertyBuilder: (value) {
                return treatEnumName(value);
              },
              onChanged: (newValue) {
                pointData.opc = newValue;
                _updateTimepoint(signals, actor, schedule);
                },
            ),
          ),
          const SizedBox(width: 18.0),
          SizedBox(
            width: 110,
            child: SimpleNumberField(
              label: "Value",
              initialValue: pointData.val,
              onChanged: (newValue) {
                pointData.val = newValue;
                _updateTimepoint(signals, actor, schedule);
              }
            ),
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