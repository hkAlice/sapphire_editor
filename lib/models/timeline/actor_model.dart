import 'package:json_annotation/json_annotation.dart';
import 'package:sapphire_editor/models/timeline/timeline_phase_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_schedule_model.dart';

part 'actor_model.g.dart';

@JsonSerializable()
class ActorModel {
  int id;
  String name;
  String type;
  int layoutId;
  int hp;
  int initialPhaseId;
  List<TimelinePhaseModel> phases;
  List<String> subactors;

  @JsonKey(includeFromJson: false, includeToJson: false)
  List<TimelineScheduleModel> get schedules {
    if(phases.isEmpty) {
      phases.add(TimelinePhaseModel(id: 1, name: 'Initial Phase'));
    }

    return phases.expand((phase) => phase.schedules).toList();
  }

  set schedules(List<TimelineScheduleModel> value) {
    if(phases.isEmpty) {
      phases.add(TimelinePhaseModel(
          id: 1, name: 'Initial Phase', schedules: value));
      return;
    }

    phases[0] = phases[0].copyWith(schedules: value);
  }

  ActorModel({
    required this.id,
    required this.name,
    required this.type,
    required this.layoutId,
    required this.hp,
    this.initialPhaseId = 1,
    phaseList,
    subactorsList,
  })  : phases = phaseList ?? [],
        subactors = subactorsList ?? [];

  factory ActorModel.fromJson(Map<String, dynamic> json) =>
      _$ActorModelFromJson(json);

  Map<String, dynamic> toJson() => _$ActorModelToJson(this);

  ActorModel copyWith({
    int? id,
    String? name,
    String? type,
    int? layoutId,
    int? initialPhaseId,
    int? hp,
    List<TimelinePhaseModel>? phases,
    List<TimelineScheduleModel>? schedules,
    List<String>? subactors,
  }) {
    final nextPhases = phases ??
        (schedules != null
            ? [
                if(this.phases.isNotEmpty)
                  this.phases.first.copyWith(schedules: schedules)
                else
                  TimelinePhaseModel(
                    id: 1,
                    name: 'Initial Phase',
                    schedules: schedules,
                  )
              ]
            : this.phases);

    return ActorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      layoutId: layoutId ?? this.layoutId,
      initialPhaseId: initialPhaseId ?? this.initialPhaseId,
      hp: hp ?? this.hp,
      phaseList: nextPhases,
      subactorsList: subactors ?? this.subactors,
    );
  }
}
