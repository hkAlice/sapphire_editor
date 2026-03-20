// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trigger_action_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TriggerActionModel _$TriggerActionModelFromJson(Map<String, dynamic> json) =>
    TriggerActionModel(
      type: json['type'] as String,
      phaseId: (json['phaseId'] as num?)?.toInt(),
      timepoint: json['timepoint'] == null
          ? null
          : TimepointModel.fromJson(json['timepoint'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TriggerActionModelToJson(TriggerActionModel instance) =>
    <String, dynamic>{
      'type': instance.type,
      'phaseId': instance.phaseId,
      'timepoint': instance.timepoint?.toJson(),
    };
