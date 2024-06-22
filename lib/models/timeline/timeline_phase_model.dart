import 'package:json_annotation/json_annotation.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';

part 'timeline_phase_model.g.dart';

@JsonSerializable()
class TimelinePhaseModel {
  final int id;
  String name;
  String description;

  List<TimepointModel> timepoints;

  TimelinePhaseModel({required this.id, required this.name, this.description = "", timepointList}) : timepoints = timepointList ?? [];

  factory TimelinePhaseModel.fromJson(Map<String, dynamic> json) => _$TimelinePhaseModelFromJson(json);

  Map<String, dynamic> toJson() => _$TimelinePhaseModelToJson(this);
}