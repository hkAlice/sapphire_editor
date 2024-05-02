import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/phase_conditions_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_phase_model.dart';
import 'package:sapphire_editor/widgets/add_generic_widget.dart';
import 'package:sapphire_editor/widgets/small_heading_widget.dart';
import 'package:sapphire_editor/widgets/timeline/phase_condition/phase_condition_item.dart';
import 'package:sapphire_editor/widgets/timeline/timeline_phase_item.dart';

class TimelineList extends StatefulWidget {
  final TimelineModel timeline;
  final Function(TimelineModel) onUpdate;
  const TimelineList({super.key, required this.onUpdate, required this.timeline});

  @override
  State<TimelineList> createState() => _TimelineListState();
}

class _TimelineListState extends State<TimelineList> {
  late TextEditingController _nameTextEditingController;

  @override
  void initState() {
    _nameTextEditingController = TextEditingController(text: widget.timeline.name);

    super.initState();
  }

  void _addNewPhase() {
    widget.timeline.phases.add(TimelinePhaseModel(name: "Phase ${widget.timeline.phases.length}"));
    setState(() {
      
    });
    widget.onUpdate(widget.timeline);
    print("added");
  }

  void _addNewPhaseCondition() {
    widget.timeline.phaseConditions.add(PhaseConditionModel(
      condition: PhaseConditionType.hpPctLessThan,
      params: [50],
      phase: widget.timeline.phases.isEmpty ? "Undefined" : widget.timeline.phases.first.name,
      description: "",
      loop: false,
    ));

    setState(() {
      
    });

    widget.onUpdate(widget.timeline);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          maxLines: 1,
          controller: _nameTextEditingController,
          decoration: const InputDecoration(
    
            border: InputBorder.none,
          ),
          onChanged: (value) {
            widget.timeline.name = value;
            widget.onUpdate(widget.timeline);
          },
        ),
        const SmallHeadingWidget(title: "Conditions"),
        ReorderableListView.builder(
          buildDefaultDragHandles: false,
          onReorder: (int oldindex, int newindex) {
            setState(() {
              if(newindex > oldindex) {
                newindex -= 1;
              }
              final items = widget.timeline.phaseConditions.removeAt(oldindex);
              widget.timeline.phaseConditions.insert(newindex, items);
              widget.onUpdate(widget.timeline);
            });
          },
          itemCount: widget.timeline.phaseConditions.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, i) {
            return PhaseConditionItem(
              key: Key("condition_${widget.timeline.phaseConditions[i].hashCode}"),
              index: i,
              timelineModel: widget.timeline,
              phaseConditionModel: widget.timeline.phaseConditions[i],
              onUpdate: (phaseConditionModel) {
                widget.onUpdate(widget.timeline);
              },
            );
          }
        ),
        AddGenericWidget(text: "Add new condition", onTap: () { _addNewPhaseCondition(); }),
        const SmallHeadingWidget(title: "Phases"),
        ReorderableListView.builder(
          buildDefaultDragHandles: false,
          onReorder: (int oldindex, int newindex) {
            setState(() {
              if(newindex > oldindex) {
                newindex -= 1;
              }
              final items = widget.timeline.phases.removeAt(oldindex);
              widget.timeline.phases.insert(newindex, items);
              widget.onUpdate(widget.timeline);
            });
          },
          itemCount: widget.timeline.phases.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, i) {
            return TimelinePhaseItem(
              key: Key("phase_${widget.timeline.phases[i].hashCode}"),
              index: i,
              phaseModel: widget.timeline.phases[i],
              onUpdate: (phaseModel) {
                widget.onUpdate(widget.timeline);
              },
            );
          }
        ),
        AddGenericWidget(text: "Add new phase", onTap: () { _addNewPhase(); })
      ],
    );
  }
}