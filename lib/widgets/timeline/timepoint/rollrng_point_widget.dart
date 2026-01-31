import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/rollrng_point_model.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';

class RollRNGPointWidget extends StatefulWidget {
  final TimelineModel timelineModel;
  final TimepointModel timepointModel;
  final ActorModel selectedActor;
  final Function() onUpdate;

  const RollRNGPointWidget({
    super.key,
    required this.timelineModel,
    required this.timepointModel,
    required this.onUpdate,
    required this.selectedActor
  });

  @override
  State<RollRNGPointWidget> createState() => _RollRNGPointWidgetState();
}

class _RollRNGPointWidgetState extends State<RollRNGPointWidget> {
  late RollRNGPointModel pointData = widget.timepointModel.data as RollRNGPointModel;
  
  @override
  Widget build(BuildContext context) {

    return Row(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 180,
              child: SimpleNumberField(
                label: "Min",
                initialValue: pointData.min,
                onChanged: (value) {
                  pointData.min = value;
                  widget.onUpdate();
                }
              ),
            ),
            const SizedBox(width: 18.0,),
            SizedBox(
              width: 180,
              child: SimpleNumberField(
                label: "Max",
                initialValue: pointData.max,
                onChanged: (value) {
                  pointData.max = value;
                  widget.onUpdate();
                }
              ),
            ),
          ],
        ),
      ],
    );
  }
}