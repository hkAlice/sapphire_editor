// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'directorseq_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DirectorSeqPointModel _$DirectorSeqPointModelFromJson(
        Map<String, dynamic> json) =>
    DirectorSeqPointModel(
      opc: json['opc'] as String,
      val: (json['val'] as num).toInt(),
    );

Map<String, dynamic> _$DirectorSeqPointModelToJson(
        DirectorSeqPointModel instance) =>
    <String, dynamic>{
      'opc': instance.opc,
      'val': instance.val,
    };
