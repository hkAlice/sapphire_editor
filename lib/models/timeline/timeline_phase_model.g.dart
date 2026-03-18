// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_phase_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimelinePhaseModel _$TimelinePhaseModelFromJson(Map<String, dynamic> json) =>
    TimelinePhaseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      onEnter: (json['onEnter'] as List<dynamic>?)
          ?.map((e) => TimepointModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      schedules: (json['schedules'] as List<dynamic>?)
          ?.map(
              (e) => TimelineScheduleModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      triggers: (json['triggers'] as List<dynamic>?)
          ?.map((e) => TriggerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TimelinePhaseModelToJson(TimelinePhaseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'onEnter': instance.onEnter.map((e) => e.toJson()).toList(),
      'schedules': instance.schedules.map((e) => e.toJson()).toList(),
      'triggers': instance.triggers.map((e) => e.toJson()).toList(),
    };
