import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/widgets/generic_search_picker_widget.dart';
import 'package:sapphire_editor/widgets/number_button.dart';

class ActorEntryList extends StatefulWidget {
  final List<ActorModel> actors;
  final Function(int) onChanged;

  const ActorEntryList({super.key, required this.actors, required this.onChanged});

  @override
  State<ActorEntryList> createState() => _ActorEntryListState();
}

class _ActorEntryListState extends State<ActorEntryList> {
  int _selectedActorIdx = 0;
  final TextEditingController iconController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    ActorModel _selectedActor = widget.actors.elementAt(_selectedActorIdx);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.max,
      children: [
        GenericSearchPickerWidget(
          items: widget.actors,
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(Icons.search),
              ),
              Image.asset("assets/images/icon_trials_rounded.png", width: 24.0,),
              const SizedBox(width: 8.0),
            ],
          ),
          onChanged: (value) {
            if(value == null) {
              return;
            }
        
            setState(() {
              _selectedActorIdx = widget.actors.indexOf(value);
            });
            
            widget.onChanged(_selectedActorIdx);
          },
          itemBuilder: (actorModel) {
            return DropdownMenuEntry(
              label: actorModel.name,
              value: actorModel,
              leadingIcon: Image.asset("assets/images/icon_trials_rounded.png", width: 24.0,),
              labelWidget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(actorModel.name),
                  Text("LID: ${actorModel.layoutId.toString()}, HP: ${actorModel.hp.toString()}", style: Theme.of(context).textTheme.bodySmall,)
                ],
              )
            );
          }
        ),
        Card(
          margin: const EdgeInsets.symmetric(vertical: 12.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                NumberButton(
                  min: 0,
                  max: 32,
                  value: _selectedActor.subactors.length,
                  label: "Subactors",
                  onChanged: (value) {
                    _selectedActor.subactors.clear();
                    for(int i = 0; i < value; i++) {
                      _selectedActor.subactors.add("${_selectedActor.name} <subactor ${i + 1}>");
                    }
                    setState(() {
                      
                    });
                    widget.onChanged(_selectedActorIdx);
                  }
                ),
              ],
            ),
          ),
        )
      ],
    );
    /*
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, i) {
        var actorModel = widget.actors[i];

        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: RadioListTile(
            value: i,
            groupValue: _selectedActor,
            onChanged: (newVal) {
              if(newVal == null) { return; }

              setState(() {
                _selectedActor = newVal;
              });

              widget.onChanged(widget.actors[i]);
            } ,
            title: Text(actorModel.name),
          ),
        );
      },
      itemCount: widget.actors.length,
    );*/
  }
}