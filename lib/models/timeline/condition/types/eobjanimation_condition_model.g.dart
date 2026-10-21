// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eobjanimation_condition_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EObjAnimationConditionModel _$EObjAnimationConditionModelFromJson(
        Map<String, dynamic> json) =>
    EObjAnimationConditionModel(
      eobjName: json['eobjName'] as String? ?? "<unknown>",
      animation: (json['animation'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$EObjAnimationConditionModelToJson(
        EObjAnimationConditionModel instance) =>
    <String, dynamic>{
      'eobjName': instance.eobjName,
      'animation': instance.animation,
    };
