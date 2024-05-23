import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/battletalk_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/logmessage_point_model.dart';

class BattleTalkPointWidget extends StatefulWidget {
  final TimepointModel timepointModel;
  final Function() onUpdate;

  const BattleTalkPointWidget({super.key, required this.timepointModel, required this.onUpdate});

  @override
  State<BattleTalkPointWidget> createState() => _BattleTalkPointWidgetState();
}

class _BattleTalkPointWidgetState extends State<BattleTalkPointWidget> {
  late TextEditingController _battleTalkIdTextEditingController;
  late TextEditingController _handlerIdTextEditingController;
  late TextEditingController _talkerIdTextEditingController;
  late TextEditingController _nameIdTextEditingController;
  late TextEditingController _kindTextEditingController;
  late TextEditingController _paramsTextEditingController;

  late BattleTalkPointModel pointData = widget.timepointModel.data as BattleTalkPointModel;

  @override
  void initState() {
    _battleTalkIdTextEditingController = TextEditingController(text: pointData.battleTalkId.toString());
    _handlerIdTextEditingController = TextEditingController(text: pointData.handlerId.toString());
    _talkerIdTextEditingController = TextEditingController(text: pointData.talkerId.toString());
    _nameIdTextEditingController = TextEditingController(text: pointData.nameId.toString());
    _kindTextEditingController = TextEditingController(text: pointData.kind.toString());
    _paramsTextEditingController = TextEditingController(text: pointData.params.join(", "));

    super.initState();
  }

  @override
  void dispose() {
    _battleTalkIdTextEditingController.dispose();
    _handlerIdTextEditingController.dispose();
    _talkerIdTextEditingController.dispose();
    _nameIdTextEditingController.dispose();
    _kindTextEditingController.dispose();
    _paramsTextEditingController.dispose();

    super.dispose();
  }

  Widget _generateIntInput({required TextEditingController textEditingController, required String label, required Function(String) onChanged}) {
    return SizedBox(
      width: 120,
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
        _generateIntInput(
          textEditingController: _battleTalkIdTextEditingController,
          label: "BattleTalk ID",
          onChanged: (value) {
            int newParamValue = 0;
            try {
              newParamValue = int.tryParse(value) ?? 0;
              pointData.battleTalkId = newParamValue;
              widget.onUpdate();
            }
            catch(_) { }

            setState(() {
              
            });
          }
        ),
        _generateIntInput(
          textEditingController: _handlerIdTextEditingController,
          label: "Handler ID",
          onChanged: (value) {
            int newParamValue = 0;
            try {
              newParamValue = int.tryParse(value) ?? 0;
              pointData.handlerId = newParamValue;
              widget.onUpdate();
            }
            catch(_) { }

            setState(() {
              
            });
          }
        ),
        _generateIntInput(
          textEditingController: _kindTextEditingController,
          label: "Kind",
          onChanged: (value) {
            int newParamValue = 0;
            try {
              newParamValue = int.tryParse(value) ?? 0;
              pointData.kind = newParamValue;
              widget.onUpdate();
            }
            catch(_) { }

            setState(() {
              
            });
          }
        ),
        _generateIntInput(
          textEditingController: _nameIdTextEditingController,
          label: "Name ID",
          onChanged: (value) {
            int newParamValue = 0;
            try {
              newParamValue = int.tryParse(value) ?? 0;
              pointData.nameId = newParamValue;
              widget.onUpdate();
            }
            catch(_) { }

            setState(() {
              
            });
          }
        ),
        _generateIntInput(
          textEditingController: _talkerIdTextEditingController,
          label: "Talker ID",
          onChanged: (value) {
            int newParamValue = 0;
            try {
              newParamValue = int.tryParse(value) ?? 0;
              pointData.talkerId = newParamValue;
              widget.onUpdate();
            }
            catch(_) { }

            setState(() {
              
            });
          }
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