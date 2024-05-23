import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';

class ActorEntryList extends StatefulWidget {
  final List<ActorModel> actors;
  final Function(ActorModel) onChanged;

  const ActorEntryList({super.key, required this.actors, required this.onChanged});

  @override
  State<ActorEntryList> createState() => _ActorEntryListState();
}

class _ActorEntryListState extends State<ActorEntryList> {
  int _currValue = 0;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, i) {
        var actorModel = widget.actors[i];

        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: RadioListTile(
            value: i,
            groupValue: _currValue,
            onChanged: (newVal) {
              if(newVal == null) { return; }

              setState(() {
                _currValue = newVal;
              });

              widget.onChanged(widget.actors[i]);
            } ,
            title: Text(actorModel.name),
          ),
        );
      },
      itemCount: widget.actors.length,
    );
  }
}