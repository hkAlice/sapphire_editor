import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sapphire_editor/models/timeline/condition/types/combatstate_condition_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/getaction_condition_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/hppctbetween_condition_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/interruptedaction_condition_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/varequals_condition_model.dart';
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

  ConditionModel copyWith({
    int? id,
    String? description,
    ConditionType? condition,
    dynamic paramData,
    bool? loop,
    bool? enabled,
    String? targetActor,
    String? targetSchedule,
  }) {
    return ConditionModel(
      id: id ?? this.id,
      description: description ?? this.description,
      condition: condition ?? this.condition,
      paramData: paramData ?? this.paramData,
      loop: loop ?? this.loop,
      enabled: enabled ?? this.enabled,
      targetActor: targetActor ?? this.targetActor,
      targetSchedule: targetSchedule ?? this.targetSchedule,
    );
  }

  // Refactored changeType using switch expression instead of if-else chain
  void changeType(ConditionType type) {
    if(type != condition) {
      paramData = <String, dynamic>{};
    }

    condition = type;

    paramData ??= <String, dynamic>{};

    if(paramData is Map<String, dynamic>) {
      paramData = _conditionDataFactory(type, paramData);
    }
  }

  static dynamic _conditionDataFactory(ConditionType type, Map<String, dynamic> json) {
    return switch (type) {
      ConditionType.combatState => CombatStateConditionModel.fromJson(json),
      ConditionType.getAction => GetActionConditionModel.fromJson(json),
      ConditionType.hpPctBetween => HPPctBetweenConditionModel.fromJson(json),
      ConditionType.scheduleActive => ScheduleActiveConditionModel.fromJson(json),
      ConditionType.interruptedAction => InterruptedActionConditionModel.fromJson(json),
      ConditionType.varEquals => VarEqualsConditionModel.fromJson(json),
      _ => json, // Keep as is for types without specific models
    };
  }

  // Color getter using extension method
  Color get color => condition.color;
  
  // Display name getter using extension method
  String get displayName => condition.displayName;

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
    } else if (condition == ConditionType.varEquals) {
      var param = paramData as VarEqualsConditionModel;
      summary += "${treatEnumName(param.type)} var Index #${param.index} Value is #${param.val}";
    } else {
      // keep as is, break shit
      summary += "condition ${treatEnumName(condition)}";
    }

    summary += ", ${loop ? "loop" : "push"} $targetActor->$targetSchedule";
    return summary;
  }
  
  List<ConditionParamParser> getConditionParamParser() {
    return condition.paramParser;
  }
}

// Extension methods for ConditionType metadata
extension ConditionTypeExtension on ConditionType {
  Color get color {
    return switch (this) {
      ConditionType.combatState => Colors.red,
      ConditionType.getAction => Colors.orange,
      ConditionType.hpPctBetween => Colors.green,
      ConditionType.hpPctLessThan => Colors.green,
      ConditionType.scheduleActive => Colors.blue,
      ConditionType.interruptedAction => Colors.purple,
      ConditionType.varEquals => Colors.teal,
      ConditionType.directorVarGreaterThan => Colors.amber,
      ConditionType.elapsedTimeGreaterThan => Colors.grey,
    };
  }

  String get displayName {
    return switch (this) {
      ConditionType.combatState => "Combat State",
      ConditionType.getAction => "Get Action",
      ConditionType.hpPctBetween => "HP % Between",
      ConditionType.hpPctLessThan => "HP % Less Than",
      ConditionType.scheduleActive => "Schedule Active",
      ConditionType.interruptedAction => "Interrupted Action",
      ConditionType.varEquals => "Var Equals",
      ConditionType.directorVarGreaterThan => "Director Var >",
      ConditionType.elapsedTimeGreaterThan => "Elapsed Time >",
    };
  }

  List<ConditionParamParser> get paramParser {
    return switch (this) {
      ConditionType.combatState => [
          ConditionParamParser(label: "Actor", initialValue: 0),
          ConditionParamParser(label: "Idle, Combat, Retreat", initialValue: 1, isHex: false),
        ],
      ConditionType.directorVarGreaterThan => [
          ConditionParamParser(label: "Director (hex)", initialValue: 0x8, isHex: true),
          ConditionParamParser(label: "Greater than", initialValue: 1, isHex: false),
        ],
      ConditionType.elapsedTimeGreaterThan => [
          ConditionParamParser(label: "Elapsed time (ms)", initialValue: 30000),
        ],
      ConditionType.hpPctBetween => [
          ConditionParamParser(label: "Actor", initialValue: 0),
          ConditionParamParser(label: "HP Min", initialValue: 25),
          ConditionParamParser(label: "HP Max", initialValue: 50),
        ],
      ConditionType.hpPctLessThan => [
          ConditionParamParser(label: "Actor", initialValue: 0),
          ConditionParamParser(label: "HP Less Than", initialValue: 70),
        ],
      _ => [
          ConditionParamParser(label: "Param1"),
          ConditionParamParser(label: "Param2"),
          ConditionParamParser(label: "Param3"),
          ConditionParamParser(label: "Param4"),
        ],
    };
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
  interruptedAction,
  @JsonValue("varEquals")
  varEquals
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