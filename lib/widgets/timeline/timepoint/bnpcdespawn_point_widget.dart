import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/bnpcdespawn_point_model.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';

class BNpcDespawnPointWidget extends StatefulWidget {
  final TimelineModel timelineModel;
  final TimepointModel timepointModel;
  final Function() onUpdate;

  const BNpcDespawnPointWidget({super.key, required this.timelineModel, required this.timepointModel, required this.onUpdate});

  @override
  State<BNpcDespawnPointWidget> createState() => _BNpcDespawnPointWidgetState();
}

class _BNpcDespawnPointWidgetState extends State<BNpcDespawnPointWidget> {
  late BNpcDespawnPointModel pointData = widget.timepointModel.data as BNpcDespawnPointModel;
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 180,
              child: GenericItemPickerWidget<ActorModel>(
                label: "Actor",
                items: widget.timelineModel.actors,
                initialValue: widget.timelineModel.actors.firstWhereOrNull((e) => e.name == pointData.despawnActor),
                onChanged: (newValue) {
                  pointData.despawnActor = newValue.name;
                  widget.onUpdate();
                  setState(() {
                    
                  });
                },
              ),
            )
          ],
        ),
      ],
    );
  }
}