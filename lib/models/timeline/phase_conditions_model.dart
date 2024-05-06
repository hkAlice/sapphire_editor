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

  void resetParams() {
    params.clear();
    var paramParser = getConditionParamParser();
    for(var paramData in paramParser) {
      params.add(paramData.initialValue);
    }
  }

  String getReadableConditionStr() {
    String summary = "If ";
    String actorIdStr = params.elementAtOrNull(0) == 0 ? "Self" : "Actor ${params.elementAtOrNull(0).toString()}";

    switch(condition) {
      case PhaseConditionType.combatState:
        // todo: i don't like params only being ints
        // todo: ENUM THIS, STOP BEING LAZY
        String combatStateStr = "Idle";
        if(params.elementAtOrNull(1) == 1) {
          combatStateStr = "In Combat";
        }
        if(params.elementAtOrNull(1) == 2) {
          combatStateStr = "Retreating";
        }

        summary += "$actorIdStr combat state is $combatStateStr";
        break;
      case PhaseConditionType.directorVarGreaterThan:
        summary += "Director var 0x${params.elementAtOrNull(0)!.toRadixString(16).toUpperCase()} >= ${params.elementAtOrNull(1)}";
        break;
      case PhaseConditionType.elapsedTimeGreaterThan:
        summary += "Elapsed time > ${params.elementAtOrNull(0)}ms";
        break;
      case PhaseConditionType.hpPctBetween:
        summary += "$actorIdStr HP% between ${params.elementAtOrNull(1)}% and ${params.elementAtOrNull(2)}%";
        break;
      case PhaseConditionType.hpPctLessThan:
        summary += "$actorIdStr HP% < ${params.elementAtOrNull(1)}%";
        break;
      default:
        summary += "${treatEnumName(condition)} (${params.join(", ")})";
        break;
    }

    summary += ", ${loop ? "loop" : "push"} $phase";
    return summary;
  }
  
  List<PhaseConditionParamParser> getConditionParamParser() {

    switch(condition) {
      case PhaseConditionType.combatState: {
        return [
          PhaseConditionParamParser(label: "Actor", initialValue: 0),
          PhaseConditionParamParser(label: "Idle, Combat, Retreat", initialValue: 1, isHex: false),
        ];
      }
      case PhaseConditionType.directorVarGreaterThan: {
        return [
          PhaseConditionParamParser(label: "Director (hex)", initialValue: 0x8, isHex: true),
          PhaseConditionParamParser(label: "Greater than", initialValue: 1, isHex: false),
        ];
      }
      case PhaseConditionType.elapsedTimeGreaterThan: {
        return [
          PhaseConditionParamParser(label: "Elapsed time (ms)", initialValue: 30000),
        ];
      }
      case PhaseConditionType.hpPctBetween: {
        return [
          PhaseConditionParamParser(label: "Actor", initialValue: 0),
          PhaseConditionParamParser(label: "HP Min", initialValue: 25),
          PhaseConditionParamParser(label: "HP Max", initialValue: 50),
        ];
      }
      case PhaseConditionType.hpPctLessThan: {
        return [
          PhaseConditionParamParser(label: "Actor", initialValue: 0),
          PhaseConditionParamParser(label: "HP Less Than", initialValue: 70),
        ];
      }
      default: {
        return [
          PhaseConditionParamParser(label: "Param1",),
          PhaseConditionParamParser(label: "Param2",),
          PhaseConditionParamParser(label: "Param3",),
          PhaseConditionParamParser(label: "Param4",),
        ];
      }
    }
  }
}

enum PhaseConditionType {
  @JsonValue("combatState")
  combatState,
  @JsonValue("directorVarGreaterThan")
  directorVarGreaterThan,
  @JsonValue("elapsedTimeGreaterThan")
  elapsedTimeGreaterThan,
  @JsonValue("hpPctBetween")
  hpPctBetween,
  @JsonValue("hpPctLessThan")
  hpPctLessThan,
}

/*
extension PhaseConditionTypeExt on PhaseConditionType {
  List<PhaseConditionParamParser> getConditionParamParser() {
}*/

class PhaseConditionParamParser {
  final String label;
  final String type;
  final int initialValue;
  final bool isHex;

  PhaseConditionParamParser({
    required this.label,
    this.type = "input",
    this.initialValue = 50,
    this.isHex = false
  });
}