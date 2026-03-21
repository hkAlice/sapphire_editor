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

  static const VERSION_MODEL = 30;

  static String _nextUniqueActorName(
    String requestedName,
    Set<String> usedNames, {
    required int layoutId,
  }) {
    final baseName =
        requestedName.trim().isEmpty ? "Actor" : requestedName.trim();

    if(!usedNames.contains(baseName)) {
      return baseName;
    }

    var candidate = "$baseName (LID $layoutId)";
    var suffix = 1;

    while (usedNames.contains(candidate)) {
      candidate = "$baseName (LID $layoutId, $suffix)";
      suffix += 1;
    }

    return candidate;
  }

  static String makeUniqueActorName(
    String requestedName,
    Iterable<String> existingNames, {
    required int layoutId,
  }) {
    final usedNames = existingNames.toSet();
    return _nextUniqueActorName(
      requestedName,
      usedNames,
      layoutId: layoutId,
    );
  }

  static List<ActorModel> ensureUniqueActorNames(List<ActorModel> actors) {
    final usedNames = <String>{};
    final normalizedActors = <ActorModel>[];

    for(final actor in actors) {
      final uniqueName = _nextUniqueActorName(
        actor.name,
        usedNames,
        layoutId: actor.layoutId,
      );
      normalizedActors.add(
          uniqueName == actor.name ? actor : actor.copyWith(name: uniqueName));
      usedNames.add(uniqueName);
    }

    return normalizedActors;
  }

  static int nextUniquePhaseId(ActorModel actor) {
    if(actor.phases.isEmpty) {
      return 1;
    }

    final existingIds = actor.phases.map((phase) => phase.id).toSet();
    var nextId = actor.phases
            .map((phase) => phase.id)
            .reduce((left, right) => left > right ? left : right) +
        1;

    while (existingIds.contains(nextId)) {
      nextId += 1;
    }

    return nextId;
  }

  factory TimelineModel.fromJson(Map<String, dynamic> json) {
    final timeline = _$TimelineModelFromJson(json);
    timeline.actors = ensureUniqueActorNames(timeline.actors);
    return timeline;
  }

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
    final uniqueName = makeUniqueActorName(
      bnpcName,
      actors.map((a) => a.name),
      layoutId: layoutId,
    );

    var actorModel = ActorModel(
      id: actors.length + 1,
      hp: hp,
      layoutId: layoutId,
      name: uniqueName,
      type: "bnpc",
    );

    actors.add(actorModel);

    return actorModel;
  }

  TimelinePhaseModel addNewPhase(ActorModel? actor) {
    actor ??= actors.first;

    final newPhase = TimelinePhaseModel(
      id: nextUniquePhaseId(actor),
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
