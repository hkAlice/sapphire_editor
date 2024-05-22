// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spawnbnpc_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpawnBNpcPointModel _$SpawnBNpcPointModelFromJson(Map<String, dynamic> json) =>
    SpawnBNpcPointModel(
      targetActor: json['targetActor'] as String,
      flags: (json['flags'] as num).toInt(),
      hateSource:
          HateSourceModel.fromJson(json['hateSource'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SpawnBNpcPointModelToJson(
        SpawnBNpcPointModel instance) =>
    <String, dynamic>{
      'targetActor': instance.targetActor,
      'flags': instance.flags,
      'hateSource': instance.hateSource,
    };

HateSourceModel _$HateSourceModelFromJson(Map<String, dynamic> json) =>
    HateSourceModel(
      hateType: json['hateType'] as String,
      source: json['source'] as String,
    );

Map<String, dynamic> _$HateSourceModelToJson(HateSourceModel instance) =>
    <String, dynamic>{
      'hateType': instance.hateType,
      'source': instance.source,
    };
