import 'package:json_annotation/json_annotation.dart';

part 'snapshot_point_model.g.dart';

@JsonSerializable()
class SnapshotPointModel {
  String selector;
  String sourceActor;

  SnapshotPointModel({this.sourceActor = "<unknown>", this.selector = "<unknown>"});

  factory SnapshotPointModel.fromJson(Map<String, dynamic> json) => _$SnapshotPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$SnapshotPointModelToJson(this);
}