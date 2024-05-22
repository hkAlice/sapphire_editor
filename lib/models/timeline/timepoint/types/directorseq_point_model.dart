import 'package:json_annotation/json_annotation.dart';

part 'directorseq_point_model.g.dart';

@JsonSerializable()
class DirectorSeqPointModel {
  String opc;

  int val;

  DirectorSeqPointModel({required this.opc, required this.val});

  factory DirectorSeqPointModel.fromJson(Map<String, dynamic> json) => _$DirectorSeqPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$DirectorSeqPointModelToJson(this);
}