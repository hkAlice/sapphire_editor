// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'battletalk_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BattleTalkPointModel _$BattleTalkPointModelFromJson(
        Map<String, dynamic> json) =>
    BattleTalkPointModel(
      handlerId: (json['handlerId'] as num?)?.toInt() ?? 0,
      talkerId: (json['talkerId'] as num?)?.toInt() ?? 0,
      kind: (json['kind'] as num?)?.toInt() ?? 0,
      nameId: (json['nameId'] as num?)?.toInt() ?? 1,
      battleTalkId: (json['battleTalkId'] as num?)?.toInt() ?? 2939,
      params: (json['params'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [0],
    );

Map<String, dynamic> _$BattleTalkPointModelToJson(
        BattleTalkPointModel instance) =>
    <String, dynamic>{
      'handlerId': instance.handlerId,
      'talkerId': instance.talkerId,
      'kind': instance.kind,
      'nameId': instance.nameId,
      'battleTalkId': instance.battleTalkId,
      'params': instance.params,
    };
