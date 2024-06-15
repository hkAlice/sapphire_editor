import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/widgets/number_button.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';
import 'package:sapphire_editor/widgets/small_heading_widget.dart';

class ActorGeneralWidget extends StatefulWidget {
  final int index;
  final ActorModel actorModel;
  final List<ActorModel> actors;
  final Function() onUpdate;

  const ActorGeneralWidget({super.key, required this.actorModel, required this.actors, required this.index, required this.onUpdate});

  @override
  State<ActorGeneralWidget> createState() => _ActorGeneralWidgetState();
}

class _ActorGeneralWidgetState extends State<ActorGeneralWidget> {
  late TextEditingController _localIdEditingController;
  late TextEditingController _layoutIdEditingController;
  late TextEditingController _hpEditingController;

  @override
  void initState() {
    _localIdEditingController = TextEditingController(text: widget.actorModel.id.toString());
    _layoutIdEditingController = TextEditingController(text: widget.actorModel.layoutId.toString());
    _hpEditingController = TextEditingController(text: widget.actorModel.hp.toString());
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // todo: fix this state issue in a proper manner
    _localIdEditingController.value = TextEditingValue(text: widget.actorModel.id.toString());
    _layoutIdEditingController.value = TextEditingValue(text: widget.actorModel.layoutId.toString());
    _hpEditingController.value = TextEditingValue(text: widget.actorModel.hp.toString());

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            const SmallHeadingWidget(
              title: "General",
              trailing: OutlinedButton(
                onPressed: null,
                child: Row(
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
                    initialValue: widget.actorModel.id,
                    controller: _localIdEditingController,
                    label: "Local ID",
                    enabled: false,
                    onChanged: (value) {},
                  ),
                ),
                const SizedBox(width: 18.0,),
                SizedBox(
                  width: 150,
                  child: SimpleNumberField(
                    initialValue: widget.actorModel.layoutId,
                    controller: _layoutIdEditingController,
                    label: "Layout ID",
                    onChanged: (value) {
                      widget.actorModel.layoutId = value;
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
                    initialValue: widget.actorModel.hp,
                    controller: _hpEditingController,
                    label: "HP",
                    onChanged: (value) {
                      widget.actorModel.hp = value;
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
                  value: widget.actorModel.subactors.length,
                  label: "Subactors",
                  onChanged: (value) {
                    widget.actorModel.subactors.clear();
                    for(int i = 0; i < value; i++) {
                      widget.actorModel.subactors.add("${widget.actorModel.name} <subactor ${i + 1}>");
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