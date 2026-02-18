import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';

class IdlePointWidget extends StatefulWidget {
  final TimepointModel timepointModel;
  final TimelineEditorSignal signals;

  const IdlePointWidget({super.key, required this.timepointModel, required this.signals});

  @override
  State<IdlePointWidget> createState() => _IdlePointWidgetState();
}

class _IdlePointWidgetState extends State<IdlePointWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}