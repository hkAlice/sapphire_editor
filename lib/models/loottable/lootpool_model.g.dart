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
      items: (json['items'] as List<dynamic>)
          .map((e) => LootItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      enabled: json['enabled'] as bool,
      duplicates: json['duplicates'] as bool,
    );

Map<String, dynamic> _$LootPoolModelToJson(LootPoolModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'pickMin': instance.pickMin,
      'pickMax': instance.pickMax,
      'items': instance.items,
      'enabled': instance.enabled,
      'duplicates': instance.duplicates,
    };

LootItemModel _$LootItemModelFromJson(Map<String, dynamic> json) =>
    LootItemModel(
      id: (json['id'] as num).toInt(),
      weight: (json['weight'] as num).toInt(),
      isHq: json['isHq'] as bool,
    );

Map<String, dynamic> _$LootItemModelToJson(LootItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'weight': instance.weight,
      'isHq': instance.isHq,
    };
