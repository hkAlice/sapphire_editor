import 'package:json_annotation/json_annotation.dart';

part 'pathto_point_model.g.dart';

@JsonSerializable()
class PathToPointModel {
  @JsonKey(defaultValue: [0.0, 0.0, 0.0])
  List<double> pos = [0.0, 0.0, 0.0];
  String actorName;
  bool useNavi = true;
  PathToType pathType;
  String targetActor;
  int serverPathId = 0;
  String selectorName;
  int selectorIndex;

  PathToPointModel({
    required this.pos,
    this.actorName = "<unknown>",
    this.useNavi = true,
    this.serverPathId = 0,
    this.pathType = PathToType.none,
    this.targetActor = "<unknown>",
    this.selectorName = "",
    this.selectorIndex = 0
  });

  factory PathToPointModel.fromJson(Map<String, dynamic> json) => _$PathToPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$PathToPointModelToJson(this);

  @override
  String toString() {
    String ret = "Actor: $actorName ";

    if(pathType == PathToType.serverPath)
      ret += "ServerPathId: $serverPathId ";
    else if(pathType == PathToType.fixedPos)
      ret += "Pos $pos";
    else if(pathType == PathToType.selectorPos)
      ret += "Selector Pos $selectorName#$selectorIndex";
    else if(pathType == PathToType.selectorTarget)
      ret += "Selector Target $selectorName#$selectorIndex";
    else if(pathType == PathToType.target)
      ret += "Target";
    else if(pathType == PathToType.timelineActor)
      ret += "Timeline Actor: $targetActor";

    ret += " Navi:$useNavi";
    return ret;
  }
}

enum PathToType {
  @JsonValue("target")
  target,
  @JsonValue("selectorPos")
  selectorPos,
  @JsonValue("selectorTarget")
  selectorTarget,
  @JsonValue("fixedPos")
  fixedPos,
  @JsonValue("serverPath")
  serverPath,
  @JsonValue("timelineActor")
  timelineActor,
  @JsonValue("none")
  none
}