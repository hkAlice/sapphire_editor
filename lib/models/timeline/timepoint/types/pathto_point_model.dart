import 'package:json_annotation/json_annotation.dart';

part 'pathto_point_model.g.dart';

@JsonSerializable()
class PathToPointModel {
  @JsonKey(defaultValue: [0.0, 0.0, 0.0])
  List<double> pos = [0.0, 0.0, 0.0];
  String actorName;
  bool useNavi = true;

  PathToPointModel({
    required this.pos,
    this.actorName = "<unknown>",
    this.useNavi = true
  });

  factory PathToPointModel.fromJson(Map<String, dynamic> json) => _$PathToPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$PathToPointModelToJson(this);

  @override
  String toString() {
    return "Actor: $actorName Pos: $pos Navi: $useNavi";
  }
}