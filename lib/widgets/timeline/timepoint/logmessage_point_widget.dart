import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/logmessage_point_model.dart';

class LogMessagePointWidget extends StatefulWidget {
  final TimepointModel timepointModel;
  final Function() onUpdate;

  const LogMessagePointWidget({super.key, required this.timepointModel, required this.onUpdate});

  @override
  State<LogMessagePointWidget> createState() => _LogMessagePointWidgetState();
}

class _LogMessagePointWidgetState extends State<LogMessagePointWidget> {
  late TextEditingController _logMsgTextEditingController;
  late TextEditingController _paramsTextEditingController;

  late LogMessagePointModel pointData = widget.timepointModel.data as LogMessagePointModel;

  @override
  void initState() {
    _logMsgTextEditingController = TextEditingController(text: pointData.messageId.toString());
    _paramsTextEditingController = TextEditingController(text: pointData.params.join(", "));

    super.initState();
  }

  @override
  void dispose() {
    _logMsgTextEditingController.dispose();
    _paramsTextEditingController.dispose();

    super.dispose();
  }

  Widget _generateIntInput({required TextEditingController textEditingController, required String label, required Function(String) onChanged}) {
    return SizedBox(
      width: 150,
      child: TextFormField(
        maxLines: 1,
        controller: textEditingController,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          border: InputBorder.none,
          label: Text(label),
        ),
        onChanged: (value) { onChanged(value); }
      ),
    );
  }

  Widget _generateStrSplitInput({required TextEditingController textEditingController, required String label, required Function(String) onChanged}) {
    return SizedBox(
      width: 150,
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
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _generateIntInput(
          textEditingController: _logMsgTextEditingController,
          label: "Message ID",
          onChanged: (value) {
            int newParamValue = 0;
            try {
              newParamValue = int.tryParse(value) ?? 0;
              pointData.messageId = newParamValue;
              widget.onUpdate();
            }
            catch(_) { }

            setState(() {
              
            });
          }
        ),
        const SizedBox(width: 18.0,),
        _generateStrSplitInput(
          textEditingController: _paramsTextEditingController,
          label: "Params (split by ,)",
          onChanged: (value) {
            try {
              var listParams = value.split(",").map((e) => int.parse(e)).toList();
              pointData.params = listParams;
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