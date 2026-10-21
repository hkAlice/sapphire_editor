import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/setvar_point_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_schedule_model.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';
import 'package:sapphire_editor/utils/text_utils.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';
import 'package:sapphire_editor/widgets/timeline/timeline_lookup.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/timepoint_editor_scope.dart';
import 'package:signals/signals_flutter.dart';

class SetVarPointWidget extends StatefulWidget {
  final TimepointModel timepointModel;

  const SetVarPointWidget({super.key, required this.timepointModel });

  @override
  State<SetVarPointWidget> createState() => _SetVarPointWidgetState();
}

class _SetVarPointWidgetState extends State<SetVarPointWidget> {
  late SetVarPointModel pointData = widget.timepointModel.data as SetVarPointModel;

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
      final timeline = signals.timeline.value;
      
      return Row(
        children: [
            SizedBox(
            width: 180,
            child: GenericItemPickerWidget<VarType>(
              label: "Type",
              items: VarType.values,
              initialValue: pointData.type,
              propertyBuilder: (value) {
                return treatEnumName(value);
              },
              onChanged: (newValue) {
                pointData.type = newValue;
                _updateTimepoint(signals, actor, schedule);
                },
            ),
          ),
          const SizedBox(width: 18.0),
          SizedBox(
            width: 180,
            child: GenericItemPickerWidget<VarOpcode>(
              label: "Operation",
              items: VarOpcode.values,
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
              label: "Index (hex)",
              initialValue: pointData.idx,
              isHex: true,
              onChanged: (newValue) {
                pointData.idx = newValue;
                _updateTimepoint(signals, actor, schedule);
              }
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