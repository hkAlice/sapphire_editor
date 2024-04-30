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
    )..phases = (json['phases'] as List<dynamic>)
        .map((e) => TimelinePhaseModel.fromJson(e as Map<String, dynamic>))
        .toList();

Map<String, dynamic> _$TimelineModelToJson(TimelineModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'phases': instance.phases,
      'version': instance.version,
    };
