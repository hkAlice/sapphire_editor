import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/actiontimeline_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/battletalk_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/bnpcdespawn_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/bnpcflags_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/castaction_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/directorflags_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/directorseq_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/directorvar_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/idle_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/interruptaction_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/logmessage_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/rollrng_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/setpos_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/setbgm_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/setcondition_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/snapshot_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/bnpcspawn_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/statuseffect_point_model.dart';

part 'timepoint_model.g.dart';

@JsonSerializable(explicitToJson: true)
class TimepointModel {
  @JsonKey(defaultValue: -1)
  int id;
  TimepointType type;
  String description;

  int startTime;

  dynamic data = {};

  TimepointModel(
      {required this.id,
      required this.type,
      this.description = "",
      this.startTime = 0,
      this.data}) {
    changeType(type);
  }

  factory TimepointModel.fromJson(Map<String, dynamic> json) =>
      _$TimepointModelFromJson(json);

  Map<String, dynamic> toJson() => _$TimepointModelToJson(this);

  TimepointModel copyWith({
    int? id,
    TimepointType? type,
    String? description,
    int? startTime,
    dynamic data,
  }) {
    final newTimepoint = TimepointModel(
      id: id ?? this.id,
      type: type ?? this.type,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      data: data ?? this.data,
    );

    if(type != null && type != this.type) {
      newTimepoint.changeType(type);
    } else {
      newTimepoint.data = data ?? this.data;
    }

    return newTimepoint;
  }

  // Simplified changeType using a factory map instead of giant if-else
  void changeType(TimepointType pointType) {
    if(type != pointType) {
      data = <String, dynamic>{};
    }

    type = pointType;

    data ??= <String, dynamic>{};

    if(data is Map<String, dynamic>) {
      data = _timepointDataFactory(pointType, data);
    }
  }

  static dynamic _timepointDataFactory(
      TimepointType type, Map<String, dynamic> json) {
    return switch (type) {
      TimepointType.setPos => SetPosPointModel.fromJson(json),
      TimepointType.idle => IdlePointModel.fromJson(json),
      TimepointType.setBGM => SetBgmPointModel.fromJson(json),
      TimepointType.logMessage => LogMessagePointModel.fromJson(json),
      TimepointType.battleTalk => BattleTalkPointModel.fromJson(json),
      TimepointType.bNpcDespawn => BNpcDespawnPointModel.fromJson(json),
      TimepointType.bNpcFlags => BNpcFlagsPointModel.fromJson(json),
      TimepointType.bNpcSpawn => BNpcSpawnPointModel.fromJson(json),
      TimepointType.castAction => CastActionPointModel.fromJson(json),
      TimepointType.directorFlags => DirectorFlagsPointModel.fromJson(json),
      TimepointType.directorSeq => DirectorSeqPointModel.fromJson(json),
      TimepointType.directorVar => DirectorVarPointModel.fromJson(json),
      TimepointType.setCondition => SetConditionPointModel.fromJson(json),
      TimepointType.snapshot => SnapshotPointModel.fromJson(json),
      TimepointType.actionTimeline => ActionTimelinePointModel.fromJson(json),
      TimepointType.interruptAction => InterruptActionPointModel.fromJson(json),
      TimepointType.rollRNG => RollRNGPointModel.fromJson(json),
      TimepointType.statusEffect => StatusEffectPointModel.fromJson(json),
    };
  }

  // Color getter using extension method
  Color get color => type.color;

  // Display name getter using extension method
  String get displayName => type.displayName;

  // Keep old method name for backwards compatibility with widgets
  Color getColorForTimepointType() => type.color;
}

// Extension methods for type metadata - keeps enums but adds rich behavior
extension TimepointTypeExtension on TimepointType {
  Color get color {
    switch (this) {
      case TimepointType.idle:
        return Colors.grey;
      case TimepointType.directorVar:
      case TimepointType.directorSeq:
      case TimepointType.directorFlags:
        return Colors.redAccent;
      case TimepointType.castAction:
      case TimepointType.actionTimeline:
        return Colors.orangeAccent;
      case TimepointType.setPos:
        return Colors.blueGrey;
      case TimepointType.setBGM:
      case TimepointType.logMessage:
      case TimepointType.battleTalk:
        return Colors.green;
      case TimepointType.bNpcDespawn:
      case TimepointType.bNpcFlags:
      case TimepointType.bNpcSpawn:
        return Colors.deepPurpleAccent;
      case TimepointType.snapshot:
      case TimepointType.setCondition:
        return Colors.brown;
      case TimepointType.interruptAction:
      case TimepointType.rollRNG:
        return Colors.orangeAccent;
      case TimepointType.statusEffect:
        return Colors.purpleAccent;
    }
  }

  String get displayName {
    switch (this) {
      case TimepointType.actionTimeline:
        return "Action Timeline";
      case TimepointType.battleTalk:
        return "Battle Talk";
      case TimepointType.bNpcDespawn:
        return "BNPC Despawn";
      case TimepointType.bNpcFlags:
        return "BNPC Flags";
      case TimepointType.bNpcSpawn:
        return "BNPC Spawn";
      case TimepointType.castAction:
        return "Cast Action";
      case TimepointType.directorFlags:
        return "Director Flags";
      case TimepointType.directorSeq:
        return "Director Seq";
      case TimepointType.directorVar:
        return "Director Var";
      case TimepointType.idle:
        return "Idle";
      case TimepointType.logMessage:
        return "Log Message";
      case TimepointType.setBGM:
        return "Set BGM";
      case TimepointType.setCondition:
        return "Set Condition";
      case TimepointType.setPos:
        return "Set Position";
      case TimepointType.snapshot:
        return "Snapshot";
      case TimepointType.interruptAction:
        return "Interrupt Action";
      case TimepointType.rollRNG:
        return "Roll RNG";
      case TimepointType.statusEffect:
        return "Status Effect";
    }
  }
}

enum TimepointType {
  @JsonValue("actionTimeline")
  actionTimeline,
  @JsonValue("battleTalk")
  battleTalk,
  @JsonValue("bNpcDespawn")
  bNpcDespawn,
  @JsonValue("bNpcFlags")
  bNpcFlags,
  @JsonValue("bNpcSpawn")
  bNpcSpawn,
  @JsonValue("castAction")
  castAction,
  @JsonValue("directorFlags")
  directorFlags,
  @JsonValue("directorSeq")
  directorSeq,
  @JsonValue("directorVar")
  directorVar,
  @JsonValue("idle")
  idle,
  @JsonValue("interruptAction")
  interruptAction,
  @JsonValue("logMessage")
  logMessage,
  @JsonValue("rollRNG")
  rollRNG,
  @JsonValue("setBGM")
  setBGM,
  @JsonValue("setCondition")
  setCondition,
  @JsonValue("setPos")
  setPos,
  @JsonValue("snapshot")
  snapshot,
  @JsonValue("statusEffect")
  statusEffect
}
