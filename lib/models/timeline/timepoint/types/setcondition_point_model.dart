import 'package:json_annotation/json_annotation.dart';

part 'setcondition_point_model.g.dart';

@JsonSerializable()
class SetConditionPointModel {
  int conditionId;
  bool enabled;

  SetConditionPointModel({this.conditionId = 1, this.enabled = true});

  factory SetConditionPointModel.fromJson(Map<String, dynamic> json) => _$SetConditionPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$SetConditionPointModelToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}