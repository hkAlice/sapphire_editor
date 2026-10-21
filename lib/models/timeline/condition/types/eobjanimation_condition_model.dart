import 'package:json_annotation/json_annotation.dart';

part 'eobjanimation_condition_model.g.dart';

@JsonSerializable()
class EObjAnimationConditionModel {
  String eobjName;
  int animation;

  EObjAnimationConditionModel({
    this.eobjName = "<unknown>",
    this.animation = 0
  });

  factory EObjAnimationConditionModel.fromJson(Map<String, dynamic> json) => _$EObjAnimationConditionModelFromJson(json);

  Map<String, dynamic> toJson() => _$EObjAnimationConditionModelToJson(this);
}