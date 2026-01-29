import 'package:json_annotation/json_annotation.dart';

part 'interruptedaction_condition_model.g.dart';

@JsonSerializable()
class InterruptedActionConditionModel {
  String sourceActor;
  int actionId;

  InterruptedActionConditionModel({
    this.sourceActor = "<unknown>",
    this.actionId = 0xFF14
  });

  factory InterruptedActionConditionModel.fromJson(Map<String, dynamic> json) => _$InterruptedActionConditionModelFromJson(json);

  Map<String, dynamic> toJson() => _$InterruptedActionConditionModelToJson(this);
}