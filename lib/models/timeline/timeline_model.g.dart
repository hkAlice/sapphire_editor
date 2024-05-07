// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimelineModel _$TimelineModelFromJson(Map<String, dynamic> json) =>
    TimelineModel(
      name: json['name'] as String,
    )
      ..actors = (json['actors'] as List<dynamic>)
          .map((e) => ActorModel.fromJson(e as Map<String, dynamic>))
          .toList()
      ..phaseConditions = (json['phaseConditions'] as List<dynamic>)
          .map((e) => PhaseConditionModel.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$TimelineModelToJson(TimelineModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'actors': instance.actors,
      'phaseConditions': instance.phaseConditions,
    };
