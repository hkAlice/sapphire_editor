import 'package:json_annotation/json_annotation.dart';

part 'rngequals_condition_model.g.dart';

@JsonSerializable()
class RNGEqualsConditionModel {
  int val;

  RNGEqualsConditionModel({
    this.val = 0,
  });

  factory RNGEqualsConditionModel.fromJson(Map<String, dynamic> json) => _$RNGEqualsConditionModelFromJson(json);

  Map<String, dynamic> toJson() => _$RNGEqualsConditionModelToJson(this);
}