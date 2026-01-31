// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rollrng_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RollRNGPointModel _$RollRNGPointModelFromJson(Map<String, dynamic> json) =>
    RollRNGPointModel(
      min: (json['min'] as num?)?.toInt() ?? 0,
      max: (json['max'] as num?)?.toInt() ?? 2,
    );

Map<String, dynamic> _$RollRNGPointModelToJson(RollRNGPointModel instance) =>
    <String, dynamic>{
      'min': instance.min,
      'max': instance.max,
    };
