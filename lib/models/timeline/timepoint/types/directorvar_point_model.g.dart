// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'directorvar_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DirectorVarPointModel _$DirectorVarPointModelFromJson(
        Map<String, dynamic> json) =>
    DirectorVarPointModel(
      opc: json['opc'] as String,
      idx: (json['idx'] as num).toInt(),
      val: (json['val'] as num).toInt(),
    );

Map<String, dynamic> _$DirectorVarPointModelToJson(
        DirectorVarPointModel instance) =>
    <String, dynamic>{
      'opc': instance.opc,
      'idx': instance.idx,
      'val': instance.val,
    };
