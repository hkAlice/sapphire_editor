import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/widgets/add_generic_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timeline_phase_item.dart';

class PhaseTabView extends StatefulWidget {
  final TimelineModel timelineModel;
  final int currentActorIndex;
  final Function() onUpdate;

  const PhaseTabView({super.key, required this.timelineModel, required this.currentActorIndex, required this.onUpdate});

  @override
  State<PhaseTabView> createState() => _PhaseTabViewState();
}

class _PhaseTabViewState extends State<PhaseTabView> {
  ActorModel _getCurrentActor() {
    return widget.timelineModel.actors[widget.currentActorIndex];
  }

  void _addNewPhase() {
    widget.timelineModel.addNewPhase(_getCurrentActor());
    widget.onUpdate();
  }
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 14.0, left: 14.0, right: 14.0),
            child: ListTile(
              leading: Image.asset("assets/images/icon_trials_rounded.png", width: 36.0,),
              title: Text(_getCurrentActor().name),
              subtitle: Text("LID: ${_getCurrentActor().layoutId.toString()}, HP: ${_getCurrentActor().hp.toString()}", style: Theme.of(context).textTheme.bodySmall,),
            ),
          ),
          const SizedBox(height: 8.0,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: ReorderableListView.builder(
              
              buildDefaultDragHandles: false,
              onReorder: (int oldindex, int newindex) {
                setState(() {
                  if(newindex > oldindex) {
                    newindex -= 1;
                  }
                  final items = _getCurrentActor().phases.removeAt(oldindex);
                  _getCurrentActor().phases.insert(newindex, items);
                });
            
                widget.onUpdate();
              },
              itemCount: _getCurrentActor().phases.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, i) {
                return TimelinePhaseItem(
                  key: Key("phase_${_getCurrentActor().phases[i].hashCode}"),
                  index: i,
                  selectedActor: _getCurrentActor(),
                  timelineModel: widget.timelineModel,
                  phaseModel: _getCurrentActor().phases[i],
                  onUpdate: (phaseModel) {
                    widget.onUpdate();
                  },
                );
              }
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 14.0, right: 14.0, bottom: 14.0),
            child: AddGenericWidget(
              text: "New phase",
              onTap: () {
                _addNewPhase();
                setState(() {
                  
                });
              }
            ),
          )
        ],
      ),
    );
  }
}