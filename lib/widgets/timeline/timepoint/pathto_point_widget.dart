import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/pathto_point_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_schedule_model.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';
import 'package:sapphire_editor/utils/text_utils.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';
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
      var selectedSelector = timeline.selectors.where((e) => e.name == pointData.selectorName).firstOrNull;
      var selectorCount = selectedSelector != null ? selectedSelector.count : 0;

      var validActors = List<String>.from(timeline.actors.map((e) => e.name))..remove(pointData.actorName);
      var localActors = List<String>.from(actor.subactors)..insert(0, actor.name);

      var validTargetActors = List<String>.from([]);
      for(var tmpActor in timeline.actors)
      {
        var tmpActors = List<String>.from(tmpActor.subactors)..insert(0, tmpActor.name);

        validTargetActors.addAll(tmpActors);
      }

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
          Row(children: [
          SizedBox(
                width: 180,
                child: GenericItemPickerWidget<PathToType>(
                  label: "Target Type",
                  items: PathToType.values,
                  initialValue: pointData.pathType,
                  propertyBuilder: (value) => treatEnumName(value),
                  onChanged: (newValue) {
                    pointData.pathType = newValue;
                    _updateTimepoint(signals, actor, schedule);
                    },
                ),
              ),
              const SizedBox(width: 18.0,),
              if(pointData.pathType == PathToType.selectorPos || pointData.pathType == PathToType.selectorTarget)
                Row(
                  children: [
                    SizedBox(
                      width: 170,
                      child: GenericItemPickerWidget<String>(
                        label: "Target Selector",
                        items: timeline.selectors.map((e) => e.name).toList(),
                        initialValue: pointData.selectorName,
                        enabled: pointData.pathType == PathToType.selectorPos ||
                            pointData.pathType == PathToType.selectorTarget,
                        onChanged: (newValue) {
                          pointData.selectorName = newValue;
                          _updateTimepoint(signals, actor, schedule);
                          },
                      ),
                    ),
                    SizedBox(
                      width: 70,
                      child: GenericItemPickerWidget<String>(
                        label: "#",
                        items: List.generate(selectorCount, (e) => (e + 1).toString()),
                        initialValue: (pointData.selectorIndex + 1).toString(),
                        enabled: pointData.pathType == PathToType.selectorPos ||
                                 pointData.pathType == PathToType.selectorTarget,
                        onChanged: (newValue) {
                          pointData.selectorIndex = int.parse(newValue) - 1;
                          _updateTimepoint(signals, actor, schedule);
                        },
                      ),
                    )
                  ],
                )
              else if(pointData.pathType case PathToType.timelineActor)
                SizedBox(
                  width: 360,
                  child: GenericItemPickerWidget<String>(
                    label: "Target Timeline Actor",
                    items: validTargetActors,
                    initialValue: validTargetActors.firstWhereOrNull((e) => e == pointData.targetActor),
                    onChanged: (newValue) {
                      pointData.targetActor = newValue;
                      _updateTimepoint(signals, actor, schedule);
                      },
                  ),
                )
              else if(pointData.pathType case PathToType.serverPath)
                  SizedBox(
                  width: 170,
                  child: SimpleNumberField(
                    label: "Server Path ID",
                    initialValue: pointData.serverPathId,
                    onChanged: (newValue) {
                      pointData.serverPathId = newValue;
                      _updateTimepoint(signals, actor, schedule);
                    },
                  ),
                )
              else if(pointData.pathType case PathToType.fixedPos)
                _PosWidget(
                  onUpdate: (){ 
                    _updateTimepoint(signals, actor, schedule);
                  }, pointData: pointData
                ),
              const SizedBox(height: 18.0,),
              SizedBox(
              width: 100,
              child: SwitchTextWidget(
                toggleText: ("UseNavi ON", "UseNavi OFF"),
                enabled: pointData.useNavi, 
                onPressed: () {
                  pointData.useNavi = !pointData.useNavi;
                  _updateTimepoint(signals, actor, schedule);
                }
              )
          )
        ],
        )]
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

class _PosWidget extends StatefulWidget {
  // todo: hax, this should not be like this at all
  final Function() onUpdate;
  final PathToPointModel pointData;

  const _PosWidget({required this.onUpdate, required this.pointData});

  @override
  State<_PosWidget> createState() => _PosWidgetState();
}

class _PosWidgetState extends State<_PosWidget> {
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
          enabled: widget.pointData.pathType == PathToType.fixedPos,
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
          enabled: widget.pointData.pathType == PathToType.fixedPos,
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
          enabled: widget.pointData.pathType == PathToType.fixedPos,
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
      ],
    );
  }
}