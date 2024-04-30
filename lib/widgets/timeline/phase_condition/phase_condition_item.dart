import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/phase_conditions_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_phase_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint_model.dart';
import 'package:sapphire_editor/utils/text_utils.dart';
import 'package:sapphire_editor/widgets/add_generic_widget.dart';
import 'package:sapphire_editor/widgets/timeline/generic_timepoint_item.dart';

class PhaseConditionItem extends StatefulWidget {
  final TimelineModel timelineModel;
  final PhaseConditionModel phaseConditionModel;
  final int index;
  final Function(PhaseConditionModel) onUpdate;

  const PhaseConditionItem({super.key, required this.timelineModel, required this.phaseConditionModel, required this.index, required this.onUpdate});

  @override
  State<PhaseConditionItem> createState() => _PhaseConditionItemState();
}

class _PhaseConditionItemState extends State<PhaseConditionItem> {
  late TextEditingController _descriptionTextEditingController;

  @override
  void initState() {
    _descriptionTextEditingController = TextEditingController(text: widget.phaseConditionModel.description);
      
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReorderableDragStartListener(
                  index: widget.index,
                  child: Text(widget.index.toString().padLeft(2, "0"), style: Theme.of(context).textTheme.displaySmall!.apply(fontSizeFactor: 0.75, color: Theme.of(context).primaryColor),)
                ),
                SizedBox(width: 18.0,),
                Container(
                  width: 250,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      labelText: "Phase",
                      border: null
                    ),
                    value: widget.phaseConditionModel.phase,
                    isDense: true,
                    onChanged: (String? value) {
                      if(value == null)
                        return;
                  
                      setState(() {
                        widget.phaseConditionModel.phase = value;
                      });
                      widget.onUpdate(widget.phaseConditionModel);
                    },
                    items: widget.timelineModel.phases.map((TimelinePhaseModel phase) {
                      print(phase.name);
                      return DropdownMenuItem<String>(
                        value: phase.name,
                        child: Text(phase.name));
                    }).toList()
                  ),
                ),
                SizedBox(width: 18.0,),
                Container(
                  width: 250,
                  child: DropdownButtonFormField<PhaseConditionType>(
                    decoration: InputDecoration(
                      filled: true,
                      labelText: "Condition",
                      border: null
                    ),
                    value: widget.phaseConditionModel.condition,
                    isDense: true,
                    onChanged: (PhaseConditionType? value) {
                      if(value == null)
                        return;
                  
                      setState(() {
                        widget.phaseConditionModel.condition = value;
                      });
                      widget.onUpdate(widget.phaseConditionModel);
                    },
                    items: PhaseConditionType.values.map((PhaseConditionType type) {
                      return DropdownMenuItem<PhaseConditionType>(
                        value: type,
                        child: Text(treatEnumName(type)));
                    }).toList()
                  ),
                ),
                SizedBox(width: 18.0,),
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    controller: _descriptionTextEditingController,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      hintText: "Description (optional)",
                    ),
                    
                    onChanged: (value) {
                      widget.phaseConditionModel.description = value;
                      widget.onUpdate(widget.phaseConditionModel);
                    },
                  ),
                )
              ],
            ),
            
          ],
        ),
      ),
    );
  }
}