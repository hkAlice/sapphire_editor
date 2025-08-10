// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lootpool_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LootPoolModel _$LootPoolModelFromJson(Map<String, dynamic> json) =>
    LootPoolModel(
      name: json['name'] as String,
      pickMin: (json['pickMin'] as num).toInt(),
      pickMax: (json['pickMax'] as num).toInt(),
      entries: (json['entries'] as List<dynamic>)
          .map((e) => LootEntryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      enabled: json['enabled'] as bool,
      duplicates: json['duplicates'] as bool,
    );

Map<String, dynamic> _$LootPoolModelToJson(LootPoolModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'pickMin': instance.pickMin,
      'pickMax': instance.pickMax,
      'entries': instance.entries,
      'enabled': instance.enabled,
      'duplicates': instance.duplicates,
    };

LootEntryModel _$LootEntryModelFromJson(Map<String, dynamic> json) =>
    LootEntryModel(
      item: (json['item'] as num).toInt(),
      weight: (json['weight'] as num).toInt(),
    );

Map<String, dynamic> _$LootEntryModelToJson(LootEntryModel instance) =>
    <String, dynamic>{
      'item': instance.item,
      'weight': instance.weight,
    };
