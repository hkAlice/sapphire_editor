import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/bnpcflags_point_model.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/bnpcflags_toggle.dart';

class BNpcFlagsPointWidget extends StatefulWidget {
  final TimepointModel timepointModel;
  final Function() onUpdate;

  const BNpcFlagsPointWidget({super.key, required this.timepointModel, required this.onUpdate});

  @override
  State<BNpcFlagsPointWidget> createState() => _BNpcFlagsPointWidgetState();
}

class _BNpcFlagsPointWidgetState extends State<BNpcFlagsPointWidget> {
  late BNpcFlagsPointModel pointData = widget.timepointModel.data as BNpcFlagsPointModel;
  
  @override
  Widget build(BuildContext context) {
    return BNpcFlagsToggle(
      flags: pointData.flags,
      onUpdate: (newFlags) {
        pointData.flags = newFlags;
        setState(() {
          
        });
        widget.onUpdate();
      }
    );
  }
}