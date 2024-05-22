import 'package:json_annotation/json_annotation.dart';

part 'battletalk_point_model.g.dart';

// TODO: change ids to actor str ref
@JsonSerializable()
class BattleTalkPointModel {
  int handlerId;
  int talkerId;
  int kind;
  int nameId;
  int battleTalkId;

  @JsonKey(defaultValue: [0])
  List<int> params;

  BattleTalkPointModel({required this.handlerId, required this.talkerId, required this.kind, required this.nameId, required this.battleTalkId, required this.params});

  factory BattleTalkPointModel.fromJson(Map<String, dynamic> json) => _$BattleTalkPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$BattleTalkPointModelToJson(this);
}