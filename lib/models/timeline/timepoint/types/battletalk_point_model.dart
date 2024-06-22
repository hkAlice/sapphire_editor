import 'package:json_annotation/json_annotation.dart';

part 'battletalk_point_model.g.dart';

// TODO: change ids to actor str ref
@JsonSerializable()
class BattleTalkPointModel {
  String handlerActorName;
  String talkerActorName;
  int kind;
  int nameId;
  int battleTalkId;

  @JsonKey(defaultValue: [0])
  List<int> params = [0];

  BattleTalkPointModel({this.handlerActorName = "<unknown>", this.talkerActorName  = "<unknown>", this.kind = 0, this.nameId = 2961, this.battleTalkId = 2939, required this.params});

  factory BattleTalkPointModel.fromJson(Map<String, dynamic> json) => _$BattleTalkPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$BattleTalkPointModelToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}