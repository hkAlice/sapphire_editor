import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/widgets/timeline/actor/actor_detailed_select.dart';
import 'package:sapphire_editor/widgets/timeline/actor/actor_general_widget.dart';
import 'package:sapphire_editor/widgets/timeline/actor/actor_parts_widget.dart';

class ActorTabView extends StatefulWidget {
  final TimelineModel timelineModel;
  final int currentActorIndex;
  final Function(int) onChanged;

  const ActorTabView({super.key, required this.timelineModel, required this.currentActorIndex, required this.onChanged});

  @override
  State<ActorTabView> createState() => _ActorTabViewState();
}

class _ActorTabViewState extends State<ActorTabView> {
  late ActorModel _selectedActor;

  @override
  void initState() {
    _selectedActor = widget.timelineModel.actors[widget.currentActorIndex];

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            ActorDetailedSelect(
              actors: widget.timelineModel.actors,
              index: widget.currentActorIndex,
              onChanged: (currActor) {
                widget.onChanged(currActor);
                setState(() {
                  _selectedActor = widget.timelineModel.actors.elementAt(currActor);
                });
                
              }
            ),
            ActorGeneralWidget(
              actors: widget.timelineModel.actors,
              actorModel: _selectedActor,
              index: widget.timelineModel.actors.indexOf(_selectedActor),
              onUpdate: () {
                setState(() {
                  
                });
                widget.onChanged(widget.currentActorIndex);
              }
            ),
            ActorPartsWidget()
          ],
        ),
      ),
    );
  }
}