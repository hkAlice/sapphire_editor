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
  @override
  Widget build(BuildContext context) {
    ActorModel selectedActor = widget.timelineModel.actors.elementAt(widget.currentActorIndex);
    
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            ActorDetailedSelect(
              actors: widget.timelineModel.actors,
              index: widget.currentActorIndex,
              onChanged: (currActor) {
                setState(() {
                  
                });
                widget.onChanged(currActor);
              }
            ),
            ActorGeneralWidget(
              actors: widget.timelineModel.actors,
              index: widget.currentActorIndex,
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