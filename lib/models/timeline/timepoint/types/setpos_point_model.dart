import 'package:json_annotation/json_annotation.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/castaction_point_model.dart';

part 'setpos_point_model.g.dart';

@JsonSerializable()
class SetPosPointModel {
  @JsonKey(defaultValue: [0.0, 0.0, 0.0])
  List<double> pos = [0.0, 0.0, 0.0];
  double rot;
  String actorName;
  String targetActor;
  ActorTargetType targetType;
  String selectorName;
  int selectorIndex;
  PositionType positionType;

  SetPosPointModel({
    required this.pos,
    this.rot = 0.0,
    this.actorName = "<unknown>",
    this.targetActor = "<unknown>",
    this.targetType = ActorTargetType.self,
    this.selectorName = "<unset>",
    this.selectorIndex = 0,
    this.positionType = PositionType.absolute
  });

  factory SetPosPointModel.fromJson(Map<String, dynamic> json) => _$SetPosPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$SetPosPointModelToJson(this);

  @override
  String toString() {
    if(positionType == PositionType.absolute) {
      String sumStr = "Actor $actorName to ";
      switch(targetType) {
        case ActorTargetType.self:
          sumStr += "(X: ${pos[0]}, Y: ${pos[1]}, Z: ${pos[2]}, Rot: $rot})";
          return sumStr;
        case ActorTargetType.target:
          sumStr += "actor $targetActor";
          break;
        case ActorTargetType.selector:
          sumStr += "selector $selectorName#$selectorIndex";
          break;
        default:
          sumStr += "<unknown>";
          break;
      }

      sumStr += ", offset (Forward: ${pos[0]}, Right: ${pos[1]}, Up: ${pos[2]}, Rot: $rot})";
      return sumStr;
    }
    else {
      String sumStr = "Offset $actorName relative to ";
      switch(targetType) {
        case ActorTargetType.self:
          sumStr += "self";
          break;
        case ActorTargetType.target:
          sumStr += "actor $targetActor";
          break;
        case ActorTargetType.selector:
          sumStr += "selector $selectorName#$selectorIndex";
        default:
          sumStr += "<unknown>";
      }

      sumStr += " by (Forward: ${pos[0]}, Right: ${pos[1]}, Up: ${pos[2]}, Rot: $rot})";
      return sumStr;
    } 
  }
}

enum PositionType {
  @JsonValue("absolute")
  absolute,
  @JsonValue("relative")
  relative,
}