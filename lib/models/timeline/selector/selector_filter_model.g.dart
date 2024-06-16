// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selector_filter_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SelectorFilterModel _$SelectorFilterModelFromJson(Map<String, dynamic> json) =>
    SelectorFilterModel(
      type: $enumDecodeNullable(_$SelectorFilterTypeEnumMap, json['type']) ??
          SelectorFilterType.player,
      data: json['data'],
    );

Map<String, dynamic> _$SelectorFilterModelToJson(
        SelectorFilterModel instance) =>
    <String, dynamic>{
      'type': _$SelectorFilterTypeEnumMap[instance.type]!,
      'data': instance.data,
    };

const _$SelectorFilterTypeEnumMap = {
  SelectorFilterType.player: 'Player',
  SelectorFilterType.furthest: 'Furthest',
  SelectorFilterType.role: 'Role',
  SelectorFilterType.notAggro: 'NotAggro',
};
