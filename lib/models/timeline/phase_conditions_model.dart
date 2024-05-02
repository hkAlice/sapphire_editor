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

  String readableConditionStr() {
    String summary = "If ";
    switch(condition) {
      case PhaseConditionType.directorVarGreaterThan:
        summary += "Director var 0x${params.elementAtOrNull(0)!.toRadixString(16).toUpperCase()} >= ${params.elementAtOrNull(1)}";
        break;
      case PhaseConditionType.elapsedTimeGreaterThan:
        summary += "Elapsed time > ${params.elementAtOrNull(0)}ms";
        break;
      case PhaseConditionType.hpPctBetween:
        summary += "HP% between ${params.elementAtOrNull(0)} and ${params.elementAtOrNull(1)}";
        break;
      case PhaseConditionType.hpPctLessThan:
        summary += "HP% < ${params.elementAtOrNull(0)}";
        break;
      default:
        summary += "${treatEnumName(condition)} (${params.join(", ")})";
        break;
    }

    summary += ", ${loop ? "loop" : "push"} $phase";
    return summary;
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

