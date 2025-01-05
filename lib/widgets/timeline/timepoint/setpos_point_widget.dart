import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/setpos_point_model.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';

class SetPosPointWidget extends StatefulWidget {
  final TimepointModel timepointModel;
  final ActorModel selectedActor;
  final Function() onUpdate;

  const SetPosPointWidget({super.key, required this.selectedActor, required this.timepointModel, required this.onUpdate});

  @override
  State<SetPosPointWidget> createState() => _SetPosPointWidgetState();
}

class _SetPosPointWidgetState extends State<SetPosPointWidget> {
  late TextEditingController _xPosTextEditingController;
  late TextEditingController _yPosTextEditingController;
  late TextEditingController _zPosTextEditingController;
  late TextEditingController _rotPosTextEditingController;

  late SetPosPointModel pointData = widget.timepointModel.data as SetPosPointModel;

  @override
  void initState() {
    _xPosTextEditingController = TextEditingController(text: pointData.pos[0].toString());
    _yPosTextEditingController = TextEditingController(text: pointData.pos[1].toString());
    _zPosTextEditingController = TextEditingController(text: pointData.pos[2].toString());
    _rotPosTextEditingController = TextEditingController(text: pointData.rot.toString());

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

  Widget _generateFloatInput({required TextEditingController textEditingController, required String label, required Function(String) onChanged}) {
    return SizedBox(
      width: 110,
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
    return Row(
      children: [
        SizedBox(
          width: 180,
          child: GenericItemPickerWidget<String>(
            label: "Actor",
            initialValue: pointData.actorName,
            items: List.from(widget.selectedActor.subactors)..insert(0, widget.selectedActor.name),
            onChanged: (newValue) {
              pointData.actorName = newValue;
              setState(() {
                
              });
              widget.onUpdate();
            },
          ),
        ),
        const SizedBox(width: 18.0,),
        _generateFloatInput(
          textEditingController: _xPosTextEditingController,
          label: "Pos X",
          onChanged: (value) {
            double newParamValue = 0.0;
            try {
              newParamValue = double.tryParse(value) ?? 0;
              pointData.pos[0] = newParamValue;
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
          onChanged: (value) {
            double newParamValue = 0.0;
            try {
              newParamValue = double.tryParse(value) ?? 0;
              pointData.pos[1] = newParamValue;
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
          onChanged: (value) {
            double newParamValue = 0.0;
            try {
              newParamValue = double.tryParse(value) ?? 0;
              pointData.pos[2] = newParamValue;
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
              pointData.rot = newParamValue;
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