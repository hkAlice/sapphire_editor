// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mechanic_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MechanicPointModel _$MechanicPointModelFromJson(Map<String, dynamic> json) =>
    MechanicPointModel(
      instance: json['instance'] as String? ?? "",
      function: json['function'] as String? ?? "",
    )..args = json['args'] as Map<String, dynamic>?;

Map<String, dynamic> _$MechanicPointModelToJson(MechanicPointModel instance) =>
    <String, dynamic>{
      'instance': instance.instance,
      'function': instance.function,
      'args': instance.args,
    };
