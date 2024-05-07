import 'package:json_annotation/json_annotation.dart';

part 'moveto_point_model.g.dart';

@JsonSerializable()
class MoveToPointModel {
  @JsonKey(defaultValue: [0.0, 0.0, 0.0])
  List<double> pos = [0.0, 0.0, 0.0];
  double rot;
  bool pathRequest; // todo: probably PathingType enum?

  MoveToPointModel({required this.pos, this.rot = 0.0, this.pathRequest = true});

  factory MoveToPointModel.fromJson(Map<String, dynamic> json) => _$MoveToPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$MoveToPointModelToJson(this);
}