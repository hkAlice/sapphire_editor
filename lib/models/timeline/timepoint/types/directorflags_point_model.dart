import 'package:json_annotation/json_annotation.dart';

part 'directorflags_point_model.g.dart';

@JsonSerializable()
class DirectorFlagsPointModel {
  String opc;

  int val;

  DirectorFlagsPointModel({required this.opc, required this.val});

  factory DirectorFlagsPointModel.fromJson(Map<String, dynamic> json) => _$DirectorFlagsPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$DirectorFlagsPointModelToJson(this);
}