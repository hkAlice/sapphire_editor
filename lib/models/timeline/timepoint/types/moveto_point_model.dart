import 'package:json_annotation/json_annotation.dart';
import 'package:sapphire_editor/models/timeline/position3_model.dart';

part 'moveto_point_model.g.dart';

@JsonSerializable()
class MoveToPointModel {
  Position3 pos;
  double rot;
  bool pathRequest; // todo: probably PathingType enum?

  MoveToPointModel({position, this.rot = 0.0, this.pathRequest = true}) : pos = position ?? Position3(0.0, 0.0, 0.0);

  factory MoveToPointModel.fromJson(Map<String, dynamic> json) => _$MoveToPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$MoveToPointModelToJson(this);
}