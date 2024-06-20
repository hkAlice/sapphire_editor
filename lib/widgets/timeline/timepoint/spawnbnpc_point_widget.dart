import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/spawnbnpc_point_model.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/bnpcflags_toggle.dart';

class SpawnBNpcPointWidget extends StatefulWidget {
  final TimelineModel timelineModel;
  final TimepointModel timepointModel;
  final Function() onUpdate;

  const SpawnBNpcPointWidget({super.key, required this.timelineModel, required this.timepointModel, required this.onUpdate});

  @override
  State<SpawnBNpcPointWidget> createState() => _SpawnBNpcPointWidgetState();
}

class _SpawnBNpcPointWidgetState extends State<SpawnBNpcPointWidget> {
  late SpawnBNpcPointModel pointData = widget.timepointModel.data as SpawnBNpcPointModel;
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 180,
                    child: GenericItemPickerWidget<ActorModel>(
                      label: "Actor",
                      items: widget.timelineModel.actors,
                      initialValue: widget.timelineModel.actors.firstWhereOrNull((e) => e.name == pointData.spawnActor),
                      onChanged: (newValue) {
                        pointData.spawnActor = newValue.name;
                        widget.onUpdate();
                        setState(() {
                          
                        });
                      },
                    ),
                  )
                ],
              )
            ],
          )
        ),
        BNpcFlagsToggle(
          flags: pointData.flags,
          isDense: true,
          onUpdate: (newFlags) {
            pointData.flags = newFlags;
            setState(() {
              
            });
            widget.onUpdate();
          }
        ),
      ],
    );
  }
}