import 'package:json_annotation/json_annotation.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/condition/phase_conditions_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/combatstate_condition_model.dart';
import 'package:sapphire_editor/models/timeline/selector/selector_filter_model.dart';
import 'package:sapphire_editor/models/timeline/selector/selector_model.dart';
import 'timeline_phase_model.dart';

part 'timeline_model.g.dart';

@JsonSerializable()
class TimelineModel {
  String name;
  final int version = TimelineModel.VERSION_MODEL;

  List<ActorModel> actors;
  List<PhaseConditionModel> conditions;
  List<SelectorModel> selectors;

  TimelineModel({
    required this.name,
    phaseList,
    conditionList,
    actorList,
    selectorList
  }) : conditions = conditionList ?? [], actors = actorList ?? [], selectors = selectorList ?? [];

  static const VERSION_MODEL = 7;

  factory TimelineModel.fromJson(Map<String, dynamic> json) => _$TimelineModelFromJson(json);

  Map<String, dynamic> toJson() => _$TimelineModelToJson(this);

  // todo: move this to timelinesvc ideally
  ActorModel addNewActor({String bnpcName = "Unknown", int layoutId = 0, int hp = 0xFF14}) {
    var actorModel = ActorModel(
      id: actors.length + 1,
      hp: hp,
      layoutId: layoutId,
      name: bnpcName,
      type: "bnpc",
    );

    actors.add(actorModel);

    return actorModel;
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
      id: conditions.length + 1,
      condition: PhaseConditionType.combatState,
      paramData: CombatStateConditionModel(combatState: ActorCombatState.combat, sourceActor: actors.first.name),
      targetActor: actors.first.name,
      targetPhase: actors.first.phases.isEmpty ? "" : actors.first.phases.first.name,
      description: "",
      loop: true,
    );

    conditions.add(condition);

    return condition;
  }

  SelectorModel addNewSelector([SelectorModel? selector]) {
    selector ??= SelectorModel(
      id: selectors.length + 1,
      name: "Selector ${selectors.length + 1}",
      count: 1,
      description: "",
      fillRandomEntries: false,
      filterList: [
        SelectorFilterModel(type: SelectorFilterType.player),
      ]
    );
    
    selectors.add(selector);
    
    return selector;
  }

  void checkSanity() {

  }
}