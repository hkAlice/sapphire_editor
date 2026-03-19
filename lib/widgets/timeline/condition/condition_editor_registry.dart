import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/condition/trigger_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/eobjinteract_condition_model.dart';
import 'package:sapphire_editor/widgets/timeline/condition/combatstate_condition_widget.dart';
import 'package:sapphire_editor/widgets/timeline/condition/eobjinteract_condition_widget.dart';
import 'package:sapphire_editor/widgets/timeline/condition/getaction_condition_widget.dart';
import 'package:sapphire_editor/widgets/timeline/condition/hpminmax_condition_widget.dart';
import 'package:sapphire_editor/widgets/timeline/condition/interruptedaction_condition_widget.dart';
import 'package:sapphire_editor/widgets/timeline/condition/phaseactive_condition_widget.dart';
import 'package:sapphire_editor/widgets/timeline/condition/varequals_condition_widget.dart';

typedef ConditionEditorBuilder = Widget Function(
    ConditionEditorContext context);

class ConditionEditorContext {
  final TriggerModel conditionModel;

  const ConditionEditorContext({
    required this.conditionModel,
  });
}

class ConditionEditorRegistry {
  static final Map<ConditionType, ConditionEditorBuilder> _builders = {
    ConditionType.combatState: (context) => CombatStateConditionWidget(
          paramData: context.conditionModel.paramData,
        ),
    ConditionType.eObjInteract: (context) => EObjInteractConditionWidget(
          paramData:
              context.conditionModel.paramData as EObjInteractConditionModel,
        ),
    ConditionType.getAction: (context) => GetActionConditionWidget(
          paramData: context.conditionModel.paramData,
        ),
    ConditionType.hpPctBetween: (context) => HPMinMaxConditionWidget(
          paramData: context.conditionModel.paramData,
        ),
    ConditionType.phaseActive: (context) => PhaseActiveConditionWidget(
          paramData: context.conditionModel.paramData,
        ),
    ConditionType.interruptedAction: (context) =>
        InterruptedActionConditionWidget(
          paramData: context.conditionModel.paramData,
        ),
    ConditionType.varEquals: (context) => VarEqualsConditionWidget(
          paramData: context.conditionModel.paramData,
        ),
  };

  static Widget buildEditor(ConditionEditorContext context) {
    final builder = _builders[context.conditionModel.condition];
    if(builder == null) {
      return Text(
          'Unimplemented condition type ${context.conditionModel.condition.name}');
    }

    return builder(context);
  }
}
