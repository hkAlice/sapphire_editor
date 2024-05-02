// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_phase_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimelinePhaseModel _$TimelinePhaseModelFromJson(Map<String, dynamic> json) =>
    TimelinePhaseModel(
      name: json['name'] as String,
      id: (json['id'] as num).toInt(),
    )..timepoints = (json['timepoints'] as List<dynamic>)
        .map((e) => TimepointModel.fromJson(e as Map<String, dynamic>))
        .toList();

Map<String, dynamic> _$TimelinePhaseModelToJson(TimelinePhaseModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
      'timepoints': instance.timepoints,
    };
