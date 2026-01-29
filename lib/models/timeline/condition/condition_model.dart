import 'package:json_annotation/json_annotation.dart';
import 'package:sapphire_editor/models/timeline/condition/types/combatstate_condition_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/getaction_condition_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/hppctbetween_condition_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/interruptedaction_condition_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/scheduleactive_condition_model.dart';
import 'package:sapphire_editor/utils/text_utils.dart';

part 'condition_model.g.dart';

// todo: wish generics would work well here instead of infinite cast for paramData
@JsonSerializable()
class ConditionModel {
  int id;
  String? description;
  ConditionType condition;
  dynamic paramData = {};
  bool loop;
  bool enabled;
  
  String? targetActor;
  String? targetSchedule;

  ConditionModel({
    required this.id,
    required this.condition,
    required this.loop,
    this.paramData,
    this.enabled = true,
    this.description = "",
    this.targetActor,
    this.targetSchedule
  }) {
    changeType(condition);
  }

  factory ConditionModel.fromJson(Map<String, dynamic> json) => _$ConditionModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConditionModelToJson(this);

  // todo: ugliest fucking thing ever. this sucks to do with json serializable + no setter
  void changeType(ConditionType type) {
    if(type != condition) {
      paramData = <String, dynamic>{};
    }

    condition = type;

    paramData ??= <String, dynamic>{};

    if(paramData is Map<String, dynamic>) {
      if(type == ConditionType.combatState) {
        paramData = CombatStateConditionModel.fromJson(paramData);
      } else if(type == ConditionType.getAction) {
        paramData = GetActionConditionModel.fromJson(paramData);
      } else if(type == ConditionType.hpPctBetween) {
        paramData = HPPctBetweenConditionModel.fromJson(paramData);
      } else if(type == ConditionType.combatState) {
        paramData = CombatStateConditionModel.fromJson(paramData);
      } else if(type == ConditionType.scheduleActive) {
        paramData = ScheduleActiveConditionModel.fromJson(paramData);
      } else if(type == ConditionType.interruptedAction) {
        paramData = InterruptedActionConditionModel.fromJson(paramData);
      } else {
        // keep as is, break shit
      }
    }
    
  }

  String getReadableConditionStr() {
    String summary = "If ";

    if(condition == ConditionType.hpPctBetween) {
      var param = paramData as HPPctBetweenConditionModel;
      summary += "${param.sourceActor} has ${param.hpMin}% < HP < ${param.hpMax}%";
    } else if (condition == ConditionType.getAction) {
      var param = paramData as GetActionConditionModel;
      summary += "${param.sourceActor} casts Action#${param.actionId}";
    } else if (condition == ConditionType.combatState) {
      var param = paramData as CombatStateConditionModel;
      summary += "${param.sourceActor} state is ${treatEnumName(param.combatState!)}";
    } else if (condition == ConditionType.scheduleActive) {
      var param = paramData as ScheduleActiveConditionModel;
      summary += "${param.sourceActor}->${param.scheduleName} is active";
    } else if (condition == ConditionType.interruptedAction) {
      var param = paramData as InterruptedActionConditionModel;
      summary += "${param.sourceActor} interrupted on Action#${param.actionId}";
    } else {
      // keep as is, break shit
      summary += "condition ${treatEnumName(condition)}";
    }

    summary += ", ${loop ? "loop" : "push"} $targetActor->$targetSchedule";
    return summary;
  }
  
  List<ConditionParamParser> getConditionParamParser() {

    switch(condition) {
      case ConditionType.combatState: {
        return [
          ConditionParamParser(label: "Actor", initialValue: 0),
          ConditionParamParser(label: "Idle, Combat, Retreat", initialValue: 1, isHex: false),
        ];
      }
      case ConditionType.directorVarGreaterThan: {
        return [
          ConditionParamParser(label: "Director (hex)", initialValue: 0x8, isHex: true),
          ConditionParamParser(label: "Greater than", initialValue: 1, isHex: false),
        ];
      }
      case ConditionType.elapsedTimeGreaterThan: {
        return [
          ConditionParamParser(label: "Elapsed time (ms)", initialValue: 30000),
        ];
      }
      case ConditionType.hpPctBetween: {
        return [
          ConditionParamParser(label: "Actor", initialValue: 0),
          ConditionParamParser(label: "HP Min", initialValue: 25),
          ConditionParamParser(label: "HP Max", initialValue: 50),
        ];
      }
      case ConditionType.hpPctLessThan: {
        return [
          ConditionParamParser(label: "Actor", initialValue: 0),
          ConditionParamParser(label: "HP Less Than", initialValue: 70),
        ];
      }
      default: {
        return [
          ConditionParamParser(label: "Param1",),
          ConditionParamParser(label: "Param2",),
          ConditionParamParser(label: "Param3",),
          ConditionParamParser(label: "Param4",),
        ];
      }
    }
  }
}

enum ConditionType {
  @JsonValue("combatState")
  combatState,
  @JsonValue("directorVarGreaterThan")
  directorVarGreaterThan,
  @JsonValue("elapsedTimeGreaterThan")
  elapsedTimeGreaterThan,
  @JsonValue("getAction")
  getAction,
  @JsonValue("hpPctBetween")
  hpPctBetween,
  @JsonValue("hpPctLessThan")
  hpPctLessThan,
  @JsonValue("scheduleActive")
  scheduleActive,
  @JsonValue("interruptedAction")
  interruptedAction
}

/*
extension PhaseConditionTypeExt on PhaseConditionType {
  List<PhaseConditionParamParser> getConditionParamParser() {
}*/

class ConditionParamParser {
  final String label;
  final String type;
  final int initialValue;
  final bool isHex;

  ConditionParamParser({
    required this.label,
    this.type = "input",
    this.initialValue = 50,
    this.isHex = false
  });
}