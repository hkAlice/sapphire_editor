import 'package:json_annotation/json_annotation.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';

part 'timeline_schedule_model.g.dart';

@JsonSerializable(explicitToJson: true)
class TimelineScheduleModel {
  final int id;
  String name;
  String description;

  List<TimepointModel> timepoints;

  @JsonKey(includeToJson: false, includeFromJson: false)
  int _nextTimepointId = 1;

  TimelineScheduleModel({
    required this.id,
    required this.name,
    this.description = "",
    List<TimepointModel>? timepointList,
  }) : timepoints = timepointList ?? [] {
    _recalculateNextId();
  }

  factory TimelineScheduleModel.fromJson(Map<String, dynamic> json) {
    final schedule = _$TimelineScheduleModelFromJson(json);
    
    // assign IDs to timepoints loaded with default value (-1)
    // this handles older timeline json without timeline id (version < 20)
    for(final timepoint in schedule.timepoints) {
      if(timepoint.id == -1) {
        timepoint.id = schedule.generateTimepointId();
      }
    }
    
    schedule._recalculateNextId();
    return schedule;
  }

  Map<String, dynamic> toJson() => _$TimelineScheduleModelToJson(this);

  void _recalculateNextId() {
    if(timepoints.isEmpty) {
      _nextTimepointId = 1;
    }
    else {
      _nextTimepointId =
          timepoints.map((t) => t.id).reduce((a, b) => a > b ? a : b) + 1;
    }
  }

  int generateTimepointId() => _nextTimepointId++;

  TimelineScheduleModel copyWith({
    int? id,
    String? name,
    String? description,
    List<TimepointModel>? timepoints,
  }) {
    final schedule = TimelineScheduleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      timepointList: timepoints ?? this.timepoints,
    );

    return schedule;
  }
}
