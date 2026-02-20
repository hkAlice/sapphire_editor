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

  @override
  String toString() {
    var op = directorOpcToString(opc);

    return "DirectorVar[0x${idx.toRadixString(16)}] $op $val";
  }
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

String directorOpcToString(DirectorOpcode opc) {
  var op = "";
  switch(opc) {
    case DirectorOpcode.set:
      op = "=";
    case DirectorOpcode.add:
      op = "+=";
    case DirectorOpcode.sub:
      op = "-=";
    case DirectorOpcode.mul:
      op = "*=";
    case DirectorOpcode.div:
      op = "/=";
    case DirectorOpcode.mod:
      op = "%=";
    case DirectorOpcode.or:
      op = "|=";
    case DirectorOpcode.xor:
      op = "^=";
    case DirectorOpcode.nor:
      op = "~=";
    case DirectorOpcode.and:
      op = "&=";
    case DirectorOpcode.sll:
      op = "<<";
    case DirectorOpcode.srl:
      op = ">>";
  }

  return op;
}