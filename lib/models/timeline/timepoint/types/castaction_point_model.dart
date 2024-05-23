import 'package:json_annotation/json_annotation.dart';

part 'castaction_point_model.g.dart';

@JsonSerializable()
class CastActionPointModel {
  String sourceActor;
  int actionId;

  CastActionPointModel({this.sourceActor = "<unknown>", this.actionId = 6116});

  factory CastActionPointModel.fromJson(Map<String, dynamic> json) => _$CastActionPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$CastActionPointModelToJson(this);
}