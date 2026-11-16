import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/pathto_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/setpos_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/castaction_point_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_schedule_model.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';
import 'package:sapphire_editor/utils/text_utils.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/switch_text_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/timepoint_editor_scope.dart';
import 'package:sapphire_editor/widgets/timeline/timeline_lookup.dart';
import 'package:signals/signals_flutter.dart';

class PathToPointWidget extends StatefulWidget {
  final TimepointModel timepointModel;

  const PathToPointWidget({super.key, required this.timepointModel});

  @override
  State<PathToPointWidget> createState() => _PathToPointWidgetState();
}

Widget _generateFloatInput({required TextEditingController textEditingController, required String label, required Function(String) onChanged, bool enabled = true}) {
    return SizedBox(
      width: 110,
      child: TextFormField(
        maxLines: 1,
        controller: textEditingController,
        enabled: enabled,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          label: Text(label),
        ),
        onChanged: (value) { onChanged(value); }
      ),
    );
  }

class _PathToPointWidgetState extends State<PathToPointWidget> {
  late PathToPointModel pointData = widget.timepointModel.data as PathToPointModel;

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

      var validActors = List<String>.from(timeline.actors.map((e) => e.name))..remove(pointData.actorName);
      var localActors = List<String>.from(actor.subactors)..insert(0, actor.name);

      return Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 180,
                child: GenericItemPickerWidget<String>(
                  label: "Actor",
                  initialValue: localActors.firstWhereOrNull((e) => e == pointData.actorName),
                  items: localActors,
                  onChanged: (newValue) {
                    pointData.actorName = newValue;
                    _updateTimepoint(signals, actor, schedule);
                  },
                ),
              ),
              const SizedBox(width: 18.0,),
            ]
          ),
          const SizedBox(height: 18.0,),
          _PathToAbsoluteWidget(onUpdate: () { _updateTimepoint(signals, actor, schedule); }, pointData: pointData),
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

class _PathToAbsoluteWidget extends StatefulWidget {
  // todo: hax, this should not be like this at all
  final Function() onUpdate;
  final PathToPointModel pointData;

  const _PathToAbsoluteWidget({required this.onUpdate, required this.pointData});

  @override
  State<_PathToAbsoluteWidget> createState() => _PathToAbsoluteWidgetState();
}

class _PathToAbsoluteWidgetState extends State<_PathToAbsoluteWidget> {
  late TextEditingController _xPosTextEditingController;
  late TextEditingController _yPosTextEditingController;
  late TextEditingController _zPosTextEditingController;

  @override
  void initState() {
    _xPosTextEditingController = TextEditingController(text: widget.pointData.pos[0].toString());
    _yPosTextEditingController = TextEditingController(text: widget.pointData.pos[1].toString());
    _zPosTextEditingController = TextEditingController(text: widget.pointData.pos[2].toString());

    super.initState();
  }

  @override
  void dispose() {
    _xPosTextEditingController.dispose();
    _yPosTextEditingController.dispose();
    _zPosTextEditingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _generateFloatInput(
          textEditingController: _xPosTextEditingController,
          label: "Pos X",
          enabled: true,
          onChanged: (value) {
            double newParamValue = 0.0;
            try {
              newParamValue = double.tryParse(value) ?? 0;
              widget.pointData.pos[0] = newParamValue;
              widget.onUpdate();
            }
            catch(_) { }

            }
        ),
        const SizedBox(width: 18.0,),
        _generateFloatInput(
          textEditingController: _yPosTextEditingController,
          label: "Pos Y",
          enabled: true,
          onChanged: (value) {
            double newParamValue = 0.0;
            try {
              newParamValue = double.tryParse(value) ?? 0;
              widget.pointData.pos[1] = newParamValue;
              widget.onUpdate();
            }
            catch(_) { }

            }
        ),
        const SizedBox(width: 18.0,),
        _generateFloatInput(
          textEditingController: _zPosTextEditingController,
          label: "Pos Z",
          enabled: true,
          onChanged: (value) {
            double newParamValue = 0.0;
            try {
              newParamValue = double.tryParse(value) ?? 0;
              widget.pointData.pos[2] = newParamValue;
              widget.onUpdate();
            }
            catch(_) { }

            }
        ),
        const SizedBox(width: 18.0),
        SizedBox(
          width: 100,
          child: SwitchTextWidget(
            toggleText: ("UseNavi ON", "UseNavi OFF"),
            enabled: widget.pointData.useNavi, 
            onPressed: () {
              widget.pointData.useNavi = !widget.pointData.useNavi;
              widget.onUpdate();
            }
          )
        )
      ],
    );
  }
}