import 'package:json_annotation/json_annotation.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/bnpcflags_point_model.dart';

part 'bnpcspawn_point_model.g.dart';

@JsonSerializable()
class BNpcSpawnPointModel {
  String spawnActor;
  int flags;
  HateSourceModel? hateSource;

  BNpcSpawnPointModel({this.spawnActor = "<unknown>", this.flags = 0, this.hateSource}) {
    hateSource ??= HateSourceModel();
  }

  factory BNpcSpawnPointModel.fromJson(Map<String, dynamic> json) => _$BNpcSpawnPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$BNpcSpawnPointModelToJson(this);

  @override
  String toString() {
    return "Spawn $spawnActor (flags: ${BNpcFlags.flagsStr(flags)})";
  }
}

@JsonSerializable()
class HateSourceModel {
  String hateType;
  String source;

  HateSourceModel({this.hateType = "<to-be-defined>", this.source = "<to-de-befined>"});

  factory HateSourceModel.fromJson(Map<String, dynamic> json) => _$HateSourceModelFromJson(json);

  Map<String, dynamic> toJson() => _$HateSourceModelToJson(this);
}