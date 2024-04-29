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
  battleTalk
}