import 'package:json_annotation/json_annotation.dart';

part 'battletalk_point_model.g.dart';

@JsonSerializable()
class BattleTalkPointModel {
  String talkerActorName;
  int kind;
  int nameId;
  int battleTalkId;
  int length; 

  @JsonKey(defaultValue: [0])
  List<int> params = [0];

  BattleTalkPointModel({this.talkerActorName  = "<unknown>", this.kind = 0, this.nameId = 2961, this.battleTalkId = 2939, required this.params, this.length = 5000});

  factory BattleTalkPointModel.fromJson(Map<String, dynamic> json) => _$BattleTalkPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$BattleTalkPointModelToJson(this);

  @override
  String toString() {
    return "BattleTalk#$battleTalkId kind $kind with nameId#$nameId (talker actor $talkerActorName), for ${(length / 1000).toStringAsFixed(2)}s";
  }
}