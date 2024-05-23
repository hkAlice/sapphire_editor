import 'package:json_annotation/json_annotation.dart';
import 'package:sapphire_editor/models/timeline/condition/types/combatstate_condition_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/hppctbetween_condition_model.dart';
import 'package:sapphire_editor/utils/text_utils.dart';

part 'phase_conditions_model.g.dart';

// todo: wish generics would work well here instead of infinite cast for paramData
@JsonSerializable()
class PhaseConditionModel {
  int id;
  String? description;
  PhaseConditionType condition;
  dynamic paramData = {};
  bool loop;
  bool enabled;
  
  String? targetActor;
  String? targetPhase;

  PhaseConditionModel({
    required this.id,
    required this.condition,
    required this.loop,
    this.paramData,
    this.enabled = true,
    this.description = "",
    this.targetActor,
    this.targetPhase
  }) {
    changeType(condition);
  }

  factory PhaseConditionModel.fromJson(Map<String, dynamic> json) => _$PhaseConditionModelFromJson(json);

  Map<String, dynamic> toJson() => _$PhaseConditionModelToJson(this);

  // todo: ugliest fucking thing ever. this sucks to do with json serializable + no setter
  void changeType(PhaseConditionType type) {
    if(type != condition) {
      paramData = <String, dynamic>{};
    }

    condition = type;

    paramData ??= <String, dynamic>{};

    if(paramData is Map<String, dynamic>) {
      if(type == PhaseConditionType.hpPctBetween) {
        paramData = HPPctBetweenConditionModel.fromJson(paramData);
      } else if(type == PhaseConditionType.combatState) {
        paramData = CombatStateConditionModel.fromJson(paramData);
      } else {
        // keep as is, break shit
      }
    }
    
  }

  String getReadableConditionStr() {
    String summary = "If ";

    if(condition == PhaseConditionType.hpPctBetween) {
      var param = paramData as HPPctBetweenConditionModel;
      summary += "${param.sourceActor} has ${param.hpMin}% < HP < ${param.hpMax}%";
    } else if (condition == PhaseConditionType.combatState) {
      var param = paramData as CombatStateConditionModel;
      summary += "${param.sourceActor} state is ${treatEnumName(param.combatState!)}";
    } else {
      // keep as is, break shit
      summary += "condition ${treatEnumName(condition)}";
    }

    summary += ", ${loop ? "loop" : "push"} $targetActor->$targetPhase";
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