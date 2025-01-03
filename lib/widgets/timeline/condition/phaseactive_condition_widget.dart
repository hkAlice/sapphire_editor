import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/phaseactive_condition_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';

class PhaseActiveConditionWidget extends StatefulWidget {
  final TimelineModel timelineModel;
  final PhaseActiveConditionModel paramData;
  final Function(PhaseActiveConditionModel) onUpdate;
  
  const PhaseActiveConditionWidget({super.key, required this.timelineModel, required this.paramData, required this.onUpdate});

  @override
  State<PhaseActiveConditionWidget> createState() => _PhaseActiveConditionWidgetState();
}

class _PhaseActiveConditionWidgetState extends State<PhaseActiveConditionWidget> {
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
              
              if(_selectedActor!.phases.isEmpty) {
                widget.paramData.phaseName = "<unset>";
              }
              else {
                widget.paramData.phaseName = _selectedActor!.phases.first.name;
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
            label: "Phase",
            items: _selectedActor == null ? [] : _selectedActor!.phases.map((e) => e.name).toList(),
            initialValue: widget.paramData.phaseName,
            onChanged: (value) {
              setState(() {
                widget.paramData.phaseName = value;
              });
              widget.onUpdate(widget.paramData);
            },
          ),
        ),
      ],
    );
  }
}