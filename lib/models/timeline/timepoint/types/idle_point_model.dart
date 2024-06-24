import 'package:json_annotation/json_annotation.dart';

part 'idle_point_model.g.dart';

@JsonSerializable()
class IdlePointModel {
  IdlePointModel();

  factory IdlePointModel.fromJson(Map<String, dynamic> json) => _$IdlePointModelFromJson(json);

  Map<String, dynamic> toJson() => _$IdlePointModelToJson(this);

  @override
  String toString() {
    return "💤";
  }
}