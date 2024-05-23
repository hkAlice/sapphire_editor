import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/battletalk_point_model.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';

class BattleTalkPointWidget extends StatefulWidget {
  final TimepointModel timepointModel;
  final Function() onUpdate;

  const BattleTalkPointWidget({super.key, required this.timepointModel, required this.onUpdate});

  @override
  State<BattleTalkPointWidget> createState() => _BattleTalkPointWidgetState();
}

class _BattleTalkPointWidgetState extends State<BattleTalkPointWidget> {
  late TextEditingController _paramsTextEditingController;

  late BattleTalkPointModel pointData = widget.timepointModel.data as BattleTalkPointModel;

  @override
  void initState() {
    _paramsTextEditingController = TextEditingController(text: pointData.params.join(", "));

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _generateStrSplitInput({required TextEditingController textEditingController, required String label, required Function(String) onChanged}) {
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
        SizedBox(
          width: 120,
          child: SimpleNumberField(
            label: "BattleTalk ID",
            initialValue: pointData.battleTalkId,
            onChanged: (value) {
              pointData.battleTalkId = value;
              widget.onUpdate();
            }
          ),
        ),
        SizedBox(
          width: 120,
          child: SimpleNumberField(
            label: "Handler ID",
            initialValue: pointData.handlerId,
            onChanged: (value) {
              pointData.handlerId = value;
              widget.onUpdate();
            }
          ),
        ),
        SizedBox(
          width: 120,
          child: SimpleNumberField(
            label: "Kind",
            initialValue: pointData.kind,
            onChanged: (value) {
              pointData.kind = value;
              widget.onUpdate();
            }
          ),
        ),
        SizedBox(
          width: 120,
          child: SimpleNumberField(
            label: "Name ID",
            initialValue: pointData.nameId,
            onChanged: (value) {
              pointData.nameId = value;
              widget.onUpdate();
            }
          ),
        ),
        SizedBox(
          width: 120,
          child: SimpleNumberField(
            label: "Talker ID",
            initialValue: pointData.talkerId,
            onChanged: (value) {
              pointData.talkerId = value;
              widget.onUpdate();
            }
          ),
        ),
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