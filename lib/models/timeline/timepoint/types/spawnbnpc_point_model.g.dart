// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spawnbnpc_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpawnBNpcPointModel _$SpawnBNpcPointModelFromJson(Map<String, dynamic> json) =>
    SpawnBNpcPointModel(
      spawnActor: json['spawnActor'] as String? ?? "<unknown>",
      flags: (json['flags'] as num?)?.toInt() ?? 0,
      hateSource: json['hateSource'] == null
          ? null
          : HateSourceModel.fromJson(
              json['hateSource'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SpawnBNpcPointModelToJson(
        SpawnBNpcPointModel instance) =>
    <String, dynamic>{
      'spawnActor': instance.spawnActor,
      'flags': instance.flags,
      'hateSource': instance.hateSource,
    };

HateSourceModel _$HateSourceModelFromJson(Map<String, dynamic> json) =>
    HateSourceModel(
      hateType: json['hateType'] as String? ?? "<to-be-defined>",
      source: json['source'] as String? ?? "<to-de-befined>",
    );

Map<String, dynamic> _$HateSourceModelToJson(HateSourceModel instance) =>
    <String, dynamic>{
      'hateType': instance.hateType,
      'source': instance.source,
    };
