import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/widgets/add_generic_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/generic_timepoint_item.dart';
import 'package:sapphire_editor/widgets/signals_provider.dart';
import 'package:signals_flutter/signals_flutter.dart';

class TimelineOnEnterItem extends StatelessWidget {
  final int actorId;
  final String phaseId;

  const TimelineOnEnterItem({
    super.key,
    required this.actorId,
    required this.phaseId,
  });

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

      final timepointCountStr =
          "${phase.onEnter.length} timepoint${(phase.onEnter.length != 1 ? 's' : '')}";
      double lastTimepoint = 0.0;
      if(phase.onEnter.isNotEmpty) {
        lastTimepoint = phase.onEnter.last.startTime / 1000.0;
      }

      return Card(
        margin: const EdgeInsets.only(bottom: 12.0),
        borderOnForeground: false,
        elevation: 1.0,
        child: ExpansionTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          initiallyExpanded: true,
          title: const Text("On Enter (Triggers)"),
          subtitle: Text(timepointCountStr),
          trailing: SizedBox(
            width: 48.0,
            child: Text(
              "${lastTimepoint.toStringAsFixed(1)}s",
              textAlign: TextAlign.end,
            ),
          ),
          childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: [
            if(phase.onEnter.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Text("Timepoints here will trigger immediately when the phase starts."),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: phase.onEnter.length,
                itemBuilder: (context, i) {
                  return GenericTimepointItem(
                    key: ValueKey("${phase.id}_onEnter_${phase.onEnter[i].id}"),
                    actorId: actorId,
                    phaseId: phase.id,
                    timepointId: phase.onEnter[i].id,
                    scheduleIndex: -1,
                    scheduleId: -1,
                    timepointIndex: i,
                    timeElapsedMs: 0,
                  );
                },
              ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
              child: AddGenericWidget(
                text: "New Entry Timepoint",
                onTap: () {
                  final nextTimepointId =
                      signals.generateNextTimepointIdForPhase(actorId, phase.id);

                  signals.addTimepointInPhase(
                    actorId,
                    phase.id,
                    null, // to onEntry
                    TimepointModel(
                      id: nextTimepointId,
                      type: TimepointType.logMessage,
                      startTime: 0,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
