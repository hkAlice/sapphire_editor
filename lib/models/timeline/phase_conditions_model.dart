import 'package:json_annotation/json_annotation.dart';
import 'package:sapphire_editor/utils/text_utils.dart';

part 'phase_conditions_model.g.dart';

@JsonSerializable()
class PhaseConditionModel {
  String? description;
  PhaseConditionType condition;
  List<int> params;
  String phase;
  bool loop;
  bool enabled;

  //final List<ActorFlag> overrideFlags;

  PhaseConditionModel({
    required this.condition,
    required this.params,
    required this.phase,
    required this.loop,
    this.enabled = true,
    this.description = "",
  });

  factory PhaseConditionModel.fromJson(Map<String, dynamic> json) => _$PhaseConditionModelFromJson(json);

  Map<String, dynamic> toJson() => _$PhaseConditionModelToJson(this);

  String readableConditionType() {
    switch(condition) {
      case PhaseConditionType.directorVarGreaterThan:
        return "Director var 0x${params.elementAtOrNull(0)!.toRadixString(16)} >= ${params.elementAtOrNull(1)}";
      case PhaseConditionType.elapsedTimeGreaterThan:
        return "Elapsed time >= ${params.elementAtOrNull(0)}ms";
      case PhaseConditionType.hpPctBetween:
        return "HP% between ${params.elementAtOrNull(0)} and ${params.elementAtOrNull(1)}";
      case PhaseConditionType.hpPctLessThan:
        return "HP% <= ${params.elementAtOrNull(0)}";
      default:
        return "${treatEnumName(condition)} (${params.join(", ")})";
    }
  }
}

enum PhaseConditionType {
  @JsonValue("directorVarGreaterThan")
  directorVarGreaterThan,
  @JsonValue("elapsedTimeGreaterThan")
  elapsedTimeGreaterThan,
  @JsonValue("hpPctBetween")
  hpPctBetween,
  @JsonValue("hpPctLessThan")
  hpPctLessThan,
}

