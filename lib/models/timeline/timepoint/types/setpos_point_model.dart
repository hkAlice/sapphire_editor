import 'package:json_annotation/json_annotation.dart';

part 'setpos_point_model.g.dart';

@JsonSerializable()
class SetPosPointModel {
  @JsonKey(defaultValue: [0.0, 0.0, 0.0])
  List<double> pos = [0.0, 0.0, 0.0];
  double rot;
  String actorName;

  SetPosPointModel({required this.pos, this.rot = 0.0, this.actorName = "<unknown>"});

  factory SetPosPointModel.fromJson(Map<String, dynamic> json) => _$SetPosPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$SetPosPointModelToJson(this);
}