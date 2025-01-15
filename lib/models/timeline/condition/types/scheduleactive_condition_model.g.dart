// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scheduleactive_condition_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScheduleActiveConditionModel _$ScheduleActiveConditionModelFromJson(
        Map<String, dynamic> json) =>
    ScheduleActiveConditionModel(
      sourceActor: json['sourceActor'] as String? ?? "<unknown>",
      scheduleName: json['scheduleName'] as String? ?? "<unset>",
    );

Map<String, dynamic> _$ScheduleActiveConditionModelToJson(
        ScheduleActiveConditionModel instance) =>
    <String, dynamic>{
      'sourceActor': instance.sourceActor,
      'scheduleName': instance.scheduleName,
    };
