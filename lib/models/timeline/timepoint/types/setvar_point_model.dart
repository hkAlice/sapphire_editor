import 'package:json_annotation/json_annotation.dart';

part 'setvar_point_model.g.dart';

@JsonSerializable()
class SetVarPointModel {
  VarOpcode opc;
  VarType type;
  int idx;
  int val;

  SetVarPointModel({this.opc = VarOpcode.set, this.type = VarType.custom, this.idx = 0, this.val = 1});

  factory SetVarPointModel.fromJson(Map<String, dynamic> json) => _$SetVarPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$SetVarPointModelToJson(this);

  @override
  String toString() {
    var op = varOpcToString(opc);
    var typeStr = varTypeToString(type);

    return "Set ${typeStr}Var[0x${idx.toRadixString(16)}] $op $val";
  }
}

// assume immediate for all opcodes
enum VarOpcode {
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

enum VarType {
  @JsonValue("director")
  director,
  @JsonValue("custom")
  custom,
  @JsonValue("pack")
  pack
}

String varTypeToString(VarType varType) {
  var type = "";
  switch(varType) {
    case VarType.director:
      type = "Director";
    case VarType.custom:
      type = "Custom";
    case VarType.pack:
      type = "Pack";
    default:
      type = "unk";
  }
  return type;
}

String varOpcToString(VarOpcode opc) {
  var op = "";
  switch(opc) {
    case VarOpcode.set:
      op = "=";
    case VarOpcode.add:
      op = "+=";
    case VarOpcode.sub:
      op = "-=";
    case VarOpcode.mul:
      op = "*=";
    case VarOpcode.div:
      op = "/=";
    case VarOpcode.mod:
      op = "%=";
    case VarOpcode.or:
      op = "|=";
    case VarOpcode.xor:
      op = "^=";
    case VarOpcode.nor:
      op = "~=";
    case VarOpcode.and:
      op = "&=";
    case VarOpcode.sll:
      op = "<<";
    case VarOpcode.srl:
      op = ">>";
    default:
      op = "unk";
  }

  return op;
}