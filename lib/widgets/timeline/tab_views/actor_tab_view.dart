import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/widgets/timeline/actor/actor_detailed_select.dart';
import 'package:sapphire_editor/widgets/timeline/actor/actor_general_widget.dart';
import 'package:sapphire_editor/widgets/timeline/actor/actor_parts_widget.dart';

class ActorTabView extends StatelessWidget {
  final TimelineModel timelineModel;
  final int currentActorIndex;
  final Function(int) onChanged;

  const ActorTabView({super.key, required this.timelineModel, required this.currentActorIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    ActorModel selectedActor = timelineModel.actors.elementAt(currentActorIndex);
    
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            ActorDetailedSelect(
              actors: timelineModel.actors,
              onChanged: (currActor) {
                onChanged(currActor);
              }
            ),
            ActorGeneralWidget(
              actor: selectedActor,
              onChanged: () {
                onChanged(currentActorIndex);
              }
            ),
            ActorPartsWidget()
          ],
        ),
      ),
    );
  }
}