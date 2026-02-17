import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sapphire_editor/models/timeline/condition/types/varequals_condition_model.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';
import 'package:sapphire_editor/utils/text_utils.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/signals_provider.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';
import 'package:signals/signals_flutter.dart';

class VarEqualsConditionWidget extends StatefulWidget {
  final VarEqualsConditionModel paramData;

  const VarEqualsConditionWidget({super.key, required this.paramData});

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
    final signals = SignalsProvider.of(context);
    
    return Watch((context) {
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
                signals.timeline.value = signals.timeline.value;
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
                signals.timeline.value = signals.timeline.value;
              }
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
                signals.timeline.value = signals.timeline.value;
              }
            )
          ),
        ],
      );
    });
  }
}