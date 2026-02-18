import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/hppctbetween_condition_model.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';
import 'package:sapphire_editor/widgets/signals_provider.dart';
import 'package:signals/signals_flutter.dart';

class HPMinMaxConditionWidget extends StatefulWidget {
  final int conditionId;
  final HPPctBetweenConditionModel paramData;
  
  const HPMinMaxConditionWidget({super.key, required this.conditionId, required this.paramData});

  @override
  State<HPMinMaxConditionWidget> createState() => _HPMinMaxConditionWidgetState();
}

class _HPMinMaxConditionWidgetState extends State<HPMinMaxConditionWidget> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final signals = SignalsProvider.of(context);
    return Watch((context) {
      final timeline = signals.timeline.value;
      final conditionModel = timeline.conditions.firstWhere((c) => c.id == widget.conditionId);
      
      return Row(
        children: [
          SizedBox(
            width: 150,
            child: GenericItemPickerWidget<ActorModel>(
              label: "Source Actor",
              items: timeline.actors,
              initialValue: timeline.actors.firstWhereOrNull((e) => e.name == widget.paramData.sourceActor),
              onChanged: (newValue) {
                widget.paramData.sourceActor = newValue.name;
                signals.updateCondition(widget.conditionId, conditionModel);
              },
            )
          ),
          const SizedBox(width: 18.0,),
          SizedBox(
            width: 150,
            child: SimpleNumberField(
              label: "HP Min",
              initialValue: widget.paramData.hpMin,
              onChanged: (newValue) {
                widget.paramData.hpMin = newValue;
                signals.updateCondition(widget.conditionId, conditionModel);
              },
            )
          ),
          const SizedBox(width: 18.0,),
          SizedBox(
            width: 150,
            child: SimpleNumberField(
              label: "HP Max",
              initialValue: widget.paramData.hpMax,
              onChanged: (newValue) {
                widget.paramData.hpMax = newValue;
                signals.updateCondition(widget.conditionId, conditionModel);
              },
            )
          ),
          
        ],
      );
    });
  }
}