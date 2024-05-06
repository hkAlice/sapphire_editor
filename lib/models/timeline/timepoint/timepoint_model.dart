import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/idle_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/moveto_point_model.dart';

part 'timepoint_model.g.dart';

@JsonSerializable(explicitToJson: true)
class TimepointModel {
  // todo: private field this + expose to json -> JsonKey(includeFromJson: true, includeToJson: true)
  TimepointType type;
  String description;

  int duration;

  dynamic data = {};

  TimepointModel({required this.type, this.description = "", this.duration = 5000, this.data}) {
    changeType(type);
  }

  factory TimepointModel.fromJson(Map<String, dynamic> json) => _$TimepointModelFromJson(json);

  Map<String, dynamic> toJson() => _$TimepointModelToJson(this);

  // todo: ugliest fucking thing ever. this sucks to do with json serializable + no setter
  void changeType(TimepointType pointType) {
    type = pointType;

    // holy hell
    if(data is Map<String, dynamic>) {
      switch(type) {
        case TimepointType.moveTo: {
          data = MoveToPointModel.fromJson(data);
        }
        default: {
          data = IdlePointModel.fromJson(data);
        }
      }
    }
    else {
      switch(type) {
        case TimepointType.moveTo: {
          data = MoveToPointModel();
        }
        default: {
          data = IdlePointModel();
        }
      }
    }
  }
  
  Color getColorForTimepointType() {
    switch(type) {
      case TimepointType.idle:
        return Colors.grey;
      case TimepointType.directorVar:
        return Colors.redAccent;
      case TimepointType.castAction:
        return Colors.orangeAccent;
      case TimepointType.moveTo:
        return Colors.blueGrey;
      case TimepointType.actorFlags:
        return Colors.deepPurpleAccent;
      case TimepointType.setCondition:
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
  @JsonValue("directorVar")
  directorVar,
  @JsonValue("actorFlags")
  actorFlags,
  @JsonValue("logMessage")
  logMessage,
  @JsonValue("battleTalk")
  battleTalk,
  @JsonValue("setCondition")
  setCondition
}