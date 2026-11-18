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
      serverPathId: (json['serverPathId'] as num?)?.toInt() ?? 0,
      pathType: $enumDecodeNullable(_$PathToTypeEnumMap, json['pathType']) ??
          PathToType.none,
      targetActor: json['targetActor'] as String? ?? "<unknown>",
      selectorName: json['selectorName'] as String? ?? "",
      selectorIndex: (json['selectorIndex'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$PathToPointModelToJson(PathToPointModel instance) =>
    <String, dynamic>{
      'pos': instance.pos,
      'actorName': instance.actorName,
      'useNavi': instance.useNavi,
      'pathType': _$PathToTypeEnumMap[instance.pathType]!,
      'targetActor': instance.targetActor,
      'serverPathId': instance.serverPathId,
      'selectorName': instance.selectorName,
      'selectorIndex': instance.selectorIndex,
    };

const _$PathToTypeEnumMap = {
  PathToType.target: 'target',
  PathToType.selectorPos: 'selectorPos',
  PathToType.selectorTarget: 'selectorTarget',
  PathToType.fixedPos: 'fixedPos',
  PathToType.serverPath: 'serverPath',
  PathToType.timelineActor: 'timelineActor',
  PathToType.none: 'none',
};
