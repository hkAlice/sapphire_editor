import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/setpos_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/castaction_point_model.dart';
import 'package:sapphire_editor/utils/text_utils.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';

class SetPosPointWidget extends StatefulWidget {
  final TimelineModel timelineModel;
  final TimepointModel timepointModel;
  final ActorModel selectedActor;
  final Function() onUpdate;

  const SetPosPointWidget({super.key, required this.selectedActor, required this.timelineModel, required this.timepointModel, required this.onUpdate});

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
    var validActors = List<String>.from(widget.timelineModel.actors.map((e) => e.name))..remove(pointData.actorName);
    var localActors = List<String>.from(widget.selectedActor.subactors)..insert(0, widget.selectedActor.name);
    var selectedSelector = widget.timelineModel.selectors.where((e) => e.name == pointData.selectorName).firstOrNull;
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
                  setState(() {
                    
                  });
                  widget.onUpdate();
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
                  widget.onUpdate();
                  setState(() {
                    
                  });
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
                  widget.onUpdate();
                  setState(() {
                    
                  });
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
                      items: widget.timelineModel.selectors.map((e) => e.name).toList(),
                      initialValue: pointData.selectorName,
                      enabled: pointData.targetType == ActorTargetType.selectorPos ||
                               pointData.targetType == ActorTargetType.selectorTarget,
                      onChanged: (newValue) {
                        pointData.selectorName = newValue;
                        widget.onUpdate();
                        setState(() {
                          
                        });
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
                        setState(() {
                          pointData.selectorIndex = int.parse(newValue) - 1;
                        });
                        
                        widget.onUpdate();
                        
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
                    widget.onUpdate();
                    setState(() {
                      
                    });
                  },
                ),
              ),
          ],
        ),
        const SizedBox(height: 18.0,),
        if(pointData.positionType == PositionType.absolute && pointData.targetType == ActorTargetType.self)
          _SetPosAbsoluteWidget(pointData: pointData, onUpdate: () => widget.onUpdate(),)
        else
          _SetPosRelativeWidget(pointData: pointData, onUpdate: () => widget.onUpdate(),),
        
      ],
    );
  }
}

class _SetPosAbsoluteWidget extends StatefulWidget {
  final SetPosPointModel pointData;
  final Function() onUpdate;

  const _SetPosAbsoluteWidget({required this.pointData, required this.onUpdate});

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
              widget.onUpdate();
            }
            catch(_) { }
    
            setState(() {
              
            });
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
              widget.onUpdate();
            }
            catch(_) { }
    
            setState(() {
              
            });
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
              widget.onUpdate();
            }
            catch(_) { }
    
            setState(() {
              
            });
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
              widget.onUpdate();
            }
            catch(_) { }
    
            setState(() {
              
            });
          }
        ),
      ],
    );
  }
}

class _SetPosRelativeWidget extends StatefulWidget {
  final SetPosPointModel pointData;
  final Function() onUpdate;

  const _SetPosRelativeWidget({required this.pointData, required this.onUpdate});

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
              widget.onUpdate();
            }
            catch(_) { }
    
            setState(() {
              
            });
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
              widget.onUpdate();
            }
            catch(_) { }
    
            setState(() {
              
            });
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
              widget.onUpdate();
            }
            catch(_) { }
    
            setState(() {
              
            });
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
              widget.onUpdate();
            }
            catch(_) { }
    
            setState(() {
              
            });
          }
        ),
      ],
    );
  }
}