import 'package:json_annotation/json_annotation.dart';

part 'actiontimeline_point_model.g.dart';

@JsonSerializable()
class ActionTimelinePointModel {
  String actorName;

  int actionTimelineId;

  ActionTimelinePointModel({this.actorName = "<unknown>", this.actionTimelineId = 0});

  factory ActionTimelinePointModel.fromJson(Map<String, dynamic> json) => _$ActionTimelinePointModelFromJson(json);

  Map<String, dynamic> toJson() => _$ActionTimelinePointModelToJson(this);

  @override
  String toString() {
    return "Play ActionTimeline $actionTimelineId on $actorName";
  }
}