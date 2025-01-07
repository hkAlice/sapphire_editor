// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'battletalk_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BattleTalkPointModel _$BattleTalkPointModelFromJson(
        Map<String, dynamic> json) =>
    BattleTalkPointModel(
      talkerActorName: json['talkerActorName'] as String? ?? "<unknown>",
      kind: (json['kind'] as num?)?.toInt() ?? 0,
      nameId: (json['nameId'] as num?)?.toInt() ?? 2961,
      battleTalkId: (json['battleTalkId'] as num?)?.toInt() ?? 2939,
      params: (json['params'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [0],
      length: (json['duration'] as num?)?.toInt() ?? 5000,
    );

Map<String, dynamic> _$BattleTalkPointModelToJson(
        BattleTalkPointModel instance) =>
    <String, dynamic>{
      'talkerActorName': instance.talkerActorName,
      'kind': instance.kind,
      'nameId': instance.nameId,
      'battleTalkId': instance.battleTalkId,
      'duration': instance.length,
      'params': instance.params,
    };
