// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimelineModel _$TimelineModelFromJson(Map<String, dynamic> json) =>
    TimelineModel(
      name: json['name'] as String,
      version:
          (json['version'] as num?)?.toInt() ?? TimelineModel.VERSION_MODEL,
    )
      ..phaseConditions = (json['phaseConditions'] as List<dynamic>)
          .map((e) => PhaseConditionModel.fromJson(e as Map<String, dynamic>))
          .toList()
      ..phases = (json['phases'] as List<dynamic>)
          .map((e) => TimelinePhaseModel.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$TimelineModelToJson(TimelineModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'phaseConditions': instance.phaseConditions,
      'phases': instance.phases,
      'version': instance.version,
    };
