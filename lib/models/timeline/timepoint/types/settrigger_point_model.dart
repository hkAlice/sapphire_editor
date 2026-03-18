import 'package:json_annotation/json_annotation.dart';

part 'settrigger_point_model.g.dart';

@JsonSerializable()
class SetTriggerPointModel {
  int conditionId;
  String conditionStr;
  bool enabled;

  SetTriggerPointModel({this.conditionId = 1, this.enabled = true, this.conditionStr = "<unknown>"});

  factory SetTriggerPointModel.fromJson(Map<String, dynamic> json) => _$SetTriggerPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$SetTriggerPointModelToJson(this);

  @override
  String toString() {
    return "${enabled ? 'Enable' : 'Disable'} Condition#$conditionId ($conditionStr)";
  }
}