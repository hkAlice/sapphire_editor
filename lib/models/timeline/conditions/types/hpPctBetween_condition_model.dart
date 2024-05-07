import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'hpPctBetween_condition_model.g.dart';

@JsonSerializable()
class HPPctBetweenConditionModel {
  String? sourceActor;
  int? hpMin;
  int? hpMax;

  HPPctBetweenConditionModel({
    this.sourceActor = "<unknown>",
    this.hpMin = 25,
    this.hpMax = 50
  });

  factory HPPctBetweenConditionModel.fromJson(Map<String, dynamic> json) => _$HPPctBetweenConditionModelFromJson(json);

  Map<String, dynamic> toJson() => _$HPPctBetweenConditionModelToJson(this);
}