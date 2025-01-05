import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/logmessage_point_model.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';

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

  Widget _generateStrSplitInput({required TextEditingController textEditingController, required String label, required Function(String) onChanged}) {
    return SizedBox(
      width: 180,
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
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: SimpleNumberField(
            label: "Message ID",
            initialValue: pointData.messageId,
            onChanged: (value) {
              pointData.messageId = value;
              widget.onUpdate();
            }
          ),
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