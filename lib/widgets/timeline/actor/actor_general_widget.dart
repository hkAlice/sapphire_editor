import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/widgets/number_button.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';
import 'package:sapphire_editor/widgets/small_heading_widget.dart';

class ActorGeneralWidget extends StatefulWidget {
  final int index;
  final List<ActorModel> actors;
  final Function() onUpdate;

  const ActorGeneralWidget({super.key, required this.actors, required this.index, required this.onUpdate});

  @override
  State<ActorGeneralWidget> createState() => _ActorGeneralWidgetState();
}

class _ActorGeneralWidgetState extends State<ActorGeneralWidget> {
  @override
  Widget build(BuildContext context) {
    var actor = widget.actors[widget.index];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            SmallHeadingWidget(
              title: "General",
              trailing: OutlinedButton(
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
                  width: 80,
                  child: SimpleNumberField(
                    initialValue: actor.id,
                    label: "Local ID",
                    enabled: false,
                    onChanged: (value) {},
                  ),
                ),
                const SizedBox(width: 18.0,),
                SizedBox(
                  width: 150,
                  child: SimpleNumberField(
                    initialValue: actor.layoutId,
                    label: "Layout ID",
                    onChanged: (value) {
                      actor.layoutId = value;
                      setState(() {
                        
                      });
                      widget.onUpdate();
                    },
                  ),
                ),
                const SizedBox(width: 18.0,),
                SizedBox(
                  width: 110,
                  child: SimpleNumberField(
                    initialValue: actor.hp,
                    label: "HP",
                    onChanged: (value) {
                      actor.hp = value;
                      setState(() {
                        
                      });
                      widget.onUpdate();
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
            
                    widget.onUpdate();
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