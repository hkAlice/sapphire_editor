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
      targetActor: json['targetActor'] as String? ?? "<unknown>",
      targetType:
          $enumDecodeNullable(_$ActorTargetTypeEnumMap, json['targetType']) ??
              ActorTargetType.self,
      selectorName: json['selectorName'] as String? ?? "<unset>",
      selectorIndex: (json['selectorIndex'] as num?)?.toInt() ?? 0,
      positionType:
          $enumDecodeNullable(_$PositionTypeEnumMap, json['positionType']) ??
              PositionType.absolute,
    );

Map<String, dynamic> _$SetPosPointModelToJson(SetPosPointModel instance) =>
    <String, dynamic>{
      'pos': instance.pos,
      'rot': instance.rot,
      'actorName': instance.actorName,
      'targetActor': instance.targetActor,
      'targetType': _$ActorTargetTypeEnumMap[instance.targetType]!,
      'selectorName': instance.selectorName,
      'selectorIndex': instance.selectorIndex,
      'positionType': _$PositionTypeEnumMap[instance.positionType]!,
    };

const _$ActorTargetTypeEnumMap = {
  ActorTargetType.self: 'self',
  ActorTargetType.target: 'target',
  ActorTargetType.selector: 'selector',
  ActorTargetType.none: 'none',
};

const _$PositionTypeEnumMap = {
  PositionType.absolute: 'absolute',
  PositionType.relative: 'relative',
};
