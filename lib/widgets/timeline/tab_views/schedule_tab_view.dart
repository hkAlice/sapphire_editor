import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/widgets/add_generic_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timeline_schedule_item.dart';

class ScheduleTabView extends StatefulWidget {
  final TimelineModel timelineModel;
  final int currentActorIndex;
  final Function() onUpdate;

  const ScheduleTabView({super.key, required this.timelineModel, required this.currentActorIndex, required this.onUpdate});

  @override
  State<ScheduleTabView> createState() => _ScheduleTabViewState();
}

class _ScheduleTabViewState extends State<ScheduleTabView> {
  ActorModel _getCurrentActor() {
    return widget.timelineModel.actors[widget.currentActorIndex];
  }

  void _onUpdate() {
    try {
      for(var actor in widget.timelineModel.actors) {
        for(var schedule in actor.schedules) {
          schedule.timepoints.sort((a, b) => a.startTime.compareTo(b.startTime));
        }
      }
    }
    catch(_) {}
    
    widget.onUpdate();
  }

  void _addNewSchedule() {
    widget.timelineModel.addNewSchedule(_getCurrentActor());
  }
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 14.0, left: 14.0, right: 14.0),
            child: ListTile(
              leading: Image.asset("assets/images/icon_trials_rounded.png", width: 36.0,),
              title: Text(_getCurrentActor().name),
              subtitle: Text("LID: ${_getCurrentActor().layoutId.toString()}, HP: ${_getCurrentActor().hp.toString()}", style: Theme.of(context).textTheme.bodySmall,),
            ),
          ),
          const SizedBox(height: 8.0,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: ReorderableListView.builder(
              buildDefaultDragHandles: false,
              onReorder: (int oldindex, int newindex) {
                setState(() {
                  if(newindex > oldindex) {
                    newindex -= 1;
                  }
                  final items = _getCurrentActor().schedules.removeAt(oldindex);
                  _getCurrentActor().schedules.insert(newindex, items);
                });
            
                _onUpdate();
              },
              itemCount: _getCurrentActor().schedules.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, i) {
                return TimelineScheduleItem(
                  key: Key("schedule_${_getCurrentActor().schedules[i].hashCode}"),
                  index: i,
                  selectedActor: _getCurrentActor(),
                  timelineModel: widget.timelineModel,
                  scheduleModel: _getCurrentActor().schedules[i],
                  onUpdate: (scheduleModel) {
                    _onUpdate();
                  },
                );
              }
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 14.0, right: 14.0, bottom: 14.0),
            child: AddGenericWidget(
              text: "New Schedule",
              onTap: () {
                _addNewSchedule();
                _onUpdate();
              }
            ),
          )
        ],
      ),
    );
  }
}