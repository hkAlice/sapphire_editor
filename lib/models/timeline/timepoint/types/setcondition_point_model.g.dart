// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setcondition_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetConditionPointModel _$SetConditionPointModelFromJson(
        Map<String, dynamic> json) =>
    SetConditionPointModel(
      conditionId: (json['conditionId'] as num?)?.toInt() ?? 1,
      enabled: json['enabled'] as bool? ?? true,
    );

Map<String, dynamic> _$SetConditionPointModelToJson(
        SetConditionPointModel instance) =>
    <String, dynamic>{
      'conditionId': instance.conditionId,
      'enabled': instance.enabled,
    };
