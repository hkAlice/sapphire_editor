// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'npcyell_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NpcYellPointModel _$NpcYellPointModelFromJson(Map<String, dynamic> json) =>
    NpcYellPointModel(
      talkerActorName: json['talkerActorName'] as String? ?? "<unknown>",
      npcYellId: (json['npcYellId'] as num?)?.toInt() ?? 0,
    )..params = (json['params'] as List<dynamic>?)
            ?.map((e) => (e as num).toInt())
            .toList() ??
        [0];

Map<String, dynamic> _$NpcYellPointModelToJson(NpcYellPointModel instance) =>
    <String, dynamic>{
      'talkerActorName': instance.talkerActorName,
      'npcYellId': instance.npcYellId,
      'params': instance.params,
    };
