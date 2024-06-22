import 'package:json_annotation/json_annotation.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/directorvar_point_model.dart';

part 'directorflags_point_model.g.dart';

@JsonSerializable()
class DirectorFlagsPointModel {
  DirectorOpcode opc;

  int val;

  DirectorFlagsPointModel({this.opc = DirectorOpcode.set, this.val = 1});

  factory DirectorFlagsPointModel.fromJson(Map<String, dynamic> json) => _$DirectorFlagsPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$DirectorFlagsPointModelToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}