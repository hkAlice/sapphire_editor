import 'package:json_annotation/json_annotation.dart';

part 'varequals_condition_model.g.dart';

@JsonSerializable()
class VarEqualsConditionModel {
  VarType type;
  int index;
  int val;

  VarEqualsConditionModel({
    this.type = VarType.director,
    this.index = 0,
    this.val = 0,
  });

  factory VarEqualsConditionModel.fromJson(Map<String, dynamic> json) => _$VarEqualsConditionModelFromJson(json);

  Map<String, dynamic> toJson() => _$VarEqualsConditionModelToJson(this);
}

enum VarType {
  @JsonValue("director")
  director,
  @JsonValue("custom")
  custom,
  @JsonValue("pack")
  pack
}