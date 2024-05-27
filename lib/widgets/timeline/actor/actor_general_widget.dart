import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/widgets/number_button.dart';
import 'package:sapphire_editor/widgets/small_heading_widget.dart';

class ActorGeneralWidget extends StatelessWidget {
  final ActorModel actor;
  final Function() onChanged;

  const ActorGeneralWidget({super.key, required this.actor, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            const SmallHeadingWidget(title: "General"),
            Row(
              children: [
                NumberButton(
                  min: 0,
                  max: 32,
                  value: actor.subactors.length,
                  label: "Subactors",
                  onChanged: (value) {
                    actor.subactors.clear();
                    for(int i = 0; i < value; i++) {
                      actor.subactors.add("${actor.name} <subactor ${i + 1}>");
                    }
            
                    onChanged();
                  }
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}