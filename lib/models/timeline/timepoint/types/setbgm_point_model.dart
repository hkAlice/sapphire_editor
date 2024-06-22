import 'package:json_annotation/json_annotation.dart';

part 'setbgm_point_model.g.dart';

@JsonSerializable()
class SetBgmPointModel {
  int bgmId;

  SetBgmPointModel({this.bgmId = 163});

  factory SetBgmPointModel.fromJson(Map<String, dynamic> json) => _$SetBgmPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$SetBgmPointModelToJson(this);

  @override
  String toString() {
    return "BGM#$bgmId";
  }
}