import 'package:json_annotation/json_annotation.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/condition/trigger_model.dart';
import 'package:sapphire_editor/models/timeline/selector/selector_filter_model.dart';
import 'package:sapphire_editor/models/timeline/selector/selector_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_phase_model.dart';

part 'timeline_model.g.dart';

@JsonSerializable()
class TimelineModel {
  String name;
  int version;

  List<ActorModel> actors;
  List<SelectorModel> selectors;

  @JsonKey(includeFromJson: false, includeToJson: false)
  List<TriggerModel> get conditions {
    return actors
        .expand((actor) => actor.phases)
        .expand((phase) => phase.triggers)
        .toList();
  }

  TimelineModel(
      {required this.name,
      this.version = TimelineModel.VERSION_MODEL,
      actorList,
      selectorList})
      : actors = actorList ?? [],
        selectors = selectorList ?? [];

  static const VERSION_MODEL = 22;

  factory TimelineModel.fromJson(Map<String, dynamic> json) =>
      _$TimelineModelFromJson(json);

  Map<String, dynamic> toJson() => _$TimelineModelToJson(this);

  TimelineModel copyWith({
    String? name,
    int? version,
    List<ActorModel>? actors,
    List<SelectorModel>? selectors,
  }) {
    return TimelineModel(
      name: name ?? this.name,
      version: version ?? this.version,
      actorList: actors ?? this.actors,
      selectorList: selectors ?? this.selectors,
    );
  }

  // todo: move this to timelinesvc ideally
  ActorModel addNewActor(
      {String bnpcName = "Unknown", int layoutId = 0, int hp = 0xFF14}) {
    var actorModel = ActorModel(
      id: actors.length + 1,
      hp: hp,
      layoutId: layoutId,
      name: bnpcName,
      type: "bnpc",
      phaseList: [TimelinePhaseModel(id: "phase_1", name: "Initial Phase")],
    );

    actors.add(actorModel);

    return actorModel;
  }

  TimelinePhaseModel addNewPhase(ActorModel? actor) {
    actor ??= actors.first;

    final newPhase = TimelinePhaseModel(
      id: "phase_${actor.phases.length + 1}",
      name: "Phase ${actor.phases.length + 1}",
    );

    actor.phases.add(newPhase);

    return newPhase;
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
        ]);

    selectors.add(selector);

    return selector;
  }

  void checkSanity() {}
}
