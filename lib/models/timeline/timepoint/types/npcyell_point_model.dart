import 'package:json_annotation/json_annotation.dart';

part 'npcyell_point_model.g.dart';

@JsonSerializable()
class NpcYellPointModel {
  String talkerActorName;
  int npcYellId;

  @JsonKey(defaultValue: [0])
  List<int> params = [0];

  NpcYellPointModel({this.talkerActorName  = "<unknown>", this.npcYellId = 0});

  factory NpcYellPointModel.fromJson(Map<String, dynamic> json) => _$NpcYellPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$NpcYellPointModelToJson(this);

  @override
  String toString() {
    return "NpcYell ID#$npcYellId Actor: $talkerActorName params: $params";
  }
}