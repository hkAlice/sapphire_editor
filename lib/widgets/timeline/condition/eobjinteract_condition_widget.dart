import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/condition/types/eobjinteract_condition_model.dart';
import 'package:sapphire_editor/widgets/timeline/condition/condition_editor_scope.dart';
import 'package:sapphire_editor/widgets/timeline/timeline_lookup.dart';
import 'package:signals/signals_flutter.dart';

class EObjInteractConditionWidget extends StatefulWidget {
  final EObjInteractConditionModel paramData;

  const EObjInteractConditionWidget(
  {super.key, required this.paramData});

  @override
  State<EObjInteractConditionWidget> createState() =>
      _EObjInteractConditionWidgetState();
}

class _EObjInteractConditionWidgetState
    extends State<EObjInteractConditionWidget> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.paramData.eObjName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final scope = ConditionEditorScope.of(context);
      final signals = scope.signals;
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
            width: 260,
            child: TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "EObj Name",
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (newValue) {
                widget.paramData.eObjName = newValue;

                signals.updateCondition(
                  scope.actorId,
                  scope.phaseId,
                  scope.conditionId,
                  conditionModel,
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
