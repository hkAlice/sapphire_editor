import 'package:json_annotation/json_annotation.dart';

part 'bnpcflags_point_model.g.dart';

@JsonSerializable()
class BNpcFlagsPointModel {
  String targetActor;

  int flags;

  BNpcFlagsPointModel({required this.targetActor, required this.flags});

  factory BNpcFlagsPointModel.fromJson(Map<String, dynamic> json) => _$BNpcFlagsPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$BNpcFlagsPointModelToJson(this);
}