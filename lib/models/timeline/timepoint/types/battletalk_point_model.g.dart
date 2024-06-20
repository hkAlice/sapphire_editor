// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'battletalk_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BattleTalkPointModel _$BattleTalkPointModelFromJson(
        Map<String, dynamic> json) =>
    BattleTalkPointModel(
      handlerActorName: json['handlerActorName'] as String? ?? "<unknown>",
      talkerActorName: json['talkerActorName'] as String? ?? "<unknown>",
      kind: (json['kind'] as num?)?.toInt() ?? 0,
      nameId: (json['nameId'] as num?)?.toInt() ?? 2961,
      battleTalkId: (json['battleTalkId'] as num?)?.toInt() ?? 2939,
      params: (json['params'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [0],
    );

Map<String, dynamic> _$BattleTalkPointModelToJson(
        BattleTalkPointModel instance) =>
    <String, dynamic>{
      'handlerActorName': instance.handlerActorName,
      'talkerActorName': instance.talkerActorName,
      'kind': instance.kind,
      'nameId': instance.nameId,
      'battleTalkId': instance.battleTalkId,
      'params': instance.params,
    };
