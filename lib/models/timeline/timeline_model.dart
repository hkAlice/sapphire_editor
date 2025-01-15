import 'package:json_annotation/json_annotation.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/condition/condition_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/combatstate_condition_model.dart';
import 'package:sapphire_editor/models/timeline/selector/selector_filter_model.dart';
import 'package:sapphire_editor/models/timeline/selector/selector_model.dart';
import 'timeline_schedule_model.dart';

part 'timeline_model.g.dart';

@JsonSerializable()
class TimelineModel {
  String name;
  int version;

  List<ActorModel> actors;
  List<ConditionModel> conditions;
  List<SelectorModel> selectors;

  TimelineModel({
    required this.name,
    this.version = TimelineModel.VERSION_MODEL,
    scheduleList,
    conditionList,
    actorList,
    selectorList
  }) : conditions = conditionList ?? [], actors = actorList ?? [], selectors = selectorList ?? [];

  static const VERSION_MODEL = 10;

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
  TimelineScheduleModel addNewSchedule(ActorModel? actor) {
    actor ??= actors.first;
    // todo: enable adding phases to other actors

    var newSchedule = TimelineScheduleModel(id: actor.schedules.length + 1, name: "Schedule ${actor.schedules.length + 1}");
    actor.schedules.add(newSchedule);

    return newSchedule;
  }

  ConditionModel addNewCondition([ConditionModel? condition]) {
    condition ??= ConditionModel(
      id: conditions.length + 1,
      condition: ConditionType.combatState,
      paramData: CombatStateConditionModel(combatState: ActorCombatState.combat, sourceActor: actors.first.name),
      targetActor: actors.first.name,
      targetSchedule: actors.first.schedules.isEmpty ? "" : actors.first.schedules.first.name,
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