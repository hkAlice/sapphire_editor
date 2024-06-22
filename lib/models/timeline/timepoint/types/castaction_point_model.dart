import 'package:json_annotation/json_annotation.dart';

part 'castaction_point_model.g.dart';

@JsonSerializable()
class CastActionPointModel {
  String sourceActor;
  int actionId;
  ActorTargetType targetType;
  String selectorName;
  int selectorIndex;
  bool snapshot;
  int snapshotTime;

  CastActionPointModel({
    this.sourceActor = "<unknown>",
    this.actionId = 6116,
    this.targetType = ActorTargetType.self,
    this.selectorName = "<unset>",
    this.selectorIndex = 0,
    this.snapshot = false,
    this.snapshotTime = 0
  });

  factory CastActionPointModel.fromJson(Map<String, dynamic> json) => _$CastActionPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$CastActionPointModelToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum ActorTargetType {
  @JsonValue("self")
  self,
  @JsonValue("target")
  target,
  @JsonValue("selector")
  selector,
  @JsonValue("none")
  none
}