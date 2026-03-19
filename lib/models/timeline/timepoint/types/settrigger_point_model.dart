import 'package:json_annotation/json_annotation.dart';

part 'settrigger_point_model.g.dart';

@JsonSerializable()
class SetTriggerPointModel {
  String targetActor;
  int targetPhaseId;
  int triggerId;
  bool enabled;
  String triggerStr;

  SetTriggerPointModel({this.targetActor = "", this.targetPhaseId = 0, this.triggerId = 1, this.enabled = true, this.triggerStr = "<unknown>"});

  factory SetTriggerPointModel.fromJson(Map<String, dynamic> json) => _$SetTriggerPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$SetTriggerPointModelToJson(this);

  @override
  String toString() {
    final phaseLabel = targetPhaseId > 0 ? targetPhaseId.toString() : '?';
    return "${enabled ? 'Enable' : 'Disable'} Actor{$targetActor} => Phase{$phaseLabel} Trigger#$triggerId ($triggerStr)";
  }
}