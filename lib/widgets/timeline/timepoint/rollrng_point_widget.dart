import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/rollrng_point_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_schedule_model.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';
import 'package:sapphire_editor/utils/text_utils.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/signals_provider.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';
import 'package:signals/signals_flutter.dart';

class RollRNGPointWidget extends StatefulWidget {
  final TimepointModel timepointModel;

  const RollRNGPointWidget({
    super.key,
    required this.timepointModel,
  });

  @override
  State<RollRNGPointWidget> createState() => _RollRNGPointWidgetState();
}

class _RollRNGPointWidgetState extends State<RollRNGPointWidget> {
  late RollRNGPointModel pointData = widget.timepointModel.data as RollRNGPointModel;
  
  @override
  Widget build(BuildContext context) {
    final signals = SignalsProvider.of(context);
    return Watch((context) {
      final actor = signals.selectedActor.value;
      final schedule = signals.selectedSchedule.value;

      return Row(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 180,
                child: SimpleNumberField(
                  label: "Min",
                  initialValue: pointData.min,
                  onChanged: (value) {
                    pointData.min = value;
                    _updateTimepoint(signals, actor, schedule);
                  }
                ),
              ),
              const SizedBox(width: 18.0,),
              SizedBox(
                width: 180,
                child: SimpleNumberField(
                  label: "Max",
                  initialValue: pointData.max,
                  onChanged: (value) {
                    pointData.max = value;
                    _updateTimepoint(signals, actor, schedule);
                  }
                ),
              ),
              const SizedBox(width: 18.0),
              SizedBox(
                width: 180,
                child: GenericItemPickerWidget<RNGVarType>(
                  label: "Var Type",
                  initialValue: RNGVarType.custom,
                  items: RNGVarType.values,
                  propertyBuilder: (value) => treatEnumName(value),
                  onChanged: (newValue) {
                    pointData.type = newValue;
                    _updateTimepoint(signals, actor, schedule);
                  },
                ),
              ),
              const SizedBox(width: 18.0),
              SizedBox(
                width: 180,
                child: SimpleNumberField(
                  label: "Index",
                  initialValue: pointData.index,
                  onChanged: (value) {
                    pointData.index = value;
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
    final oldTimepoint = schedule.timepoints.firstWhere((t) => t == widget.timepointModel);
    final newTimepoint = TimepointModel(
      type: oldTimepoint.type,
      startTime: oldTimepoint.startTime,
      data: pointData,
    );
    signals.updateTimepoint(actor, schedule, oldTimepoint, newTimepoint);
  }
}