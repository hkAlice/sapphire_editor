import 'package:json_annotation/json_annotation.dart';

part 'getaction_condition_model.g.dart';

@JsonSerializable()
class GetActionConditionModel {
  String sourceActor;
  int actionId;

  GetActionConditionModel({
    this.sourceActor = "<unknown>",
    this.actionId = 0xFF14
  });

  factory GetActionConditionModel.fromJson(Map<String, dynamic> json) => _$GetActionConditionModelFromJson(json);

  Map<String, dynamic> toJson() => _$GetActionConditionModelToJson(this);
}