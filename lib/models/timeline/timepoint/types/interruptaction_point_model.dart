import 'package:json_annotation/json_annotation.dart';

part 'interruptaction_point_model.g.dart';

@JsonSerializable()
class InterruptActionPointModel {
  String sourceActor;

  int actionId;

  InterruptActionPointModel({this.sourceActor = "<unknown>", this.actionId = 0});

  factory InterruptActionPointModel.fromJson(Map<String, dynamic> json) => _$InterruptActionPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$InterruptActionPointModelToJson(this);

  @override
  String toString() {
    return "Interrupt Action $actionId on $sourceActor";
  }
}