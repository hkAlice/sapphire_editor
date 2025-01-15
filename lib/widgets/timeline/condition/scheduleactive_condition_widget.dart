import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/scheduleactive_condition_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';

class ScheduleActiveConditionWidget extends StatefulWidget {
  final TimelineModel timelineModel;
  final ScheduleActiveConditionModel paramData;
  final Function(ScheduleActiveConditionModel) onUpdate;
  
  const ScheduleActiveConditionWidget({super.key, required this.timelineModel, required this.paramData, required this.onUpdate});

  @override
  State<ScheduleActiveConditionWidget> createState() => _ScheduleActiveConditionWidgetState();
}

class _ScheduleActiveConditionWidgetState extends State<ScheduleActiveConditionWidget> {
  late ActorModel? _selectedActor;
  @override
  void initState() {
    _selectedActor = widget.timelineModel.actors.firstWhereOrNull((e) => e.name == widget.paramData.sourceActor);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 180,
          child: GenericItemPickerWidget<ActorModel>(
            label: "Source Actor",
            items: widget.timelineModel.actors,
            initialValue: widget.timelineModel.actors.firstWhereOrNull((e) => e.name == widget.paramData.sourceActor),
            onChanged: (newValue) {
              _selectedActor = newValue as ActorModel;
              
              widget.paramData.sourceActor = _selectedActor!.name;
              
              if(_selectedActor!.schedules.isEmpty) {
                widget.paramData.scheduleName = "<unset>";
              }
              else {
                widget.paramData.scheduleName = _selectedActor!.schedules.first.name;
              }
              
              setState(() {
                
              });
              
              widget.onUpdate(widget.paramData);
            },
          )
        ),
        const SizedBox(width: 18.0,),
        SizedBox(
          width: 240,
          child: GenericItemPickerWidget<String>(
            label: "Schedule",
            items: _selectedActor == null ? [] : _selectedActor!.schedules.map((e) => e.name).toList(),
            initialValue: widget.paramData.scheduleName,
            onChanged: (value) {
              setState(() {
                widget.paramData.scheduleName = value;
              });
              widget.onUpdate(widget.paramData);
            },
          ),
        ),
      ],
    );
  }
}