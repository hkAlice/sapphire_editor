import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/phase_conditions_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_phase_model.dart';
import 'package:sapphire_editor/utils/text_utils.dart';
import 'package:sapphire_editor/widgets/switch_text_widget.dart';

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
      borderOnForeground: false,
      shadowColor: Colors.transparent,
      elevation: 1.0,
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ExpansionTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ReorderableDragStartListener(
              index: widget.index,
              child: Text(widget.index.toString().padLeft(2, "0"), style: Theme.of(context).textTheme.displaySmall!.apply(fontSizeFactor: 0.70, color: Theme.of(context).primaryColor),)
            ),
            SwitchTextWidget(
              enabled: widget.phaseConditionModel.enabled,
              onPressed: () {
                setState(() {
                  widget.phaseConditionModel.enabled = !widget.phaseConditionModel.enabled;
                });
                widget.onUpdate(widget.phaseConditionModel);
              },
            ),
            const VerticalDivider(),
          ],
        ),
        title: Text(widget.phaseConditionModel.readableConditionStr()),
        subtitle: widget.phaseConditionModel.description?.isNotEmpty ?? false ? Text(widget.phaseConditionModel.description!) : null,
        trailing: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            widget.timelineModel.phaseConditions.removeAt(widget.index);
            widget.onUpdate(widget.phaseConditionModel);
          },
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 250,
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
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
                    const SizedBox(width: 18.0,),
                    SizedBox(
                      width: 250,
                      child: DropdownButtonFormField<PhaseConditionType>(
                        decoration: const InputDecoration(
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
                    const SizedBox(width: 18.0,),
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
        ]
      ),
    );
  }
}