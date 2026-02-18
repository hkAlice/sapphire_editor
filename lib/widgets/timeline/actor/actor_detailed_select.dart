import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/widgets/generic_search_picker_widget.dart';
import 'package:sapphire_editor/widgets/signals_provider.dart';
import 'package:signals_flutter/signals_flutter.dart';

class ActorDetailedSelect extends StatefulWidget {
  final List<ActorModel> actors;
  final int actorId;

  const ActorDetailedSelect({super.key, required this.actors, required this.actorId});

  @override
  State<ActorDetailedSelect> createState() => _ActorDetailedSelectState();
}

class _ActorDetailedSelectState extends State<ActorDetailedSelect> {
  final TextEditingController iconController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    final signals = SignalsProvider.of(context);
    
    return Watch((context) {
      final actor = signals.selectedActor.value;
      final schedule = signals.selectedSchedule.value;
      final timeline = signals.timeline.value;


      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        children: [
          GenericSearchPickerWidget(
            value: widget.actors.firstWhere(
              (a) => a.id == actor.id,
              orElse: () => widget.actors.isNotEmpty ? widget.actors.first : throw StateError("No actors available"),
            ),
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
              signals.selectActor(value.id);
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
    });
  }
}