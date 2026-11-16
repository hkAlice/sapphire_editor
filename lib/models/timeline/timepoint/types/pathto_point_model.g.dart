// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pathto_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PathToPointModel _$PathToPointModelFromJson(Map<String, dynamic> json) =>
    PathToPointModel(
      pos: (json['pos'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [0.0, 0.0, 0.0],
      actorName: json['actorName'] as String? ?? "<unknown>",
      useNavi: json['useNavi'] as bool? ?? true,
    );

Map<String, dynamic> _$PathToPointModelToJson(PathToPointModel instance) =>
    <String, dynamic>{
      'pos': instance.pos,
      'actorName': instance.actorName,
      'useNavi': instance.useNavi,
    };
