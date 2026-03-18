import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/scheduleactive_condition_model.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/timeline/condition/condition_editor_scope.dart';
import 'package:sapphire_editor/widgets/timeline/timeline_lookup.dart';
import 'package:signals/signals_flutter.dart';

class ScheduleActiveConditionWidget extends StatefulWidget {
  final ScheduleActiveConditionModel paramData;

  const ScheduleActiveConditionWidget(
  {super.key, required this.paramData});

  @override
  State<ScheduleActiveConditionWidget> createState() =>
      _ScheduleActiveConditionWidgetState();
}

class _ScheduleActiveConditionWidgetState
    extends State<ScheduleActiveConditionWidget> {
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
                      _selectedActor!.schedules.isEmpty) {
                    widget.paramData.scheduleName = "<unset>";
                  } else {
                    widget.paramData.scheduleName =
                        _selectedActor!.schedules.first.name;
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
              label: "Schedule",
              items: _selectedActor == null
                  ? []
                  : _selectedActor!.schedules.map((e) => e.name).toList(),
              initialValue: widget.paramData.scheduleName,
              onChanged: (value) {
                widget.paramData.scheduleName = value;
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
