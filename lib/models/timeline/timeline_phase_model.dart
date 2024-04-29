import 'package:json_annotation/json_annotation.dart';
import 'package:sapphirexiv_timeline_editor/models/timeline/timepoint_model.dart';

part 'timeline_phase_model.g.dart';

@JsonSerializable()
class TimelinePhaseModel {
  final String name;

  List<TimepointModel> timepoints;

  TimelinePhaseModel({required this.name, timepointList}) : timepoints = timepointList ?? [];

  factory TimelinePhaseModel.fromJson(Map<String, dynamic> json) => _$TimelinePhaseModelFromJson(json);

  Map<String, dynamic> toJson() => _$TimelinePhaseModelToJson(this);
}