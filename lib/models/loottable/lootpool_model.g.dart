// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lootpool_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LootPoolModel _$LootPoolModelFromJson(Map<String, dynamic> json) =>
    LootPoolModel(
      name: json['name'] as String,
      pick: LootPickModel.fromJson(json['pick'] as Map<String, dynamic>),
      entries: (json['entries'] as List<dynamic>)
          .map((e) => LootEntryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LootPoolModelToJson(LootPoolModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'pick': instance.pick,
      'entries': instance.entries,
    };
