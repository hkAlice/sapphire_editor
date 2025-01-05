import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/battletalk_point_model.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';

class BattleTalkPointWidget extends StatefulWidget {
  final TimelineModel timelineModel;
  final TimepointModel timepointModel;
  final Function() onUpdate;

  const BattleTalkPointWidget({super.key, required this.timelineModel, required this.timepointModel, required this.onUpdate});

  @override
  State<BattleTalkPointWidget> createState() => _BattleTalkPointWidgetState();
}

class _BattleTalkPointWidgetState extends State<BattleTalkPointWidget> {
  late TextEditingController _paramsTextEditingController;

  late BattleTalkPointModel pointData = widget.timepointModel.data as BattleTalkPointModel;

  @override
  void initState() {
    _paramsTextEditingController = TextEditingController(text: pointData.params.join(", "));

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _generateStrSplitInput({required TextEditingController textEditingController, required String label, required Function(String) onChanged}) {
    return SizedBox(
      width: 306,
      child: TextFormField(
        maxLines: 1,
        controller: textEditingController,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          label: Text(label),
        ),
        onChanged: (value) { onChanged(value); }
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 180,
              child: GenericItemPickerWidget<ActorModel>(
                label: "Handler Actor",
                items: widget.timelineModel.actors,
                initialValue: widget.timelineModel.actors.firstWhereOrNull((e) => e.name == pointData.handlerActorName),
                onChanged: (newValue) {
                  pointData.handlerActorName = newValue.name;
                  widget.onUpdate();
                  setState(() {
                    
                  });
                },
              ),
            ),
            const SizedBox(width: 18.0,),
            SizedBox(
              width: 110,
              child: SimpleNumberField(
                label: "BattleTalk ID",
                initialValue: pointData.battleTalkId,
                onChanged: (value) {
                  pointData.battleTalkId = value;
                  widget.onUpdate();
                }
              ),
            ),
            const SizedBox(width: 18.0,),
            SizedBox(
              width: 80,
              child: SimpleNumberField(
                label: "Kind",
                initialValue: pointData.kind,
                onChanged: (value) {
                  pointData.kind = value;
                  widget.onUpdate();
                }
              ),
            ),
            const SizedBox(width: 18.0,),
            SizedBox(
              width: 80,
              child: SimpleNumberField(
                label: "Name ID",
                initialValue: pointData.nameId,
                onChanged: (value) {
                  pointData.nameId = value;
                  widget.onUpdate();
                }
              ),
            ),
          ],
        ),
        const SizedBox(height: 9.0,),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 180,
              child: GenericItemPickerWidget<ActorModel>(
                label: "Talker Actor",
                items: widget.timelineModel.actors,
                initialValue: widget.timelineModel.actors.firstWhereOrNull((e) => e.name == pointData.talkerActorName),
                onChanged: (newValue) {
                  pointData.talkerActorName = newValue.name;
                  widget.onUpdate();
                  setState(() {
                    
                  });
                },
              ),
            ),
            const SizedBox(width: 18.0,),
            _generateStrSplitInput(
              textEditingController: _paramsTextEditingController,
              label: "Params (split by ,)",
              onChanged: (value) {
                try {
                  var listParams = value.split(",").map((e) => int.parse(e)).toList();
                  pointData.params = listParams;
                  widget.onUpdate();
                }
                catch(_) { }
        
                setState(() {
                  
                });
              }
            ),
          ],
        ),
      ],
    );
  }
}