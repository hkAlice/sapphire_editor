import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/condition/phase_conditions_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/setcondition_point_model.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/switch_text_widget.dart';

class SetConditionPointWidget extends StatefulWidget {
  final TimelineModel timelineModel;
  final TimepointModel timepointModel;
  final Function() onUpdate;

  const SetConditionPointWidget({super.key, required this.timelineModel, required this.timepointModel, required this.onUpdate});

  @override
  State<SetConditionPointWidget> createState() => _SetConditionPointWidgetState();
}

class _SetConditionPointWidgetState extends State<SetConditionPointWidget> {
  late SetConditionPointModel pointData = widget.timepointModel.data as SetConditionPointModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: 500,
          child: GenericItemPickerWidget<PhaseConditionModel>(
            label: "Condition",
            items: widget.timelineModel.conditions,
            initialValue: widget.timelineModel.conditions.firstWhereOrNull((e) => e.id == pointData.conditionId) ?? widget.timelineModel.conditions.first,
            propertyBuilder: (value) {
              return "(ID: ${value.id}) ${value.getReadableConditionStr()}";
            },
            onChanged: (newValue) {
              pointData.conditionId = newValue.id;
              pointData.conditionStr = newValue.getReadableConditionStr();
              widget.onUpdate();
              setState(() {
                
              });
            },
          ),
        ),
        const SizedBox(width: 18.0,),
        SwitchTextWidget(
          enabled: pointData.enabled,
          onPressed: () {
            pointData.enabled = !pointData.enabled;
            widget.onUpdate();
            setState(() {
              
            });
          }
        )
      ],
    );
  }
}