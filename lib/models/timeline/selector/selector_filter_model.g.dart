// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selector_filter_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SelectorFilterModel _$SelectorFilterModelFromJson(Map<String, dynamic> json) =>
    SelectorFilterModel(
      type: $enumDecodeNullable(_$SelectorFilterTypeEnumMap, json['type']) ??
          SelectorFilterType.player,
      param: json['param'],
    );

Map<String, dynamic> _$SelectorFilterModelToJson(
        SelectorFilterModel instance) =>
    <String, dynamic>{
      'type': _$SelectorFilterTypeEnumMap[instance.type]!,
      'param': instance.param,
    };

const _$SelectorFilterTypeEnumMap = {
  SelectorFilterType.insideRadius: 'insideRadius',
  SelectorFilterType.outsideRadius: 'outsideRadius',
  SelectorFilterType.player: 'player',
  SelectorFilterType.ally: 'ally',
  SelectorFilterType.ownBattalion: 'ownBattalion',
  SelectorFilterType.tank: 'tank',
  SelectorFilterType.healer: 'healer',
  SelectorFilterType.dps: 'dps',
  SelectorFilterType.rangedDps: 'rangedDps',
  SelectorFilterType.hasStatusEffect: 'hasStatusEffect',
  SelectorFilterType.topAggro: 'topAggro',
  SelectorFilterType.secondAggro: 'secondAggro',
  SelectorFilterType.allianceA: 'allianceA',
  SelectorFilterType.allianceB: 'allianceB',
  SelectorFilterType.allianceC: 'allianceC',
};
