import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/conditions/types/combatstate_condition_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/utils/text_utils.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';

class CombatStateConditionWidget extends StatefulWidget {
  final TimelineModel timelineModel;
  final CombatStateConditionModel paramData;
  final Function(CombatStateConditionModel) onUpdate;
  
  const CombatStateConditionWidget({super.key, required this.timelineModel, required this.paramData, required this.onUpdate});

  @override
  State<CombatStateConditionWidget> createState() => _CombatStateConditionWidgetState();
}

class _CombatStateConditionWidgetState extends State<CombatStateConditionWidget> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 150,
          child: GenericItemPickerWidget<ActorModel>(
            label: "Actor",
            items: widget.timelineModel.actors,
            onChanged: (newValue) {
              widget.paramData.sourceActor = newValue.name;
              widget.onUpdate(widget.paramData);
              setState(() {
                
              });
            },
          )
        ),
        SizedBox(
          width: 150,
          child: GenericItemPickerWidget<ActorCombatState>(
            label: "Actor",
            items: ActorCombatState.values,
            onChanged: (newValue) {
              widget.paramData.combatState = newValue;
              widget.onUpdate(widget.paramData);
              setState(() {
                
              });
            },
            propertyBuilder: (e) {
              return treatEnumName(e);
            },
          )
        ),
      ],
    );
  }
}