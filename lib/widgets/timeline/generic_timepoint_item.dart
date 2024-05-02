import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/timepoint_model.dart';
import 'package:sapphire_editor/utils/text_utils.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/idle_point_widget.dart';

class GenericTimepointItem extends StatefulWidget {
  final TimepointModel timepointModel;
  final Function(TimepointModel) onUpdate;

  GenericTimepointItem({super.key, required this.timepointModel, required this.onUpdate});

  @override
  State<GenericTimepointItem> createState() => _GenericTimepointItemState();
}

class _GenericTimepointItemState extends State<GenericTimepointItem> {
  late TextEditingController _descriptionTextEditingController;

  Widget _generateTypedTimepoint() {
    switch(widget.timepointModel.type) {
      case TimepointType.idle:
        return IdlePointWidget();
      default:
        return Text("Unimplemented timepoint type ${widget.timepointModel.type}");
    }
  }

  @override
  void initState() {
    _descriptionTextEditingController = TextEditingController(text: widget.timepointModel.description);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: widget.timepointModel.getColorForTimepointType(), width: 5.0),
          top: BorderSide(color: Colors.grey.shade800, width: 1.0)
        )
      ),
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
                SizedBox(
                  width: 170,
                  child: DropdownButtonFormField<TimepointType>(
                    decoration: const InputDecoration(
                      filled: true,
                      labelText: "Point type",
                      border: null
                    ),
                    value: widget.timepointModel.type,
                    isDense: true,
                    onChanged: (TimepointType? value) {
                      if(value == null)
                        return;
                  
                      setState(() {
                        widget.timepointModel.type = value;
                      });
                      widget.onUpdate(widget.timepointModel);
                    },
                    items: TimepointType.values.map((TimepointType type) {
                      return DropdownMenuItem<TimepointType>(
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
                      widget.timepointModel.description = value;
                      widget.onUpdate(widget.timepointModel);
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