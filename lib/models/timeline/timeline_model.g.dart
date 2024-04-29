// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimelineModel _$TimelineModelFromJson(Map<String, dynamic> json) =>
    TimelineModel(
      name: json['name'] as String,
    )..phases = (json['phases'] as List<dynamic>)
        .map((e) => TimelinePhaseModel.fromJson(e as Map<String, dynamic>))
        .toList();

Map<String, dynamic> _$TimelineModelToJson(TimelineModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'phases': instance.phases,
    };
