// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'directorseq_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DirectorSeqPointModel _$DirectorSeqPointModelFromJson(
        Map<String, dynamic> json) =>
    DirectorSeqPointModel(
      opc: $enumDecodeNullable(_$DirectorOpcodeEnumMap, json['opc']) ??
          DirectorOpcode.set,
      val: (json['val'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$DirectorSeqPointModelToJson(
        DirectorSeqPointModel instance) =>
    <String, dynamic>{
      'opc': _$DirectorOpcodeEnumMap[instance.opc]!,
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
