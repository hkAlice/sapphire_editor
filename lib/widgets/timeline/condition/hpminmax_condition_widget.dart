import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sapphire_editor/models/timeline/condition/types/hppctbetween_condition_model.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';
import 'package:sapphire_editor/widgets/timeline/condition/condition_editor_scope.dart';
import 'package:sapphire_editor/widgets/timeline/timeline_lookup.dart';
import 'package:signals/signals_flutter.dart';

class HPMinMaxConditionWidget extends StatefulWidget {
  final HPPctBetweenConditionModel paramData;

  const HPMinMaxConditionWidget(
  {super.key, required this.paramData});

  @override
  State<HPMinMaxConditionWidget> createState() =>
      _HPMinMaxConditionWidgetState();
}

class _HPMinMaxConditionWidgetState extends State<HPMinMaxConditionWidget> {
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
              width: 150,
              child: GenericItemPickerWidget<String>(
                label: "Source Actor",
                items: timeline.actors.map((e) => e.name).toList(),
                initialValue:
                    widget.paramData.sourceActor ?? timeline.actors.first.name,
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
                label: "HP Min",
                initialValue: widget.paramData.hpMin,
                onChanged: (newValue) {
                  widget.paramData.hpMin = newValue;
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
                label: "HP Max",
                initialValue: widget.paramData.hpMax,
                onChanged: (newValue) {
                  widget.paramData.hpMax = newValue;
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
