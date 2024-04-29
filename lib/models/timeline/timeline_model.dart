import 'package:json_annotation/json_annotation.dart';
import 'timeline_phase_model.dart';

part 'timeline_model.g.dart';

@JsonSerializable()
class TimelineModel {
  String name;

  List<TimelinePhaseModel> phases;

  TimelineModel({required this.name, phaseList}) : phases = phaseList ?? [];

  factory TimelineModel.fromJson(Map<String, dynamic> json) => _$TimelineModelFromJson(json);

  Map<String, dynamic> toJson() => _$TimelineModelToJson(this);
}