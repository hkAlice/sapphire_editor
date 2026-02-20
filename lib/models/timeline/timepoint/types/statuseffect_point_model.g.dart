// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statuseffect_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatusEffectPointModel _$StatusEffectPointModelFromJson(
        Map<String, dynamic> json) =>
    StatusEffectPointModel(
      targetType:
          $enumDecodeNullable(_$ActorTargetTypeEnumMap, json['targetType']) ??
              ActorTargetType.self,
      selectorName: json['selectorName'] as String? ?? "<unset>",
      selectorIndex: (json['selectorIndex'] as num?)?.toInt() ?? 0,
      sourceActor: json['sourceActor'] as String? ?? "<unknown>",
      statusId: (json['statusId'] as num?)?.toInt() ?? 0,
      isRemove: json['isRemove'] as bool? ?? false,
      duration: (json['duration'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$StatusEffectPointModelToJson(
        StatusEffectPointModel instance) =>
    <String, dynamic>{
      'targetType': _$ActorTargetTypeEnumMap[instance.targetType]!,
      'selectorName': instance.selectorName,
      'selectorIndex': instance.selectorIndex,
      'sourceActor': instance.sourceActor,
      'statusId': instance.statusId,
      'isRemove': instance.isRemove,
      'duration': instance.duration,
    };

const _$ActorTargetTypeEnumMap = {
  ActorTargetType.self: 'self',
  ActorTargetType.target: 'target',
  ActorTargetType.selectorPos: 'selectorPos',
  ActorTargetType.selectorTarget: 'selectorTarget',
  ActorTargetType.none: 'none',
};
