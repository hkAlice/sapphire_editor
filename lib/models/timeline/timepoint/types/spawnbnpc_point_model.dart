import 'package:json_annotation/json_annotation.dart';

part 'spawnbnpc_point_model.g.dart';

@JsonSerializable()
class SpawnBNpcPointModel {
  String targetActor;
  
  int flags;

  HateSourceModel hateSource;

  SpawnBNpcPointModel({required this.targetActor, required this.flags, required this.hateSource});

  factory SpawnBNpcPointModel.fromJson(Map<String, dynamic> json) => _$SpawnBNpcPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$SpawnBNpcPointModelToJson(this);
}

@JsonSerializable()
class HateSourceModel {
  String hateType;
  
  String source;

  HateSourceModel({required this.hateType, required this.source});

  factory HateSourceModel.fromJson(Map<String, dynamic> json) => _$HateSourceModelFromJson(json);

  Map<String, dynamic> toJson() => _$HateSourceModelToJson(this);
}