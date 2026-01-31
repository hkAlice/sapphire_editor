import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sapphire_editor/models/timeline/condition/types/rngequals_condition_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';

class RNGEqualsConditionWidget extends StatefulWidget {
  final TimelineModel timelineModel;
  final RNGEqualsConditionModel paramData;
  final Function(RNGEqualsConditionModel) onUpdate;
  
  const RNGEqualsConditionWidget({super.key, required this.timelineModel, required this.paramData, required this.onUpdate});

  @override
  State<RNGEqualsConditionWidget> createState() => _RNGEqualsConditionWidgetState();
}

class _RNGEqualsConditionWidgetState extends State<RNGEqualsConditionWidget> {
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