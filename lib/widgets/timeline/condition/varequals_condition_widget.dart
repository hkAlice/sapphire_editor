import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sapphire_editor/models/timeline/condition/types/varequals_condition_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/utils/text_utils.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';

class VarEqualsConditionWidget extends StatefulWidget {
  final TimelineModel timelineModel;
  final VarEqualsConditionModel paramData;
  final Function(VarEqualsConditionModel) onUpdate;
  
  const VarEqualsConditionWidget({super.key, required this.timelineModel, required this.paramData, required this.onUpdate});

  @override
  State<VarEqualsConditionWidget> createState() => _VarEqualsConditionWidgetState();
}

class _VarEqualsConditionWidgetState extends State<VarEqualsConditionWidget> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
          SizedBox(
            width: 180,
            child: GenericItemPickerWidget<VarType>(
              label: "Var Type",
              initialValue: VarType.custom,
              items: VarType.values,
              propertyBuilder: (value) => treatEnumName(value),
              onChanged: (newValue) {
                widget.paramData.type = newValue;
                widget.onUpdate(widget.paramData);
                setState(() {
                  
                });
              },
            ),
          ),
          SizedBox(width: 18.0),
          SizedBox(
          width: 180,
          child: SimpleNumberField(
            label: "Index",
            initialValue: widget.paramData.index,
            onChanged: (newValue) {
              widget.paramData.index = newValue;
              widget.onUpdate(widget.paramData);
              setState(() {
                
              });
            },
          )
        ),
        SizedBox(width: 18.0),
        SizedBox(
          width: 180,
          child: SimpleNumberField(
            label: "Value",
            initialValue: widget.paramData.val,
            onChanged: (newValue) {
              widget.paramData.val = newValue;
              widget.onUpdate(widget.paramData);
              setState(() {
                
              });
            },
          )
        ),
      ],
    );
  }
}