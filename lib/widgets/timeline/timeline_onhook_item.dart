import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/widgets/timeline/imgui_schedule_container.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/generic_timepoint_item.dart';
import 'package:sapphire_editor/widgets/timeline/timeline_lookup.dart';
import 'package:sapphire_editor/widgets/signals_provider.dart';
import 'package:signals_flutter/signals_flutter.dart';

enum TimelineHookType {
  onEnter,
  onExit,
}

class TimelineOnHookItem extends StatelessWidget {
  final int actorId;
  final int phaseId;
  final TimelineHookType hookType;

  const TimelineOnHookItem({
    super.key,
    required this.actorId,
    required this.phaseId,
    required this.hookType,
  });

  int get _scheduleId {
    return hookType == TimelineHookType.onEnter
        ? TimelineNodeLookup.onEnterScheduleId
        : TimelineNodeLookup.onExitScheduleId;
  }

  String get _hookKey {
    return hookType == TimelineHookType.onEnter ? 'onEnter' : 'onExit';
  }

  String get _title {
    return hookType == TimelineHookType.onEnter
        ? 'On Enter (Triggers)'
        : 'On Exit (Triggers)';
  }

  String get _emptyDescription {
    return hookType == TimelineHookType.onEnter
        ? 'Timepoints here will trigger immediately when the phase starts.'
        : 'Timepoints here will trigger immediately when the phase ends.';
  }

  String get _newTimepointText {
    return hookType == TimelineHookType.onEnter
        ? 'Add new timepoint'
        : 'Add new Timepoint';
  }

  @override
  Widget build(BuildContext context) {
    final signals = SignalsProvider.of(context);

    final phaseSignal = computed(() {
      final actors = signals.timeline.value.actors;
      final actor = actors.firstWhere(
        (a) => a.id == actorId,
        orElse: () => actors.first,
      );
      return actor.phases.firstWhere(
        (p) => p.id == phaseId,
        orElse: () => actor.phases.first,
      );
    });

    return Watch((context) {
      final phase = phaseSignal.value;
      final timepoints =
          hookType == TimelineHookType.onEnter ? phase.onEnter : phase.onExit;

      final timepointCountStr =
          '${timepoints.length} timepoint${(timepoints.length != 1 ? 's' : '')}';
      double lastTimepoint = 0.0;
      if(timepoints.isNotEmpty) {
        lastTimepoint = timepoints.last.startTime / 1000.0;
      }

      return ImGuiScheduleContainer(
        title: Text(_title),
        subtitle: Text(timepointCountStr),
        trailingText: '${lastTimepoint.toStringAsFixed(1)}s',
        addButtonText: '+ $_newTimepointText',
        onAddTap: () {
          final nextTimepointId =
              signals.generateNextTimepointIdForPhase(actorId, phase.id);

          signals.addTimepointInPhase(
            actorId,
            phase.id,
            _scheduleId,
            TimepointModel(
              id: nextTimepointId,
              type: TimepointType.logMessage,
              startTime: 0,
            ),
          );
        },
        child: timepoints.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Center(
                  child: Text(
                    _emptyDescription,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withValues(alpha: 0.5)),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: timepoints.length,
                itemBuilder: (context, i) {
                  return GenericTimepointItem(
                    key: ValueKey(
                        '${phase.id}_${_hookKey}_${timepoints[i].id}'),
                    actorId: actorId,
                    phaseId: phase.id,
                    timepointId: timepoints[i].id,
                    scheduleIndex: -1,
                    scheduleId: _scheduleId,
                    timepointIndex: i,
                    timeElapsedMs: 0,
                  );
                },
              ),
      );
    });
  }
}
