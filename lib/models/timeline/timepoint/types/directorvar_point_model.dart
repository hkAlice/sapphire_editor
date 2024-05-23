import 'package:json_annotation/json_annotation.dart';

part 'directorvar_point_model.g.dart';

@JsonSerializable()
class DirectorVarPointModel {
  DirectorOpcode opc;
  
  int idx;
  int val;

  DirectorVarPointModel({this.opc = DirectorOpcode.set, this.idx = 0, this.val = 1});

  factory DirectorVarPointModel.fromJson(Map<String, dynamic> json) => _$DirectorVarPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$DirectorVarPointModelToJson(this);
}

// assume immediate for all opcodes
enum DirectorOpcode {
  @JsonValue("set")
  set, // idx  = val
  @JsonValue("add")
  add, // idx += val
  @JsonValue("sub")
  sub, // idx -= val
  @JsonValue("mul")
  mul, // idx *= val
  @JsonValue("div")
  div, // idx /= val
  @JsonValue("mod")
  mod, // idx %= val
  @JsonValue("or")
  or,  // idx |= val
  @JsonValue("xor")
  xor, // idx ^= val
  @JsonValue("nor")
  nor, // idx ~= val
  @JsonValue("and")
  and,  // idx &= val
  @JsonValue("sll")
  sll, // idx << val
  @JsonValue("srl")
  srl // idx >> val
}