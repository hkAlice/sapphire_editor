import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_phase_model.dart';
import 'package:sapphire_editor/widgets/add_generic_widget.dart';
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

  void _addNewState() {
    widget.timeline.phases.add(TimelinePhaseModel(name: "Phase ${widget.timeline.phases.length}"));
    setState(() {
      
    });
    widget.onUpdate(widget.timeline);
    print("added");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
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
                key: Key("phase_$i"),
                index: i,
                phaseModel: widget.timeline.phases[i],
                onUpdate: (phaseModel) {
                  widget.onUpdate(widget.timeline);
                },
              );
            }
          ),
          AddGenericWidget(text: "Add new phase", onTap: () { _addNewState(); })
        ],
      ),
    );
  }
}