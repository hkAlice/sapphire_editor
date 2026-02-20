// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bnpcflags_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BNpcFlagsPointModel _$BNpcFlagsPointModelFromJson(Map<String, dynamic> json) =>
    BNpcFlagsPointModel(
      targetActor: json['targetActor'] as String? ?? "",
      flags: (json['flags'] as num?)?.toInt() ?? 0,
      flagsMask: (json['flagsMask'] as num?)?.toInt(),
      invulnType: (json['invulnType'] as num?)?.toInt(),
    );

Map<String, dynamic> _$BNpcFlagsPointModelToJson(
        BNpcFlagsPointModel instance) =>
    <String, dynamic>{
      'targetActor': instance.targetActor,
      'flags': instance.flags,
      'flagsMask': instance.flagsMask,
      'invulnType': instance.invulnType,
    };
