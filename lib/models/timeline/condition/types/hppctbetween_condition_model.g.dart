// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hppctbetween_condition_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HPPctBetweenConditionModel _$HPPctBetweenConditionModelFromJson(
        Map<String, dynamic> json) =>
    HPPctBetweenConditionModel(
      sourceActor: json['sourceActor'] as String? ?? "<unknown>",
      hpMin: (json['hpMin'] as num?)?.toInt() ?? 25,
      hpMax: (json['hpMax'] as num?)?.toInt() ?? 50,
    );

Map<String, dynamic> _$HPPctBetweenConditionModelToJson(
        HPPctBetweenConditionModel instance) =>
    <String, dynamic>{
      'sourceActor': instance.sourceActor,
      'hpMin': instance.hpMin,
      'hpMax': instance.hpMax,
    };
