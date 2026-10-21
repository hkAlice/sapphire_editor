import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sapphire_editor/models/timeline/condition/types/eobjanimation_condition_model.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';
import 'package:sapphire_editor/widgets/timeline/condition/condition_editor_scope.dart';
import 'package:sapphire_editor/widgets/timeline/timeline_lookup.dart';
import 'package:signals/signals_flutter.dart';

class EObjAnimationConditionWidget extends StatefulWidget {
  final EObjAnimationConditionModel paramData;

  const EObjAnimationConditionWidget(
  {super.key, required this.paramData});

  @override
  State<EObjAnimationConditionWidget> createState() =>
      _EObjAnimationConditionWidgetState();
}

class _EObjAnimationConditionWidgetState extends State<EObjAnimationConditionWidget> {
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
              child: TextField(
                decoration : InputDecoration(
                  labelText: "EObj Name"
                ),
                onChanged: (newValue) {
                  widget.paramData.eobjName = newValue;
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
                label: "Animation",
                initialValue: widget.paramData.animation,
                onChanged: (newValue) {
                  widget.paramData.animation = newValue;
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
