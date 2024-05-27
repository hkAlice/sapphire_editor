import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/widgets/add_generic_widget.dart';
import 'package:sapphire_editor/widgets/small_heading_widget.dart';
import 'package:sapphire_editor/widgets/timeline/actor/actor_entry_item.dart';
import 'package:sapphire_editor/widgets/timeline/condition/phase_condition_item.dart';
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

  void _addNewPhaseCondition() {
    widget.timeline.addNewCondition();

    setState(() {
      
    });

    widget.onUpdate(widget.timeline);
  }

  @override
  Widget build(BuildContext context) {
    return TabContainer(
      borderRadius: BorderRadius.circular(20),
      tabEdge: TabEdge.top,
      curve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        animation = CurvedAnimation(
            curve: Curves.easeIn, parent: animation);
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
      color: const Color.fromARGB(255, 26, 26, 26),
      tabs: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cruelty_free_outlined, size: 22.0,),
            const SizedBox(width: 8.0,),
            Text("Actors", style: Theme.of(context).textTheme.bodyLarge,)
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.g_mobiledata, size: 28.0,),
            const SizedBox(width: 8.0,),
            Text("Conditions", style: Theme.of(context).textTheme.bodyLarge,)
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.linear_scale_rounded, size: 22.0,),
            const SizedBox(width: 8.0,),
            Text("Phases", style: Theme.of(context).textTheme.bodyLarge,)
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.scatter_plot_outlined, size: 22.0,),
            const SizedBox(width: 8.0,),
            Text("Selectors", style: Theme.of(context).textTheme.bodyLarge,)
          ],
        )
      ],
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(14.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                ActorEntryList(
                actors: widget.timeline.actors,
                onChanged: (currActor) {
                  _selectedActor = widget.timeline.actors.indexOf(currActor);
                  setState(() {
                    
                  });
            
                  widget.onUpdate(widget.timeline);
                }
              ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(14.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                ReorderableListView.builder(
                buildDefaultDragHandles: false,
                onReorder: (int oldindex, int newindex) {
                  setState(() {
                    if(newindex > oldindex) {
                      newindex -= 1;
                    }
                    final items = widget.timeline.conditions.removeAt(oldindex);
                    widget.timeline.conditions.insert(newindex, items);
                    widget.onUpdate(widget.timeline);
                  });
                },
                itemCount: widget.timeline.conditions.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, i) {
                  return PhaseConditionItem(
                    key: Key("condition_${widget.timeline.conditions[i].hashCode}"),
                    index: i,
                    timelineModel: widget.timeline,
                    phaseConditionModel: widget.timeline.conditions[i],
                    onUpdate: (phaseConditionModel) {
                      widget.onUpdate(widget.timeline);
                    },
                  );
                }
              ),
              AddGenericWidget(text: "Add new condition", onTap: () { _addNewPhaseCondition(); }),
              ],
            ),
          ),
        ),
          
        Padding(
          padding: const EdgeInsets.all(14.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
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