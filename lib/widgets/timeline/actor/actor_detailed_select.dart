import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/widgets/generic_search_picker_widget.dart';

class ActorDetailedSelect extends StatefulWidget {
  final List<ActorModel> actors;
  final int index;
  final Function(int) onChanged;

  const ActorDetailedSelect({super.key, required this.actors, required this.index, required this.onChanged});

  @override
  State<ActorDetailedSelect> createState() => _ActorDetailedSelectState();
}

class _ActorDetailedSelectState extends State<ActorDetailedSelect> {
  late int _selectedActorIdx = widget.index;
  final TextEditingController iconController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.max,
      children: [
        GenericSearchPickerWidget(
          value: widget.actors[widget.index],
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
      ],
    );
  }
}