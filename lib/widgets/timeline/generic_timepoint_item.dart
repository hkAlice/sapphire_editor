import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sapphirexiv_timeline_editor/models/timeline/timepoint_model.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;
import 'package:sapphirexiv_timeline_editor/utils/text_utils.dart';

class GenericTimepointItem extends StatefulWidget {
  late TimepointModel timepointModel;
  final Function(TimepointModel) onUpdate;

  GenericTimepointItem({super.key, required this.timepointModel, required this.onUpdate});

  @override
  State<GenericTimepointItem> createState() => _GenericTimepointItemState();
}

class _GenericTimepointItemState extends State<GenericTimepointItem> {
  late TextEditingController _descriptionTextEditingController;

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
          left: BorderSide(color: getColorForTimepointType(widget.timepointModel.type), width: 5.0),
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
                Container(
                  width: 170,
                  child: DropdownButtonFormField<TimepointType>(
                    decoration: InputDecoration(
                      filled: true,
                      labelText: 'Point type',
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
                SizedBox(width: 18.0,),
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    controller: _descriptionTextEditingController,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: "Description (optional)",
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

Color getColorForTimepointType(TimepointType type) {
  switch(type) {
    case TimepointType.idle:
      return Colors.grey;
    case TimepointType.setDirectorVar:
      return Colors.redAccent;
    case TimepointType.castAction:
      return Colors.orangeAccent;
    case TimepointType.moveTo:
      return Colors.blueGrey;
    case TimepointType.setActorFlags:
      return Colors.deepPurpleAccent;
    default:
      return Colors.greenAccent;
  }
  
}