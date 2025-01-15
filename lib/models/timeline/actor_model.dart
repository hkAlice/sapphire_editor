import 'package:json_annotation/json_annotation.dart';
import 'package:sapphire_editor/models/timeline/timeline_schedule_model.dart';

part 'actor_model.g.dart';

@JsonSerializable()
class ActorModel {
  int id;
  String name;
  String type;
  int layoutId;
  int hp;
  List<TimelineScheduleModel> schedules;
  List<String> subactors;

  ActorModel({
    required this.id,
    required this.name,
    required this.type,
    required this.layoutId,
    required this.hp,
    subactorsList,
    scheduleList,
  }) : schedules = scheduleList ?? [], subactors = subactorsList ?? [];

  factory ActorModel.fromJson(Map<String, dynamic> json) => _$ActorModelFromJson(json);

  Map<String, dynamic> toJson() => _$ActorModelToJson(this);
}