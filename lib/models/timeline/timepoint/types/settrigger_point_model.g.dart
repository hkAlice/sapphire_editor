// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settrigger_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetTriggerPointModel _$SetTriggerPointModelFromJson(
        Map<String, dynamic> json) =>
    SetTriggerPointModel(
      targetActor: json['targetActor'] as String? ?? "",
      targetPhaseId: (json['targetPhaseId'] as num?)?.toInt() ?? 0,
      triggerId: (json['triggerId'] as num?)?.toInt() ?? 1,
      enabled: json['enabled'] as bool? ?? true,
      triggerStr: json['triggerStr'] as String? ?? "<unknown>",
    );

Map<String, dynamic> _$SetTriggerPointModelToJson(
        SetTriggerPointModel instance) =>
    <String, dynamic>{
      'targetActor': instance.targetActor,
      'targetPhaseId': instance.targetPhaseId,
      'triggerId': instance.triggerId,
      'enabled': instance.enabled,
      'triggerStr': instance.triggerStr,
    };
