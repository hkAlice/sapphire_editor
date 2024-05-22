import 'package:json_annotation/json_annotation.dart';

part 'directorvar_point_model.g.dart';

@JsonSerializable()
class DirectorVarPointModel {
  String opc;
  
  int idx;
  int val;

  DirectorVarPointModel({required this.opc, required this.idx, required this.val});

  factory DirectorVarPointModel.fromJson(Map<String, dynamic> json) => _$DirectorVarPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$DirectorVarPointModelToJson(this);
}

// assume immediate for all opcodes
enum DirectorOpcode {
  set, // idx  = val
  add, // idx += val
  sub, // idx -= val
  mul, // idx *= val
  div, // idx /= val
  mod, // idx %= val
  sll, // idx << val
  srl, // idx >> val
  or,  // idx |= val
  xor, // idx ^= val
  nor, // idx ~= val
  and  // idx &= val
}