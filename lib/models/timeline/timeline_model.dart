import 'package:json_annotation/json_annotation.dart';
import 'package:sapphire_editor/models/timeline/phase_conditions_model.dart';
import 'timeline_phase_model.dart';

part 'timeline_model.g.dart';

@JsonSerializable()
class TimelineModel {
  String name;

  List<PhaseConditionModel> phaseConditions;
  List<TimelinePhaseModel> phases;

  final int version;

  TimelineModel({
    required this.name,
    phaseList,
    conditionList,
    this.version = TimelineModel.VERSION_MODEL
  }) : phases = phaseList ?? [], phaseConditions = conditionList ?? [];

  static const VERSION_MODEL = 1;

  factory TimelineModel.fromJson(Map<String, dynamic> json) => _$TimelineModelFromJson(json);

  Map<String, dynamic> toJson() => _$TimelineModelToJson(this);
}