import 'package:json_annotation/json_annotation.dart';

part 'castaction_point_model.g.dart';

@JsonSerializable()
class CastActionModel {
  String targetActor;
  
  int actionId;

  CastActionModel({required this.targetActor, required this.actionId});

  factory CastActionModel.fromJson(Map<String, dynamic> json) => _$CastActionModelFromJson(json);

  Map<String, dynamic> toJson() => _$CastActionModelToJson(this);
}