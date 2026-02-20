import 'package:flutter/material.dart';
import 'package:sapphire_editor/widgets/timeline/tab_views/actor_tab_view.dart';
import 'package:sapphire_editor/widgets/timeline/tab_views/condition_tab_view.dart';
import 'package:sapphire_editor/widgets/timeline/tab_views/schedule_tab_view.dart';
import 'package:sapphire_editor/widgets/timeline/tab_views/selector_tab_view.dart';
import 'package:signals_flutter/signals_flutter.dart';

class TimelineList extends StatelessWidget {
  final int actorId;

  const TimelineList({
    super.key,
    required this.actorId
  });

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      return DefaultTabController(
        length: 4,
        child: Column(
          children: [
            TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: Theme.of(context).hoverColor,
                borderRadius: BorderRadius.circular(16.0),
              ),
              labelStyle: Theme.of(context).textTheme.bodyLarge,
              unselectedLabelStyle: Theme.of(context).textTheme.bodyLarge,
              tabs: const [
                Tab(icon: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cruelty_free_outlined, size: 22.0),
                    SizedBox(width: 8.0),
                    Text("Actor"),
                  ],
                )),
                Tab(icon: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.g_mobiledata, size: 28.0),
                    SizedBox(width: 8.0),
                    Text("Condition"),
                  ],
                )),
                Tab(icon: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.linear_scale_rounded, size: 22.0),
                    SizedBox(width: 8.0),
                    Text("Schedule"),
                  ],
                )),
                Tab(icon: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.scatter_plot_outlined, size: 22.0),
                    SizedBox(width: 8.0),
                    Text("Selector"),
                  ],
                )),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ActorTabView(),
                  ConditionTabView(),
                  ScheduleTabView(
                    actorId: actorId,
                  ),
                  SelectorTabView(),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
