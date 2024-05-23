import 'package:json_annotation/json_annotation.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/directorvar_point_model.dart';

part 'directorseq_point_model.g.dart';

@JsonSerializable()
class DirectorSeqPointModel {
  DirectorOpcode opc;

  int val;

  DirectorSeqPointModel({this.opc = DirectorOpcode.set, this.val = 1});

  factory DirectorSeqPointModel.fromJson(Map<String, dynamic> json) => _$DirectorSeqPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$DirectorSeqPointModelToJson(this);
}