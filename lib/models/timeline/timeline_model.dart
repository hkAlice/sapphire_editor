import 'package:json_annotation/json_annotation.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/condition/phase_conditions_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/combatstate_condition_model.dart';
import 'timeline_phase_model.dart';

part 'timeline_model.g.dart';

@JsonSerializable()
class TimelineModel {
  String name;
  final int version = TimelineModel.VERSION_MODEL;

  List<ActorModel> actors;
  List<PhaseConditionModel> phaseConditions;
  //List<TimelinePhaseModel> phases;

  TimelineModel({
    required this.name,
    phaseList,
    conditionList,
    actorList,
  }) : phaseConditions = conditionList ?? [], actors = actorList ?? [];

  static const VERSION_MODEL = 3;

  factory TimelineModel.fromJson(Map<String, dynamic> json) => _$TimelineModelFromJson(json);

  Map<String, dynamic> toJson() => _$TimelineModelToJson(this);

  // todo: move this to timelinesvc ideally
  ActorModel addNewActor() {
    // todo: enable adding phases to other actors

    var newActor = ActorModel(
      id: actors.length + 1,
      hp: 0xFF14,
      layoutId: 4126276,
      name: "Ifrit ${actors.length + 1}",
      type: "bnpc",
    );

    actors.add(newActor);

    return newActor;
  }

  // todo: move this to timelinesvc ideally
  TimelinePhaseModel addNewPhase(ActorModel? actor) {
    actor ??= actors.first;
    // todo: enable adding phases to other actors

    var newPhase = TimelinePhaseModel(id: actor.phases.length + 1, name: "Phase ${actor.phases.length + 1}");
    actor.phases.add(newPhase);

    return newPhase;
  }

  PhaseConditionModel addNewCondition([PhaseConditionModel? condition]) {
    condition ??= PhaseConditionModel(
      condition: PhaseConditionType.combatState,
      paramData: CombatStateConditionModel(combatState: ActorCombatState.combat, sourceActor: actors.first.name),
      targetActor: actors.first.name,
      targetPhase: actors.first.phases.isEmpty ? "" : actors.first.phases.first.name,
      description: "",
      loop: true,
    );

    phaseConditions.add(condition);

    return condition;
  }

  void checkSanity() {

  }
}