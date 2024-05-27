import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/moveto_point_model.dart';
import 'package:sapphire_editor/widgets/switch_text_widget.dart';

class MoveToPointWidget extends StatefulWidget {
  final TimepointModel timepointModel;
  final Function() onUpdate;

  const MoveToPointWidget({super.key, required this.timepointModel, required this.onUpdate});

  @override
  State<MoveToPointWidget> createState() => _MoveToPointWidgetState();
}

class _MoveToPointWidgetState extends State<MoveToPointWidget> {
  late TextEditingController _xPosTextEditingController;
  late TextEditingController _yPosTextEditingController;
  late TextEditingController _zPosTextEditingController;
  late TextEditingController _rotPosTextEditingController;

  late MoveToPointModel pointData = widget.timepointModel.data as MoveToPointModel;

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
      width: 120,
      child: TextFormField(
        maxLines: 1,
        controller: textEditingController,
        decoration: InputDecoration(
          border: InputBorder.none,
          label: Text(label),
        ),
        onChanged: (value) { onChanged(value); }
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
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
        SwitchTextWidget(
          leading: const Text("Request Path"),
          enabled: pointData.pathRequest,
          onPressed: () {
            setState(() {
              pointData.pathRequest = !pointData.pathRequest;
            });
            widget.onUpdate();
          }
        )
      ],
    );
  }
}