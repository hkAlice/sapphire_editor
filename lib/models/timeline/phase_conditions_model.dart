import 'package:json_annotation/json_annotation.dart';

part 'phase_conditions_model.g.dart';

@JsonSerializable()
class PhaseConditionModel {
  String? description;
  PhaseConditionType condition;
  List<int> params;
  String phase;
  bool loop;

  //final List<ActorFlag> overrideFlags;

  PhaseConditionModel({
    required this.condition,
    required this.params,
    required this.phase,
    required this.loop,
    this.description = "",
  });

  factory PhaseConditionModel.fromJson(Map<String, dynamic> json) => _$PhaseConditionModelFromJson(json);

  Map<String, dynamic> toJson() => _$PhaseConditionModelToJson(this);
}

enum PhaseConditionType {
  @JsonValue("hpPctLessThan")
  hpPctLessThan,
  @JsonValue("elapsedTimeGreaterThan")
  elapsedTimeGreaterThan,
  @JsonValue("hpPctBetween")
  hpPctBetween,
  @JsonValue("directorVarGreaterThan")
  directorVarGreaterThan,
}