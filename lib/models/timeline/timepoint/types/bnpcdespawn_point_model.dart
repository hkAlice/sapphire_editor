import 'package:json_annotation/json_annotation.dart';

part 'bnpcdespawn_point_model.g.dart';

@JsonSerializable()
class BNpcDespawnPointModel {
  String despawnActor;

  BNpcDespawnPointModel({this.despawnActor = "<unknown>"});

  factory BNpcDespawnPointModel.fromJson(Map<String, dynamic> json) => _$BNpcDespawnPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$BNpcDespawnPointModelToJson(this);

  @override
  String toString() {
    return "Despawn $despawnActor";
  }
}