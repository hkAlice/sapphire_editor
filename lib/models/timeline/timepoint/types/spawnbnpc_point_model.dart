import 'package:json_annotation/json_annotation.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/bnpcflags_point_model.dart';

part 'spawnbnpc_point_model.g.dart';

@JsonSerializable()
class SpawnBNpcPointModel {
  String spawnActor;
  int flags;
  HateSourceModel? hateSource;

  SpawnBNpcPointModel({this.spawnActor = "<unknown>", this.flags = 0, this.hateSource}) {
    hateSource ??= HateSourceModel();
  }

  factory SpawnBNpcPointModel.fromJson(Map<String, dynamic> json) => _$SpawnBNpcPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$SpawnBNpcPointModelToJson(this);

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