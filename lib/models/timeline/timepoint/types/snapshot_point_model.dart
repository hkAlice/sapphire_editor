import 'package:json_annotation/json_annotation.dart';

part 'snapshot_point_model.g.dart';

@JsonSerializable()
class SnapshotPointModel {
  String selectorName;
  String sourceActor;

  SnapshotPointModel({this.sourceActor = "<unknown>", this.selectorName = "<unknown>"});

  factory SnapshotPointModel.fromJson(Map<String, dynamic> json) => _$SnapshotPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$SnapshotPointModelToJson(this);
}