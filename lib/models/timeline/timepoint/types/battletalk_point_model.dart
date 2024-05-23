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
  List<int> params = [0];

  BattleTalkPointModel({this.handlerId = 0, this.talkerId = 0, this.kind = 0, this.nameId = 1, this.battleTalkId = 2939, required this.params});

  factory BattleTalkPointModel.fromJson(Map<String, dynamic> json) => _$BattleTalkPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$BattleTalkPointModelToJson(this);
}