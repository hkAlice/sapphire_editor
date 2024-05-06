import 'package:json_annotation/json_annotation.dart';
import 'package:sapphire_editor/models/timeline/phase_conditions_model.dart';
import 'timeline_phase_model.dart';

part 'timeline_model.g.dart';

@JsonSerializable()
class TimelineModel {
  String name;

  List<PhaseConditionModel> phaseConditions;
  List<TimelinePhaseModel> phases;

  final int version;

  TimelineModel({
    required this.name,
    phaseList,
    conditionList,
    this.version = TimelineModel.VERSION_MODEL
  }) : phases = phaseList ?? [], phaseConditions = conditionList ?? [];

  static const VERSION_MODEL = 1;

  factory TimelineModel.fromJson(Map<String, dynamic> json) => _$TimelineModelFromJson(json);

  Map<String, dynamic> toJson() => _$TimelineModelToJson(this);

  // todo: move this to timelinesvc ideally
  TimelinePhaseModel addNewPhase() {
    var newPhase = TimelinePhaseModel(id: phases.length + 1, name: "Phase ${phases.length + 1}");
    phases.add(newPhase);

    return newPhase;
  }

  PhaseConditionModel addNewCondition([PhaseConditionModel? condition]) {
    condition ??= PhaseConditionModel(
      condition: PhaseConditionType.combatState,
      params: [0, 1],
      phase: phases.isEmpty ? "Undefined" : phases.first.name,
      description: "",
      loop: true,
    );
    
    // todo: yucky sucky for bucky??? sussyyy???? sussy baka?
    condition.resetParams();

    phaseConditions.add(condition);

    return condition;
  }

  void checkSanity() {

  }
}