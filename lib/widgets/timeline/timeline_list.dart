import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/widgets/timeline/tab_views/actor_tab_view.dart';
import 'package:sapphire_editor/widgets/timeline/tab_views/condition_tab_view.dart';
import 'package:sapphire_editor/widgets/timeline/tab_views/phase_tab_view.dart';
import 'package:sapphire_editor/widgets/timeline/tab_views/selector_tab_view.dart';
import 'package:tab_container/tab_container.dart';

class TimelineList extends StatefulWidget {
  final TimelineModel timeline;
  final Function(TimelineModel) onUpdate;
  const TimelineList({super.key, required this.onUpdate, required this.timeline});

  @override
  State<TimelineList> createState() => _TimelineListState();
}

class _TimelineListState extends State<TimelineList> {
  late TextEditingController _nameTextEditingController;
  int _selectedActor = 0;

  @override
  void initState() {
    _nameTextEditingController = TextEditingController(text: widget.timeline.name);

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
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
            Text("Actors")
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.g_mobiledata, size: 28.0,),
            SizedBox(width: 8.0,),
            Text("Conditions")
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.linear_scale_rounded, size: 22.0,),
            SizedBox(width: 8.0,),
            Text("Phases")
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.scatter_plot_outlined, size: 22.0,),
            SizedBox(width: 8.0,),
            Text("Selectors")
          ],
        )
      ],
      children: <Widget>[ 
        ActorTabView(
          timelineModel: widget.timeline,
          currentActorIndex: _selectedActor,
          onChanged: (actorIdx) {
            _selectedActor = actorIdx;

            widget.onUpdate(widget.timeline);
            setState(() {
              
            });
          }
        ),
        ConditionTabView(
          timelineModel: widget.timeline,
          onUpdate: () {
            widget.onUpdate(widget.timeline);
          }
        ),
        PhaseTabView(
          timelineModel: widget.timeline,
          currentActorIndex: _selectedActor,
          onUpdate: () {
            widget.onUpdate(widget.timeline);
          }
        ),
        SelectorTabView(
          timelineModel: widget.timeline,
          onUpdate: () {
            widget.onUpdate(widget.timeline);
          }
        )
      ]
    );
  }
}