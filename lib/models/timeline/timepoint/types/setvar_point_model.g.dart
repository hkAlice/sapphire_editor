// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setvar_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetVarPointModel _$SetVarPointModelFromJson(Map<String, dynamic> json) =>
    SetVarPointModel(
      opc:
          $enumDecodeNullable(_$VarOpcodeEnumMap, json['opc']) ?? VarOpcode.set,
      type:
          $enumDecodeNullable(_$VarTypeEnumMap, json['type']) ?? VarType.custom,
      idx: (json['idx'] as num?)?.toInt() ?? 0,
      val: (json['val'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$SetVarPointModelToJson(SetVarPointModel instance) =>
    <String, dynamic>{
      'opc': _$VarOpcodeEnumMap[instance.opc]!,
      'type': _$VarTypeEnumMap[instance.type]!,
      'idx': instance.idx,
      'val': instance.val,
    };

const _$VarOpcodeEnumMap = {
  VarOpcode.set: 'set',
  VarOpcode.add: 'add',
  VarOpcode.sub: 'sub',
  VarOpcode.mul: 'mul',
  VarOpcode.div: 'div',
  VarOpcode.mod: 'mod',
  VarOpcode.or: 'or',
  VarOpcode.xor: 'xor',
  VarOpcode.nor: 'nor',
  VarOpcode.and: 'and',
  VarOpcode.sll: 'sll',
  VarOpcode.srl: 'srl',
};

const _$VarTypeEnumMap = {
  VarType.director: 'director',
  VarType.custom: 'custom',
  VarType.pack: 'pack',
};
