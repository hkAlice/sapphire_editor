import 'package:json_annotation/json_annotation.dart';

part 'setcondition_point_model.g.dart';

@JsonSerializable()
class SetConditionPointModel {
  int conditionId;
  String conditionStr;
  bool enabled;

  SetConditionPointModel({this.conditionId = 1, this.enabled = true, this.conditionStr = "<unknown>"});

  factory SetConditionPointModel.fromJson(Map<String, dynamic> json) => _$SetConditionPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$SetConditionPointModelToJson(this);

  @override
  String toString() {
    return "${enabled ? 'Enable' : 'Disable'} Condition#$conditionId ($conditionStr)";
  }
}