import 'package:flutter/material.dart';
import 'package:sapphire_editor/widgets/signals_provider.dart';
import 'package:sapphire_editor/widgets/timeline/tab_views/actor_tab_view.dart';
import 'package:sapphire_editor/widgets/timeline/tab_views/condition_tab_view.dart';
import 'package:sapphire_editor/widgets/timeline/tab_views/schedule_tab_view.dart';
import 'package:sapphire_editor/widgets/timeline/tab_views/selector_tab_view.dart';
import 'package:tab_container/tab_container.dart';
import 'package:signals_flutter/signals_flutter.dart';

class TimelineList extends StatelessWidget {
  const TimelineList({super.key});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      return TabContainer(
        borderRadius: BorderRadius.circular(16.0),
        tabEdge: TabEdge.top,
        curve: Curves.easeInOutCubic,
        transitionBuilder: (child, animation) {
          animation = CurvedAnimation(
            curve: Curves.easeInOutCubic,
            parent: animation
          );
          return SlideTransition(
            position: Tween(
              begin: const Offset(0.2, 0.0),
              end: const Offset(0.0, 0.0),
            ).animate(animation),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        selectedTextStyle:  Theme.of(context).textTheme.bodyLarge,
        unselectedTextStyle:  Theme.of(context).textTheme.bodyLarge,
        color: Theme.of(context).hoverColor,
        tabs: const <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cruelty_free_outlined, size: 22.0,),
              SizedBox(width: 8.0,),
              Text("Actor")
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.g_mobiledata, size: 28.0,),
              SizedBox(width: 8.0,),
              Text("Condition")
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.linear_scale_rounded, size: 22.0,),
              SizedBox(width: 8.0,),
              Text("Schedule")
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.scatter_plot_outlined, size: 22.0,),
              SizedBox(width: 8.0,),
              Text("Selector")
            ],
          )
        ],
        children: const <Widget>[
          ActorTabView(),
          ConditionTabView(),
          ScheduleTabView(),
          SelectorTabView()
        ]
      );
    });
  }
}
