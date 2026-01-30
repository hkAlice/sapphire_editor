import 'package:json_annotation/json_annotation.dart';
import 'package:sapphire_editor/utils/text_utils.dart';

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
    var sum = "Cast Action $actionId from $sourceActor to ${treatEnumName(targetType)}";
    
    if(targetType == ActorTargetType.selectorTarget || targetType == ActorTargetType.selectorPos) {
      sum += " $selectorName#${selectorIndex + 1}";
    }

    if(snapshot) {
      sum += " (snapshot @ ${snapshotTime}ms)";
    }

    return sum;
  }
}

enum ActorTargetType {
  @JsonValue("self")
  self,
  @JsonValue("target")
  target,
  @JsonValue("selectorPos")
  selectorPos,
  @JsonValue("selectorTarget")
  selectorTarget,
  @JsonValue("none")
  none
}