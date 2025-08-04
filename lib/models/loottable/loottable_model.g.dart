// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loottable_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LootTableModel _$LootTableModelFromJson(Map<String, dynamic> json) =>
    LootTableModel(
      lootTable: json['lootTable'] as String,
      type: json['type'] as String,
      pools: (json['pools'] as List<dynamic>)
          .map((e) => LootPoolModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LootTableModelToJson(LootTableModel instance) =>
    <String, dynamic>{
      'lootTable': instance.lootTable,
      'type': instance.type,
      'pools': instance.pools,
    };
