// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'castaction_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CastActionPointModel _$CastActionPointModelFromJson(
        Map<String, dynamic> json) =>
    CastActionPointModel(
      sourceActor: json['sourceActor'] as String? ?? "<unknown>",
      actionId: (json['actionId'] as num?)?.toInt() ?? 6116,
      targetType:
          $enumDecodeNullable(_$ActorTargetTypeEnumMap, json['targetType']) ??
              ActorTargetType.self,
      selectorName: json['selectorName'] as String? ?? "<unset>",
      selectorIndex: (json['selectorIndex'] as num?)?.toInt() ?? 0,
      snapshot: json['snapshot'] as bool? ?? false,
      snapshotTime: (json['snapshotTime'] as num?)?.toInt() ?? 0,
      targetActor: json['targetActor'] as String? ?? "<unknown>",
    )..pos = (json['pos'] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        [0.0, 0.0, 0.0];

Map<String, dynamic> _$CastActionPointModelToJson(
        CastActionPointModel instance) =>
    <String, dynamic>{
      'sourceActor': instance.sourceActor,
      'actionId': instance.actionId,
      'targetType': _$ActorTargetTypeEnumMap[instance.targetType]!,
      'selectorName': instance.selectorName,
      'selectorIndex': instance.selectorIndex,
      'snapshot': instance.snapshot,
      'snapshotTime': instance.snapshotTime,
      'targetActor': instance.targetActor,
      'pos': instance.pos,
    };

const _$ActorTargetTypeEnumMap = {
  ActorTargetType.self: 'self',
  ActorTargetType.target: 'target',
  ActorTargetType.selectorPos: 'selectorPos',
  ActorTargetType.selectorTarget: 'selectorTarget',
  ActorTargetType.fixedPos: 'fixedPos',
  ActorTargetType.timelineActor: 'timelineActor',
  ActorTargetType.none: 'none',
};
