// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settrigger_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetTriggerPointModel _$SetTriggerPointModelFromJson(
        Map<String, dynamic> json) =>
    SetTriggerPointModel(
      conditionId: (json['conditionId'] as num?)?.toInt() ?? 1,
      enabled: json['enabled'] as bool? ?? true,
      conditionStr: json['conditionStr'] as String? ?? "<unknown>",
    );

Map<String, dynamic> _$SetTriggerPointModelToJson(
        SetTriggerPointModel instance) =>
    <String, dynamic>{
      'conditionId': instance.conditionId,
      'conditionStr': instance.conditionStr,
      'enabled': instance.enabled,
    };
