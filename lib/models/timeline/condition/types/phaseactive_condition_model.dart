import 'package:json_annotation/json_annotation.dart';

part 'phaseactive_condition_model.g.dart';

@JsonSerializable()
class PhaseActiveConditionModel {
  String sourceActor;
  String phaseId;

  PhaseActiveConditionModel({
    this.sourceActor = "<unknown>",
    this.phaseId = "<unset>",
  });

  factory PhaseActiveConditionModel.fromJson(Map<String, dynamic> json) {
    final normalized = <String, dynamic>{...json};
    normalized['phaseId'] ??= normalized['scheduleName'];
    return _$PhaseActiveConditionModelFromJson(normalized);
  }

  Map<String, dynamic> toJson() => _$PhaseActiveConditionModelToJson(this);
}
