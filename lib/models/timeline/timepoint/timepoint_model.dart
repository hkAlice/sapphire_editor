import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/battletalk_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/bnpcflags_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/castaction_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/directorflags_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/directorseq_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/directorvar_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/idle_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/logmessage_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/setpos_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/setbgm_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/setcondition_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/spawnbnpc_point_model.dart';

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
    if(type != pointType) {
      data = <String, dynamic>{};
    }

    type = pointType;

    data ??= <String, dynamic>{};

    if(data is Map<String, dynamic>) {
      if(type == TimepointType.setPos) {
        data = SetPosPointModel.fromJson(data);
      } else if(type == TimepointType.idle) {
        data = IdlePointModel.fromJson(data);
      } else if(type == TimepointType.setBGM) {
        data = SetBgmPointModel.fromJson(data);
      } else if(type == TimepointType.logMessage) {
        data = LogMessagePointModel.fromJson(data);
      } else if(type == TimepointType.battleTalk) {
        data = BattleTalkPointModel.fromJson(data);
      } else if(type == TimepointType.spawnBNpc) {
        data = SpawnBNpcPointModel.fromJson(data);
      } else if(type == TimepointType.bNpcFlags) {
        data = BNpcFlagsPointModel.fromJson(data);
      } else if(type == TimepointType.castAction) {
        data = CastActionPointModel.fromJson(data);
      } else if(type == TimepointType.directorFlags) {
        data = DirectorFlagsPointModel.fromJson(data);
      } else if(type == TimepointType.directorSeq) {
        data = DirectorSeqPointModel.fromJson(data);
      } else if(type == TimepointType.directorVar) {
        data = DirectorVarPointModel.fromJson(data);
      } else if(type == TimepointType.setCondition) {
        data = SetConditionPointModel.fromJson(data);
      }
      else {
        throw UnimplementedError("Missing timepoint type cast for ${pointType.name}");
      }
    }
  }
  
  Color getColorForTimepointType() {
    switch(type) {
      case TimepointType.idle:
        return Colors.grey;
      case TimepointType.directorVar:
      case TimepointType.directorSeq:
      case TimepointType.directorFlags:
        return Colors.redAccent;
      case TimepointType.castAction:
        return Colors.orangeAccent;
      case TimepointType.setPos:
        return Colors.blueGrey;
      case TimepointType.setBGM:
      case TimepointType.logMessage:
      case TimepointType.battleTalk:
        return Colors.green;
      case TimepointType.bNpcFlags:
      case TimepointType.spawnBNpc:
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
  setPos,
  @JsonValue("directorFlags")
  directorFlags,
  @JsonValue("directorSeq")
  directorSeq,
  @JsonValue("directorVar")
  directorVar,
  @JsonValue("bNpcFlags")
  bNpcFlags,
  @JsonValue("spawnBNpc")
  spawnBNpc,
  @JsonValue("logMessage")
  logMessage,
  @JsonValue("battleTalk")
  battleTalk,
  @JsonValue("setBGM")
  setBGM,
  @JsonValue("setCondition")
  setCondition
}