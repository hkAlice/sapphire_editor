import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/setpos_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/castaction_point_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_schedule_model.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';
import 'package:sapphire_editor/utils/text_utils.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/signals_provider.dart';
import 'package:signals/signals_flutter.dart';

class SetPosPointWidget extends StatefulWidget {
  final TimepointModel timepointModel;

  const SetPosPointWidget({super.key, required this.timepointModel});

  @override
  State<SetPosPointWidget> createState() => _SetPosPointWidgetState();
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

class _SetPosPointWidgetState extends State<SetPosPointWidget> {
  late SetPosPointModel pointData = widget.timepointModel.data as SetPosPointModel;

  @override
  Widget build(BuildContext context) {
    final signals = SignalsProvider.of(context);

    return Watch((context) {
      final actor = signals.selectedActor.value;
      final schedule = signals.selectedSchedule.value;
      final timeline = signals.timeline.value;

      var validActors = List<String>.from(timeline.actors.map((e) => e.name))..remove(pointData.actorName);
      var localActors = List<String>.from(actor.subactors)..insert(0, actor.name);
      var selectedSelector = timeline.selectors.where((e) => e.name == pointData.selectorName).firstOrNull;
      var selectorCount = selectedSelector != null ? selectedSelector.count : 0;

      return Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 180,
                child: GenericItemPickerWidget<String>(
                  label: "Actor",
                  initialValue: localActors.firstWhereOrNull((e) => e == pointData.targetActor),
                  items: localActors,
                  onChanged: (newValue) {
                    pointData.actorName = newValue;
                    _updateTimepoint(signals, actor, schedule);
                  },
                ),
              ),
              const SizedBox(width: 18.0,),
              SizedBox(
                width: 168,
                child: GenericItemPickerWidget<PositionType>(
                  label: "Position",
                  items: PositionType.values,
                  initialValue: pointData.positionType,
                  propertyBuilder: (value) => treatEnumName(value),
                  onChanged: (newValue) {
                    pointData.positionType = newValue;
                    _updateTimepoint(signals, actor, schedule);
                    },
                ),
              ),
              const SizedBox(width: 18.0,),
              SizedBox(
                width: 110,
                child: GenericItemPickerWidget<ActorTargetType>(
                  label: "Target Type",
                  items: ActorTargetType.values,
                  initialValue: pointData.targetType,
                  propertyBuilder: (value) => treatEnumName(value),
                  onChanged: (newValue) {
                    pointData.targetType = newValue;
                    _updateTimepoint(signals, actor, schedule);
                    },
                ),
              ),
              const SizedBox(width: 18.0,),
              if(pointData.targetType == ActorTargetType.selectorPos || pointData.targetType == ActorTargetType.selectorTarget)
                Row(
                  children: [
                    SizedBox(
                      width: 170,
                      child: GenericItemPickerWidget<String>(
                        label: "Target Selector",
                        items: timeline.selectors.map((e) => e.name).toList(),
                        initialValue: pointData.selectorName,
                        enabled: pointData.targetType == ActorTargetType.selectorPos ||
                            pointData.targetType == ActorTargetType.selectorTarget,
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
                enabled: pointData.targetType == ActorTargetType.selectorPos ||
                         pointData.targetType == ActorTargetType.selectorTarget,
                onChanged: (newValue) {
                  pointData.selectorIndex = int.parse(newValue) - 1;
                  _updateTimepoint(signals, actor, schedule);
                },
              ),
                    )
                  ],
                )
              else if(pointData.targetType case ActorTargetType.target)
                SizedBox(
                  width: 170,
                  child: GenericItemPickerWidget<String>(
                    label: "Target Actor",
                    items: validActors,
                    initialValue: validActors.firstWhereOrNull((e) => e == pointData.targetActor),
                    onChanged: (newValue) {
                      pointData.targetActor = newValue;
                      _updateTimepoint(signals, actor, schedule);
                      },
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18.0,),
          if(pointData.positionType == PositionType.absolute && pointData.targetType == ActorTargetType.self)
            _SetPosAbsoluteWidget(pointData: pointData, signals: signals, actor: actor, schedule: schedule,)
          else
            _SetPosRelativeWidget(pointData: pointData, signals: signals, actor: actor, schedule: schedule,),

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

class _SetPosAbsoluteWidget extends StatefulWidget {
  final SetPosPointModel pointData;
  final TimelineEditorSignal signals;
  final ActorModel actor;
  final TimelineScheduleModel schedule;

  const _SetPosAbsoluteWidget({required this.pointData, required this.signals, required this.actor, required this.schedule});

  @override
  State<_SetPosAbsoluteWidget> createState() => _SetPosAbsoluteWidgetState();
}

class _SetPosAbsoluteWidgetState extends State<_SetPosAbsoluteWidget> {
  late TextEditingController _xPosTextEditingController;
  late TextEditingController _yPosTextEditingController;
  late TextEditingController _zPosTextEditingController;
  late TextEditingController _rotPosTextEditingController;

  @override
  void initState() {
    _xPosTextEditingController = TextEditingController(text: widget.pointData.pos[0].toString());
    _yPosTextEditingController = TextEditingController(text: widget.pointData.pos[1].toString());
    _zPosTextEditingController = TextEditingController(text: widget.pointData.pos[2].toString());
    _rotPosTextEditingController = TextEditingController(text: widget.pointData.rot.toString());

    super.initState();
  }

  @override
  void dispose() {
    _xPosTextEditingController.dispose();
    _yPosTextEditingController.dispose();
    _zPosTextEditingController.dispose();
    _rotPosTextEditingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _generateFloatInput(
          textEditingController: _xPosTextEditingController,
          label: "Pos X",
          enabled: widget.pointData.targetType == ActorTargetType.self,
          onChanged: (value) {
            double newParamValue = 0.0;
            try {
              newParamValue = double.tryParse(value) ?? 0;
              widget.pointData.pos[0] = newParamValue;
              _updateTimepoint();
            }
            catch(_) { }

            }
        ),
        const SizedBox(width: 18.0,),
        _generateFloatInput(
          textEditingController: _yPosTextEditingController,
          label: "Pos Y",
          enabled: widget.pointData.targetType == ActorTargetType.self,
          onChanged: (value) {
            double newParamValue = 0.0;
            try {
              newParamValue = double.tryParse(value) ?? 0;
              widget.pointData.pos[1] = newParamValue;
              _updateTimepoint();
            }
            catch(_) { }

            }
        ),
        const SizedBox(width: 18.0,),
        _generateFloatInput(
          textEditingController: _zPosTextEditingController,
          label: "Pos Z",
          enabled: widget.pointData.targetType == ActorTargetType.self,
          onChanged: (value) {
            double newParamValue = 0.0;
            try {
              newParamValue = double.tryParse(value) ?? 0;
              widget.pointData.pos[2] = newParamValue;
              _updateTimepoint();
            }
            catch(_) { }

            }
        ),
        const SizedBox(width: 18.0,),
        _generateFloatInput(
          textEditingController: _rotPosTextEditingController,
          label: "Rot",
          enabled: widget.pointData.targetType == ActorTargetType.self,
          onChanged: (value) {
            double newParamValue = 0.0;
            try {
              newParamValue = double.tryParse(value) ?? 0;
              widget.pointData.rot = newParamValue;
              _updateTimepoint();
            }
            catch(_) { }

            }
        ),
      ],
    );
  }

  void _updateTimepoint() {
    final oldTimepoint = widget.schedule.timepoints.firstWhere((t) => t.data == widget.pointData);
    final newTimepoint = TimepointModel(
      type: oldTimepoint.type,
      startTime: oldTimepoint.startTime,
      data: widget.pointData,
    );
    widget.signals.updateTimepoint(widget.actor, widget.schedule, oldTimepoint, newTimepoint);
  }
}

class _SetPosRelativeWidget extends StatefulWidget {
  final SetPosPointModel pointData;
  final TimelineEditorSignal signals;
  final ActorModel actor;
  final TimelineScheduleModel schedule;

  const _SetPosRelativeWidget({required this.pointData, required this.signals, required this.actor, required this.schedule});

  @override
  State<_SetPosRelativeWidget> createState() => _SetPosRelativeWidgetState();
}

class _SetPosRelativeWidgetState extends State<_SetPosRelativeWidget> {
  late TextEditingController _xPosTextEditingController;
  late TextEditingController _yPosTextEditingController;
  late TextEditingController _zPosTextEditingController;
  late TextEditingController _rotPosTextEditingController;

  @override
  void initState() {
    _xPosTextEditingController = TextEditingController(text: widget.pointData.pos[0].toString());
    _yPosTextEditingController = TextEditingController(text: widget.pointData.pos[1].toString());
    _zPosTextEditingController = TextEditingController(text: widget.pointData.pos[2].toString());
    _rotPosTextEditingController = TextEditingController(text: widget.pointData.rot.toString());

    super.initState();
  }

  @override
  void dispose() {
    _xPosTextEditingController.dispose();
    _yPosTextEditingController.dispose();
    _zPosTextEditingController.dispose();
    _rotPosTextEditingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _generateFloatInput(
          textEditingController: _xPosTextEditingController,
          label: "Forward",
          onChanged: (value) {
            double newParamValue = 0.0;
            try {
              newParamValue = double.tryParse(value) ?? 0;
              widget.pointData.pos[0] = newParamValue;
              _updateTimepoint();
            }
            catch(_) { }

            }
        ),
        const SizedBox(width: 18.0,),
        _generateFloatInput(
          textEditingController: _yPosTextEditingController,
          label: "Right",
          onChanged: (value) {
            double newParamValue = 0.0;
            try {
              newParamValue = double.tryParse(value) ?? 0;
              widget.pointData.pos[1] = newParamValue;
              _updateTimepoint();
            }
            catch(_) { }

            }
        ),
        const SizedBox(width: 18.0,),
        _generateFloatInput(
          textEditingController: _zPosTextEditingController,
          label: "Up",
          onChanged: (value) {
            double newParamValue = 0.0;
            try {
              newParamValue = double.tryParse(value) ?? 0;
              widget.pointData.pos[2] = newParamValue;
              _updateTimepoint();
            }
            catch(_) { }

            }
        ),
        const SizedBox(width: 18.0,),
        _generateFloatInput(
          textEditingController: _rotPosTextEditingController,
          label: "Rot",
          onChanged: (value) {
            double newParamValue = 0.0;
            try {
              newParamValue = double.tryParse(value) ?? 0;
              widget.pointData.rot = newParamValue;
              _updateTimepoint();
            }
            catch(_) { }

            }
        ),
      ],
    );
  }
  
  void _updateTimepoint() {
    final oldTimepoint = widget.schedule.timepoints.firstWhere((t) => t == widget.pointData);
    final newTimepoint = TimepointModel(
      type: oldTimepoint.type,
      startTime: oldTimepoint.startTime,
      data: widget.pointData,
    );
    widget.signals.updateTimepoint(widget.actor, widget.schedule, oldTimepoint, newTimepoint);
  }
}