import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sapphire_editor/models/timeline/condition/trigger_action_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/combatstate_condition_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/eobjinteract_condition_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/getaction_condition_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/hppctbetween_condition_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/interruptedaction_condition_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/varequals_condition_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/phaseactive_condition_model.dart';
import 'package:sapphire_editor/utils/text_utils.dart';

part 'trigger_model.g.dart';

@JsonSerializable()
class TriggerModel {
  int id;
  String? description;
  ConditionType condition;
  dynamic paramData = {};
  TriggerActionModel? action;

  @JsonKey(includeFromJson: false, includeToJson: false)
  bool loop;

  @JsonKey(includeFromJson: false, includeToJson: false)
  bool enabled;

  @JsonKey(includeFromJson: false, includeToJson: false)
  String? targetActor;

  @JsonKey(includeFromJson: false, includeToJson: false)
  String? targetSchedule;

  TriggerModel({
    required this.id,
    required this.condition, // todo: this needs to be an array, use chained AND/OR etc
    this.paramData,
    this.description = "",
    this.action,
    this.loop = false,
    this.enabled = true,
    this.targetActor,
    this.targetSchedule,
  }) {
    changeType(condition);
  }

  factory TriggerModel.fromJson(Map<String, dynamic> json) {
    final normalized = <String, dynamic>{...json};
    normalized['condition'] ??= normalized['conditionType'];
    if(normalized['condition'] == 'scheduleActive') {
      normalized['condition'] = 'phaseActive';
    }
    return _$TriggerModelFromJson(normalized);
  }

  Map<String, dynamic> toJson() => _$TriggerModelToJson(this);

  TriggerModel copyWith({
    int? id,
    String? description,
    ConditionType? condition,
    dynamic paramData,
    TriggerActionModel? action,
    bool? loop,
    bool? enabled,
    String? targetActor,
    String? targetSchedule,
  }) {
    return TriggerModel(
      id: id ?? this.id,
      description: description ?? this.description,
      condition: condition ?? this.condition,
      paramData: paramData ?? this.paramData,
      action: action ?? this.action,
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

  static dynamic _conditionDataFactory(
      ConditionType type, Map<String, dynamic> json) {
    return switch(type) {
      ConditionType.combatState => CombatStateConditionModel.fromJson(json),
      ConditionType.eObjInteract => EObjInteractConditionModel.fromJson(json),
      ConditionType.getAction => GetActionConditionModel.fromJson(json),
      ConditionType.hpPctBetween => HPPctBetweenConditionModel.fromJson(json),
      ConditionType.phaseActive => PhaseActiveConditionModel.fromJson(json),
      ConditionType.interruptedAction =>
        InterruptedActionConditionModel.fromJson(json),
      ConditionType.varEquals => VarEqualsConditionModel.fromJson(json),
      _ => json, // keep as is for types without specific models
    };
  }

  Color get color => condition.color;

  String get displayName => condition.displayName;

  String getReadableConditionStr() {
    String summary = "If ";

    if(condition == ConditionType.hpPctBetween) {
      var param = paramData as HPPctBetweenConditionModel;
      summary +=
          "${param.sourceActor} has ${param.hpMin}% < HP < ${param.hpMax}%";
    } else if(condition == ConditionType.getAction) {
      var param = paramData as GetActionConditionModel;
      summary += "${param.sourceActor} casts Action#${param.actionId}";
    } else if(condition == ConditionType.combatState) {
      var param = paramData as CombatStateConditionModel;
      summary +=
          "${param.sourceActor} state is ${treatEnumName(param.combatState!)}";
    } else if(condition == ConditionType.eObjInteract) {
      var param = paramData as EObjInteractConditionModel;
      summary +=
          "${param.eObjName.isEmpty ? 'Eobj' : param.eObjName} is interacted with";
    } else if(condition == ConditionType.phaseActive) {
      var param = paramData as PhaseActiveConditionModel;
      summary += "${param.sourceActor}->${param.phaseId} is active";
    } else if(condition == ConditionType.interruptedAction) {
      var param = paramData as InterruptedActionConditionModel;
      summary += "${param.sourceActor} interrupted on Action#${param.actionId}";
    } else if(condition == ConditionType.varEquals) {
      var param = paramData as VarEqualsConditionModel;
      summary +=
          "${treatEnumName(param.type)} var Index #${param.index} Value is #${param.val}";
    } else {
      // keep as is, break shit
      summary += "condition ${treatEnumName(condition)}";
    }

    if(action != null) {
      if(action!.type == 'transitionPhase' &&
          action!.phaseId != null &&
          action!.phaseId!.isNotEmpty) {
        summary += ", action transitionPhase -> ${action!.phaseId}";
      } else if(action!.type == 'timepoint' && action!.timepoint != null) {
        final triggerTimepoint = action!.timepoint!;
        final seconds = (triggerTimepoint.startTime / 1000).toStringAsFixed(1);
        summary +=
            ", action timepoint -> ${seconds}s ${treatEnumName(triggerTimepoint.type)} (${triggerTimepoint.data})";
      } else {
        summary += ", action ${action!.type}";
      }
    }
    return summary;
  }

  List<ConditionParamParser> getConditionParamParser() {
    return condition.paramParser;
  }
}

extension ConditionTypeExtension on ConditionType {
  Color get color {
    return switch(this) {
      ConditionType.combatState => Colors.red,
      ConditionType.eObjInteract => Colors.lightBlue,
      ConditionType.getAction => Colors.orange,
      ConditionType.hpPctBetween => Colors.green,
      ConditionType.hpPctLessThan => Colors.green,
      ConditionType.phaseActive => Colors.blue,
      ConditionType.interruptedAction => Colors.purple,
      ConditionType.varEquals => Colors.teal,
      ConditionType.directorVarGreaterThan => Colors.amber,
      ConditionType.elapsedTimeGreaterThan => Colors.grey,
    };
  }

  String get displayName {
    return switch(this) {
      ConditionType.combatState => "Combat State",
      ConditionType.eObjInteract => "EObj Interact",
      ConditionType.getAction => "Get Action",
      ConditionType.hpPctBetween => "HP % Between",
      ConditionType.hpPctLessThan => "HP % Less Than",
      ConditionType.phaseActive => "Phase Active",
      ConditionType.interruptedAction => "Interrupted Action",
      ConditionType.varEquals => "Var Equals",
      ConditionType.directorVarGreaterThan => "Director Var >",
      ConditionType.elapsedTimeGreaterThan => "Elapsed Time >",
    };
  }

  List<ConditionParamParser> get paramParser {
    return switch(this) {
      ConditionType.combatState => [
          ConditionParamParser(label: "Actor", initialValue: 0),
          ConditionParamParser(
              label: "Idle, Combat, Retreat", initialValue: 1, isHex: false),
        ],
      ConditionType.eObjInteract => [
          ConditionParamParser(label: "EObj Actor", initialValue: 0),
        ],
      ConditionType.directorVarGreaterThan => [
          ConditionParamParser(
              label: "Director (hex)", initialValue: 0x8, isHex: true),
          ConditionParamParser(
              label: "Greater than", initialValue: 1, isHex: false),
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
  @JsonValue("eObjInteract")
  eObjInteract,
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
  @JsonValue("phaseActive")
  phaseActive,
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

  ConditionParamParser(
      {required this.label,
      this.type = "input",
      this.initialValue = 50,
      this.isHex = false});
}
