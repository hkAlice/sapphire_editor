import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/condition/phase_conditions_model.dart';

class PhaseConditionList extends StatefulWidget {
  final PhaseConditionModel phaseConditionsModel;
  const PhaseConditionList({super.key, required this.phaseConditionsModel});

  @override
  State<PhaseConditionList> createState() => _PhaseConditionListState();
}

class _PhaseConditionListState extends State<PhaseConditionList> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}