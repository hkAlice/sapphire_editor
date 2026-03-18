import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sapphire_editor/models/timeline/condition/types/getaction_condition_model.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';
import 'package:sapphire_editor/widgets/timeline/condition/condition_editor_scope.dart';
import 'package:sapphire_editor/widgets/timeline/timeline_lookup.dart';
import 'package:signals/signals_flutter.dart';

class GetActionConditionWidget extends StatefulWidget {
  final GetActionConditionModel paramData;

  const GetActionConditionWidget(
  {super.key, required this.paramData});

  @override
  State<GetActionConditionWidget> createState() =>
      _GetActionConditionWidgetState();
}

class _GetActionConditionWidgetState extends State<GetActionConditionWidget> {
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
              width: 180,
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
              child: SimpleNumberField(
                label: "Action ID",
                initialValue: widget.paramData.actionId,
                onChanged: (newValue) {
                  widget.paramData.actionId = newValue;
                  signals.updateCondition(
                    scope.actorId,
                    scope.phaseId,
                    scope.conditionId,
                    conditionModel,
                  );
                },
              )),
        ],
      );
    });
  }
}
