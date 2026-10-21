import 'dart:ffi';

import 'package:json_annotation/json_annotation.dart';

part 'seteobjstate_point_model.g.dart';

@JsonSerializable()
class SetEObjStatePointModel {
  String eobjName;
  int state;
  int animation;
  int permissionInvisibility;

  SetEObjStatePointModel({this.eobjName = "", this.state = 0, this.animation = 0, this.permissionInvisibility = 0 });

  factory SetEObjStatePointModel.fromJson(Map<String, dynamic> json) => _$SetEObjStatePointModelFromJson(json);

  Map<String, dynamic> toJson() => _$SetEObjStatePointModelToJson(this);

  @override
  String toString() {
    return "$eobjName | State: $state | Anim: $animation | Invisibility: $permissionInvisibility";
  }
}