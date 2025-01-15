import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sapphire_editor/models/timeline/condition/condition_model.dart';

class GenericConditionParam extends StatefulWidget {
  final ConditionModel conditionModel;
  final List<ConditionParamParser> paramData;
  final Function() onUpdate;

  const GenericConditionParam({super.key, required this.conditionModel, required this.paramData, required this.onUpdate});

  @override
  State<GenericConditionParam> createState() => _GenericConditionParamState();
}

class _GenericConditionParamState extends State<GenericConditionParam> {
  final List<TextEditingController> _paramTextControllers = [];
  final List<Widget> _paramWidgets = [];
  late ConditionType _lastConditionType;

  @override
  void initState() {
    // if only dart setters could shadow same name as the field
    //widget.phaseConditionModel.params = List<int>.filled(widget.paramData.length, 0, growable: true);
    _buildParamWidgets();

    super.initState();
  }

  @override
  void dispose() {
    for(var controller in _paramTextControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  void _buildParamWidgets() {
    for(var controller in _paramTextControllers) {
      controller.dispose();
    }

    _paramTextControllers.clear();
    _paramWidgets.clear();

    for(int i = 0; i < widget.paramData.length; i++) {
      // todo: add actor, phase select, etc
      // for now every param is a boring text input
      var paramParser = widget.paramData[i];
      var paramTextController = TextEditingController(text: paramParser.initialValue.toString());
      _paramTextControllers.add(paramTextController);

      _paramWidgets.add(
        SizedBox(
          width: 150,
          child: TextFormField(
            maxLines: 1,
            keyboardType: paramParser.isHex ? TextInputType.text : TextInputType.number,
            inputFormatters: paramParser.isHex ? null : <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            controller: paramTextController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              label: Text(paramParser.label),
            ),
            onChanged: (value) {
              int newParamValue = 0;
              try {
                newParamValue = int.tryParse(value, radix: paramParser.isHex ? 16 : null) ?? 0;
              }
              catch(e) {
                // failed to parse, ignore
                return;
              }

              paramTextController.text = paramParser.isHex ? newParamValue.toRadixString(16) : newParamValue.toString();
              paramTextController.selection = TextSelection.collapsed(offset: paramTextController.text.length);
          
              //widget.phaseConditionModel.params[i] = newParamValue;
              widget.onUpdate();

              setState(() {
                
              });
            },
          ),
        ),
      );
    }

    _lastConditionType = widget.conditionModel.condition;
  }

  @override
  Widget build(BuildContext context) {
    if(_lastConditionType != widget.conditionModel.condition) {
      _buildParamWidgets();
    }

    return Row(
      children: _paramWidgets,
    );
  }
}