import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/widgets/add_generic_widget.dart';
import 'package:sapphire_editor/widgets/timeline/tab_views/actor_tab_view.dart';
import 'package:sapphire_editor/widgets/timeline/tab_views/condition_tab_view.dart';
import 'package:sapphire_editor/widgets/timeline/timeline_phase_item.dart';
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

  ActorModel _getCurrentActor() {
    return widget.timeline.actors[_selectedActor];
  }

  void _addNewPhase() {
    widget.timeline.addNewPhase(_getCurrentActor());
    setState(() {
      
    });
    widget.onUpdate(widget.timeline);
  }

  @override
  Widget build(BuildContext context) {
    return TabContainer(
      borderRadius: BorderRadius.circular(16.0),
      tabEdge: TabEdge.top,
      curve: Curves.easeInOutCubic,
      transitionBuilder: (child, animation) {
        animation = CurvedAnimation(
          curve: Curves.easeInOutCubic, parent: animation
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
      unselectedTextStyle:  Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white70),
      color: const Color.fromARGB(255, 26, 26, 26),
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
        // todo: all this should be split into its own stl widgets
        ActorTabView(
          timelineModel: widget.timeline,
          currentActorIndex: _selectedActor,
          onChanged: (actorIdx) {
            _selectedActor = actorIdx;
            setState(() {
              
            });
            widget.onUpdate(widget.timeline);
          }
        ),
        ConditionTabView(
          timelineModel: widget.timeline,
          onUpdate: () {
            setState(() {
              
            });
            widget.onUpdate(widget.timeline);
          }
        ),
        Padding(
          padding: const EdgeInsets.all(14.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                ListTile(
                  leading: Image.asset("assets/images/icon_trials_rounded.png", width: 36.0,),
                  title: Text(_getCurrentActor().name),
                  subtitle: Text("LID: ${_getCurrentActor().layoutId.toString()}, HP: ${_getCurrentActor().hp.toString()}", style: Theme.of(context).textTheme.bodySmall,),
                ),
                const SizedBox(height: 8.0,),
                ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  onReorder: (int oldindex, int newindex) {
                    setState(() {
                      if(newindex > oldindex) {
                        newindex -= 1;
                      }
                      final items = _getCurrentActor().phases.removeAt(oldindex);
                      _getCurrentActor().phases.insert(newindex, items);
                    });
                
                    widget.onUpdate(widget.timeline);
                  },
                  itemCount: _getCurrentActor().phases.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, i) {
                    return TimelinePhaseItem(
                      key: Key("phase_${_getCurrentActor().phases[i].hashCode}"),
                      index: i,
                      timelineModel: widget.timeline,
                      phaseModel: _getCurrentActor().phases[i],
                      onUpdate: (phaseModel) {
                        widget.onUpdate(widget.timeline);
                      },
                    );
                  }
                ),
                AddGenericWidget(text: "Add new phase", onTap: () { _addNewPhase(); })
              ],
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Placeholder(child: Center(child: Text("Not yet. The voices...")),),
            ],
          ),
        ),
      ]
    );
  }
}