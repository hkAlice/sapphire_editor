import 'package:json_annotation/json_annotation.dart';

part 'phaseactive_condition_model.g.dart';

@JsonSerializable()
class PhaseActiveConditionModel {
  String sourceActor;
  String phaseName;

  PhaseActiveConditionModel({
    this.sourceActor = "<unknown>",
    this.phaseName = "<unset>"
  });

  factory PhaseActiveConditionModel.fromJson(Map<String, dynamic> json) => _$PhaseActiveConditionModelFromJson(json);

  Map<String, dynamic> toJson() => _$PhaseActiveConditionModelToJson(this);
}