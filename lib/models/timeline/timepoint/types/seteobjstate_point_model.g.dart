// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seteobjstate_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetEObjStatePointModel _$SetEObjStatePointModelFromJson(
        Map<String, dynamic> json) =>
    SetEObjStatePointModel(
      eobjName: json['eobjName'] as String? ?? "",
      state: (json['state'] as num?)?.toInt() ?? 0,
      animation: (json['animation'] as num?)?.toInt() ?? 0,
      permissionInvisibility:
          (json['permissionInvisibility'] as num?)?.toInt() ?? 0,
      collision: json['collision'] as bool? ?? false,
    );

Map<String, dynamic> _$SetEObjStatePointModelToJson(
        SetEObjStatePointModel instance) =>
    <String, dynamic>{
      'eobjName': instance.eobjName,
      'state': instance.state,
      'animation': instance.animation,
      'permissionInvisibility': instance.permissionInvisibility,
      'collision': instance.collision,
    };
