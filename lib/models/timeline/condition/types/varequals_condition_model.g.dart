// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'varequals_condition_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VarEqualsConditionModel _$VarEqualsConditionModelFromJson(
        Map<String, dynamic> json) =>
    VarEqualsConditionModel(
      type: $enumDecodeNullable(_$VarTypeEnumMap, json['type']) ??
          VarType.director,
      index: (json['index'] as num?)?.toInt() ?? 0,
      val: (json['val'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$VarEqualsConditionModelToJson(
        VarEqualsConditionModel instance) =>
    <String, dynamic>{
      'type': _$VarTypeEnumMap[instance.type]!,
      'index': instance.index,
      'val': instance.val,
    };

const _$VarTypeEnumMap = {
  VarType.director: 'director',
  VarType.custom: 'custom',
  VarType.pack: 'pack',
};
