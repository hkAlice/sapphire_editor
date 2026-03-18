import 'package:json_annotation/json_annotation.dart';
import 'package:sapphire_editor/models/timeline/condition/trigger_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_schedule_model.dart';

part 'timeline_phase_model.g.dart';

@JsonSerializable(explicitToJson: true)
class TimelinePhaseModel {
  String id;
  String name;

  List<TimepointModel> onEnter;
  List<TimelineScheduleModel> schedules;
  List<TriggerModel> triggers;

  TimelinePhaseModel({
    required this.id,
    required this.name,
    List<TimepointModel>? onEnter,
    List<TimelineScheduleModel>? schedules,
    List<TriggerModel>? triggers,
  })  : onEnter = onEnter ?? [],
        schedules = schedules ?? [],
        triggers = triggers ?? [];

  factory TimelinePhaseModel.fromJson(Map<String, dynamic> json) =>
      _$TimelinePhaseModelFromJson(json);

  Map<String, dynamic> toJson() => _$TimelinePhaseModelToJson(this);

  TimelinePhaseModel copyWith({
    String? id,
    String? name,
    List<TimepointModel>? onEnter,
    List<TimelineScheduleModel>? schedules,
    List<TriggerModel>? triggers,
  }) {
    return TimelinePhaseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      onEnter: onEnter ?? this.onEnter,
      schedules: schedules ?? this.schedules,
      triggers: triggers ?? this.triggers,
    );
  }
}
