import 'package:json_annotation/json_annotation.dart';

part 'scheduleactive_condition_model.g.dart';

@JsonSerializable()
class ScheduleActiveConditionModel {
  String sourceActor;
  String scheduleName;

  ScheduleActiveConditionModel({
    this.sourceActor = "<unknown>",
    this.scheduleName = "<unset>"
  });

  factory ScheduleActiveConditionModel.fromJson(Map<String, dynamic> json) => _$ScheduleActiveConditionModelFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleActiveConditionModelToJson(this);
}