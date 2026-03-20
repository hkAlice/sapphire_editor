import 'package:flutter/material.dart';
import 'package:sapphire_editor/widgets/signals_provider.dart';
import 'package:sapphire_editor/widgets/timeline/timeline_schedule_item.dart';
import 'package:sapphire_editor/widgets/timeline/timeline_onenter_item.dart';
import 'package:sapphire_editor/widgets/timeline/timeline_onexit_item.dart';
import 'package:sapphire_editor/widgets/add_generic_widget.dart';
import 'package:signals_flutter/signals_flutter.dart';

class ScheduleTabView extends StatelessWidget {
  final int actorId;

  const ScheduleTabView({super.key, required this.actorId});

  @override
  Widget build(BuildContext context) {
    final signals = SignalsProvider.of(context);

    return Watch((context) {
      final actors = signals.timeline.value.actors;
      if(actors.isEmpty) {
        return const SizedBox.shrink();
      }

      final actor = actors.firstWhere(
        (a) => a.id == actorId,
        orElse: () => actors.first,
      );

      if(actor.phases.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: AddGenericWidget(
              text: "New Phase",
              onTap: () {
                signals.addPhase(actor);
              },
            ),
          ),
        );
      }

      final selectedPhaseId = signals.selectedPhaseId.value;
      final phase = actor.phases.firstWhere(
        (p) => p.id == selectedPhaseId,
        orElse: () => actor.phases.first,
      );

      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 14.0, left: 14.0, right: 14.0),
              child: ListTile(
                leading: Image.asset(
                  "assets/images/icon_trials_rounded.png",
                  width: 36.0,
                ),
                title: Text(actor.name),
                subtitle: Text(
                  "LID: ${actor.layoutId.toString()}, HP: ${actor.hp.toString()}",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
              child: SizedBox(
            height: 8.0,
          )),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: TimelineOnEnterItem(actorId: actorId, phaseId: phase.id),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: TimelineOnExitItem(actorId: actorId, phaseId: phase.id),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            sliver: SliverList.builder(
              itemCount: phase.schedules.length,
              itemBuilder: (context, i) {
                return TimelineScheduleItem(
                  key: ValueKey("${phase.id}_${phase.schedules[i].id}"),
                  actorId: actor.id,
                  phaseId: phase.id,
                  scheduleId: phase.schedules[i].id,
                  scheduleIndex: i,
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: AddGenericWidget(
                  text: "New Schedule",
                  onTap: () {
                    signals.addScheduleToPhase(phase.id, actor);
                  }),
            ),
          ),
          SliverToBoxAdapter(
              child: Center(
            child: Text(
              "Tip: Click or right-click schedules and timepoints to edit them.",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withValues(alpha: 0.5)),
            ),
          )),
        ],
      );
    });
  }
}
