import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';

class IdlePointWidget extends StatefulWidget {
  final TimepointModel timepointModel;

  const IdlePointWidget({super.key, required this.timepointModel});

  @override
  State<IdlePointWidget> createState() => _IdlePointWidgetState();
}

class _IdlePointWidgetState extends State<IdlePointWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}