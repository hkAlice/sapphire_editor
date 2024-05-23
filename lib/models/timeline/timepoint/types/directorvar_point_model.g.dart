// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'directorvar_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DirectorVarPointModel _$DirectorVarPointModelFromJson(
        Map<String, dynamic> json) =>
    DirectorVarPointModel(
      opc: $enumDecodeNullable(_$DirectorOpcodeEnumMap, json['opc']) ??
          DirectorOpcode.set,
      idx: (json['idx'] as num?)?.toInt() ?? 0,
      val: (json['val'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$DirectorVarPointModelToJson(
        DirectorVarPointModel instance) =>
    <String, dynamic>{
      'opc': _$DirectorOpcodeEnumMap[instance.opc]!,
      'idx': instance.idx,
      'val': instance.val,
    };

const _$DirectorOpcodeEnumMap = {
  DirectorOpcode.set: 'set',
  DirectorOpcode.add: 'add',
  DirectorOpcode.sub: 'sub',
  DirectorOpcode.mul: 'mul',
  DirectorOpcode.div: 'div',
  DirectorOpcode.mod: 'mod',
  DirectorOpcode.or: 'or',
  DirectorOpcode.xor: 'xor',
  DirectorOpcode.nor: 'nor',
  DirectorOpcode.and: 'and',
  DirectorOpcode.sll: 'sll',
  DirectorOpcode.srl: 'srl',
};
