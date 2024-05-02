import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'timepoint_model.g.dart';

@JsonSerializable()
class TimepointModel {
  TimepointType type;
  String description;

  dynamic data;

  TimepointModel({required this.type, this.description = "", this.data});

  factory TimepointModel.fromJson(Map<String, dynamic> json) => _$TimepointModelFromJson(json);

  Map<String, dynamic> toJson() => _$TimepointModelToJson(this);
  
  Color getColorForTimepointType() {
  switch(type) {
    case TimepointType.idle:
      return Colors.grey;
    case TimepointType.setDirectorVar:
      return Colors.redAccent;
    case TimepointType.castAction:
      return Colors.orangeAccent;
    case TimepointType.moveTo:
      return Colors.blueGrey;
    case TimepointType.setActorFlags:
      return Colors.deepPurpleAccent;
    case TimepointType.switchCondition:
      return Colors.brown;
    default:
      return Colors.greenAccent;
    }
  }
}

enum TimepointType {
  @JsonValue("idle")
  idle,
  @JsonValue("castAction")
  castAction,
  @JsonValue("moveTo")
  moveTo,
  @JsonValue("setDirectorVar")
  setDirectorVar,
  @JsonValue("setActorFlags")
  setActorFlags,
  @JsonValue("logMessage")
  logMessage,
  @JsonValue("battleTalk")
  battleTalk,
  @JsonValue("switchCondition")
  switchCondition
}