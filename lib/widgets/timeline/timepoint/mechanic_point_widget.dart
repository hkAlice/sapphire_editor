import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:json_text_field/json_text_field.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/mechanic_point_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_schedule_model.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';

import 'package:sapphire_editor/widgets/simple_number_field.dart';
import 'package:sapphire_editor/widgets/switch_text_widget.dart';
import 'package:sapphire_editor/widgets/text_modal_editor_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/timepoint_editor_scope.dart';
import 'package:sapphire_editor/widgets/timeline/timeline_lookup.dart';
import 'package:signals/signals_flutter.dart';

class MechanicPointWidget extends StatefulWidget {
  final TimepointModel timepointModel;

  const MechanicPointWidget({super.key, required this.timepointModel});

  @override
  State<MechanicPointWidget> createState() => _MechanicPointWidgetState();
}

class _MechanicPointWidgetState extends State<MechanicPointWidget> {
  late TextEditingController _instanceTextEditingController;
  late TextEditingController _functionTextEditingController;

  late MechanicPointModel pointData = widget.timepointModel.data as MechanicPointModel;

  @override
  void initState() {
    _instanceTextEditingController = TextEditingController(text: pointData.instance);
    _functionTextEditingController = TextEditingController(text: pointData.function);
    
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
      final timeline = signals.timeline.value;

      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 180,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "Instance",
                  ),
                  controller: _instanceTextEditingController,
                  onChanged: (value) {
                    pointData.instance = value;
                    _updateTimepoint(signals, actor, schedule);
                  }
                ),
              ),
              const SizedBox(width: 18.0,),
              SizedBox(
                width: 180,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "Function",
                  ),
                  controller: _functionTextEditingController,
                  onChanged: (value) {
                    pointData.function = value;
                    _updateTimepoint(signals, actor, schedule);
                  }
                ),
              ),
              const SizedBox(width: 18.0,),
              const SizedBox(
                width: 36.0,
                child: Text("Args")
              ),
              SizedBox(
                width: 36,
                child: TextModalEditorWidget(
                  headerText: "Args",
                  text: _formatArgsJson(pointData.args),
                  onChanged: (value) {
                    pointData.args = jsonDecode(value);
                    _updateTimepoint(signals, actor, schedule);
                  }
                ),
              )
            ],
          ),
        ],
      );
    });
  }
  
  String _formatArgsJson(Map<String, dynamic>? args)
  {
    args = args ?? Map<String, dynamic>();

    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(args);
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