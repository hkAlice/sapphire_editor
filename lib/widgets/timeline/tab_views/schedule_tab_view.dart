import 'package:flutter/material.dart';
import 'package:sapphire_editor/widgets/signals_provider.dart';
import 'package:sapphire_editor/widgets/timeline/timeline_schedule_item.dart';
import 'package:sapphire_editor/widgets/add_generic_widget.dart';
import 'package:signals_flutter/signals_flutter.dart';

class ScheduleTabView extends StatelessWidget {
  final int actorId;

  const ScheduleTabView({
    super.key,
    required this.actorId
  });

  @override
  Widget build(BuildContext context) {
    final signals = SignalsProvider.of(context);

    return Watch((context) {
      final actor = signals.timeline.value.actors.firstWhere(
        (a) => a.id == actorId,
        orElse: () => signals.timeline.value.actors.first,
      );

      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 14.0, left: 14.0, right: 14.0),
              child: ListTile(
                leading: Image.asset("assets/images/icon_trials_rounded.png", width: 36.0,),
                title: Text(actor.name),
                subtitle: Text("LID: ${actor.layoutId.toString()}, HP: ${actor.hp.toString()}", style: Theme.of(context).textTheme.bodySmall,),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8.0,)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            sliver: SliverReorderableList(
              itemCount: actor.schedules.length,
              onReorder: (int oldindex, int newindex) {
                signals.reorderSchedule(actor, oldindex, newindex);
              },
              itemBuilder: (context, i) {
                return TimelineScheduleItem(
                  key: ValueKey(actor.schedules[i].id),
                  scheduleId: actor.schedules[i].id,
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
                  signals.addSchedule(actor);
                }
              ),
            ),
          )
        ],
      );
    });
  }
}
