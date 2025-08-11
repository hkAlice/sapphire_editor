// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lootpool_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LootPoolModel _$LootPoolModelFromJson(Map<String, dynamic> json) =>
    LootPoolModel(
      name: json['name'] as String,
      pick: LootRangeModel.fromJson(json['pick'] as Map<String, dynamic>),
      items: (json['items'] as List<dynamic>)
          .map((e) => LootItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      enabled: json['enabled'] as bool,
      duplicates: json['duplicates'] as bool,
    );

Map<String, dynamic> _$LootPoolModelToJson(LootPoolModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'pick': instance.pick,
      'items': instance.items,
      'enabled': instance.enabled,
      'duplicates': instance.duplicates,
    };

LootItemModel _$LootItemModelFromJson(Map<String, dynamic> json) =>
    LootItemModel(
      id: (json['id'] as num).toInt(),
      weight: (json['weight'] as num).toInt(),
      isHq: json['isHq'] as bool,
      quantity:
          LootRangeModel.fromJson(json['quantity'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LootItemModelToJson(LootItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'weight': instance.weight,
      'isHq': instance.isHq,
      'quantity': instance.quantity,
    };

LootRangeModel _$LootRangeModelFromJson(Map<String, dynamic> json) =>
    LootRangeModel(
      min: (json['min'] as num).toInt(),
      max: (json['max'] as num).toInt(),
    );

Map<String, dynamic> _$LootRangeModelToJson(LootRangeModel instance) =>
    <String, dynamic>{
      'min': instance.min,
      'max': instance.max,
    };
