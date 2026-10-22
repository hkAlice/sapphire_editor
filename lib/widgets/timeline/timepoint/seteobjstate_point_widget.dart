import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/seteobjstate_point_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_schedule_model.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';

import 'package:sapphire_editor/widgets/simple_number_field.dart';
import 'package:sapphire_editor/widgets/switch_text_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/timepoint_editor_scope.dart';
import 'package:sapphire_editor/widgets/timeline/timeline_lookup.dart';
import 'package:signals/signals_flutter.dart';

class SetEObjStatePointWidget extends StatefulWidget {
  final TimepointModel timepointModel;

  const SetEObjStatePointWidget({super.key, required this.timepointModel});

  @override
  State<SetEObjStatePointWidget> createState() => _SetEObjStatePointWidgetState();
}

class _SetEObjStatePointWidgetState extends State<SetEObjStatePointWidget> {
  late TextEditingController _eobjNameTextEditingController;

  late SetEObjStatePointModel pointData = widget.timepointModel.data as SetEObjStatePointModel;

  @override
  void initState() {
    _eobjNameTextEditingController = TextEditingController(text: pointData.eobjName);

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
                    labelText: "EObjName",
                  ),
                  controller: _eobjNameTextEditingController,
                  onChanged: (value) {
                    pointData.eobjName = value;
                    _updateTimepoint(signals, actor, schedule);
                  }
                ),
              ),
              const SizedBox(width: 18.0,),
              SizedBox(
                width: 90,
                child: SimpleNumberField(
                  label: "State",
                  initialValue: pointData.state,
                  onChanged: (value) {
                    pointData.state = value;
                    _updateTimepoint(signals, actor, schedule);
                  }
                ),
              ),
              const SizedBox(width: 18.0,),
              SizedBox(
                width: 100,
                child: SimpleNumberField(
                  label: "Animation",
                  initialValue: pointData.animation,
                  onChanged: (value) {
                    pointData.animation = value;
                    _updateTimepoint(signals, actor, schedule);
                  }
                ),
              ),
              const SizedBox(width: 18.0,),
              SizedBox(
                width: 100,
                child: SimpleNumberField(
                  label: "Permission Invisibility",
                  initialValue: pointData.animation,
                  onChanged: (value) {
                    pointData.animation = value;
                    _updateTimepoint(signals, actor, schedule);
                  }
                ),
              ),
              const SizedBox(width: 18.0),
              SizedBox(
                width: 100,
                child: SwitchTextWidget(
                  toggleText: ("Collision ON", "Collision OFF"),
                  enabled: pointData.collision, 
                  onPressed: () {
                    pointData.collision = !pointData.collision;
                    _updateTimepoint(signals, actor, schedule);
                })
              )
            ],
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