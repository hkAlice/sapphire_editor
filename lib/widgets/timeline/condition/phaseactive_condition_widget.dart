import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/phaseactive_condition_model.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/timeline/condition/condition_editor_scope.dart';
import 'package:sapphire_editor/widgets/timeline/timeline_lookup.dart';
import 'package:signals/signals_flutter.dart';

class PhaseActiveConditionWidget extends StatefulWidget {
  final PhaseActiveConditionModel paramData;

  const PhaseActiveConditionWidget({super.key, required this.paramData});

  @override
  State<PhaseActiveConditionWidget> createState() =>
      _PhaseActiveConditionWidgetState();
}

class _PhaseActiveConditionWidgetState
    extends State<PhaseActiveConditionWidget> {
  late ActorModel? _selectedActor;

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

      _selectedActor = timeline.actors
          .firstWhereOrNull((e) => e.name == widget.paramData.sourceActor);

      return Row(
        children: [
          SizedBox(
              width: 180,
              child: GenericItemPickerWidget<String>(
                label: "Source Actor",
                items: timeline.actors.map((e) => e.name).toList(),
                initialValue: widget.paramData.sourceActor,
                onChanged: (newValue) {
                  _selectedActor = timeline.actors
                      .firstWhereOrNull((e) => e.name == newValue);

                  widget.paramData.sourceActor = newValue;

                  if(_selectedActor == null ||
                      _selectedActor!.phases.isEmpty) {
                    widget.paramData.phaseId = "<unset>";
                  } else {
                    widget.paramData.phaseId = _selectedActor!.phases.first.id;
                  }

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
            width: 240,
            child: GenericItemPickerWidget<String>(
              label: "Phase",
              items: _selectedActor == null
                  ? []
                  : _selectedActor!.phases.map((e) => e.id).toList(),
              initialValue: widget.paramData.phaseId,
              propertyBuilder: (phaseId) {
                if(_selectedActor == null) {
                  return phaseId;
                }

                return _selectedActor!.phases
                        .firstWhereOrNull((phase) => phase.id == phaseId)
                        ?.name ??
                    phaseId;
              },
              onChanged: (value) {
                widget.paramData.phaseId = value;
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
