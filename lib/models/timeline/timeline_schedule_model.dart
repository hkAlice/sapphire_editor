import 'package:json_annotation/json_annotation.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';

part 'timeline_schedule_model.g.dart';

@JsonSerializable()
class TimelineScheduleModel {
  final int id;
  String name;
  String description;

  List<TimepointModel> timepoints;

  TimelineScheduleModel({required this.id, required this.name, this.description = "", timepointList}) : timepoints = timepointList ?? [];

  factory TimelineScheduleModel.fromJson(Map<String, dynamic> json) => _$TimelineScheduleModelFromJson(json);

  Map<String, dynamic> toJson() => _$TimelineScheduleModelToJson(this);

  TimelineScheduleModel copyWith({
    int? id,
    String? name,
    String? description,
    List<TimepointModel>? timepoints,
  }) {
    return TimelineScheduleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      timepointList: timepoints ?? this.timepoints,
    );
  }
}