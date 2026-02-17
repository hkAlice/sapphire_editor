import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/combatstate_condition_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/utils/text_utils.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';
import 'package:sapphire_editor/widgets/signals_provider.dart';
import 'package:signals/signals_flutter.dart';

class CombatStateConditionWidget extends StatefulWidget {
  final CombatStateConditionModel paramData;
  
  const CombatStateConditionWidget({super.key, required this.paramData});

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
    final signals = SignalsProvider.of(context);
    return Watch((context) {
      final timeline = signals.timeline.value;
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
              },
            )
          ),
          const SizedBox(width: 18.0,),
          SizedBox(
            width: 150,
            child: GenericItemPickerWidget<ActorCombatState>(
              label: "Combat State",
              items: ActorCombatState.values,
              initialValue: widget.paramData.combatState,
              onChanged: (newValue) {
                widget.paramData.combatState = newValue;
              },
              propertyBuilder: (e) {
                return treatEnumName(e);
              },
            )
          ),
        ],
      );
    });
  }
}