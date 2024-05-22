// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'directorflags_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DirectorFlagsPointModel _$DirectorFlagsPointModelFromJson(
        Map<String, dynamic> json) =>
    DirectorFlagsPointModel(
      opc: json['opc'] as String,
      val: (json['val'] as num).toInt(),
    );

Map<String, dynamic> _$DirectorFlagsPointModelToJson(
        DirectorFlagsPointModel instance) =>
    <String, dynamic>{
      'opc': instance.opc,
      'val': instance.val,
    };
