// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setpos_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetPosPointModel _$SetPosPointModelFromJson(Map<String, dynamic> json) =>
    SetPosPointModel(
      pos: (json['pos'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [0.0, 0.0, 0.0],
      rot: (json['rot'] as num?)?.toDouble() ?? 0.0,
      actorName: json['actorName'] as String? ?? "<unknown>",
    );

Map<String, dynamic> _$SetPosPointModelToJson(SetPosPointModel instance) =>
    <String, dynamic>{
      'pos': instance.pos,
      'rot': instance.rot,
      'actorName': instance.actorName,
    };
