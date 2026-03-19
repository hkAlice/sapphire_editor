import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sapphire_editor/models/timeline/condition/types/combatstate_condition_model.dart';
import 'package:sapphire_editor/utils/text_utils.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/timeline/condition/condition_editor_scope.dart';
import 'package:sapphire_editor/widgets/timeline/timeline_lookup.dart';
import 'package:signals/signals_flutter.dart';

class CombatStateConditionWidget extends StatefulWidget {
  final CombatStateConditionModel paramData;

  const CombatStateConditionWidget(
  {super.key, required this.paramData});

  @override
  State<CombatStateConditionWidget> createState() =>
      _CombatStateConditionWidgetState();
}

class _CombatStateConditionWidgetState
    extends State<CombatStateConditionWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final scope = ConditionEditorScope.of(context);
      final signals = scope.signals;
      final timeline = signals.timeline.value;
      final conditionModel = TimelineNodeLookup.findCondition(
        signals,
        scope.actorId,
        scope.phaseId,
        scope.conditionId,
      );
      if(conditionModel == null) {
        return const SizedBox.shrink();
      }

      return Row(
        children: [
          SizedBox(
              width: 250,
              child: GenericItemPickerWidget<String>(
                label: "Source Actor",
                items: timeline.actors.map((e) => e.name).toList(),
                initialValue: widget.paramData.sourceActor,
                onChanged: (newValue) {
                  widget.paramData.sourceActor = newValue;
                  signals.updateCondition(
                    scope.actorId,
                    scope.phaseId,
                    scope.conditionId,
                    conditionModel,
                  );
                },
              )),
          const SizedBox(
            width: 18.0,
          ),
          SizedBox(
              width: 150,
              child: GenericItemPickerWidget<ActorCombatState>(
                label: "Combat State",
                items: ActorCombatState.values,
                initialValue: widget.paramData.combatState,
                onChanged: (newValue) {
                  widget.paramData.combatState = newValue;
                  signals.updateCondition(
                    scope.actorId,
                    scope.phaseId,
                    scope.conditionId,
                    conditionModel,
                  );
                },
                propertyBuilder: (e) {
                  return treatEnumName(e);
                },
              )),
        ],
      );
    });
  }
}
