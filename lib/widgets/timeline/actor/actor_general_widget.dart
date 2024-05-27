import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/widgets/number_button.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';
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
            SmallHeadingWidget(
              title: "General",
              leading: OutlinedButton(
                onPressed: () {

                },
                child: const Row(
                  children: [
                    Icon(Icons.terminal_rounded),
                    SizedBox(width: 8.0,),
                    Text("Load BNPC data"),
                  ],
                )
              ),
            ),
            Row(
              children: [
                SizedBox(
                  width: 150,
                  child: SimpleNumberField(
                    initialValue: actor.layoutId,
                    label: "Layout ID",
                    onChanged: (value) {
                      actor.layoutId = value;
                      onChanged();
                    },
                  ),
                ),
                const SizedBox(width: 18.0,),
                SizedBox(
                  width: 150,
                  child: SimpleNumberField(
                    initialValue: actor.hp,
                    label: "HP",
                    onChanged: (value) {
                      actor.hp = value;
                      onChanged();
                    },
                  ),
                ),
                const SizedBox(width: 18.0,),
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