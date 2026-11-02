import 'package:json_annotation/json_annotation.dart';
import 'package:json_text_field/json_text_field.dart';

part 'mechanic_point_model.g.dart';

@JsonSerializable()
class MechanicPointModel {
  String instance;
  String function;
  Map<String, dynamic>? args;

  MechanicPointModel({this.instance = "", this.function = ""});

  factory MechanicPointModel.fromJson(Map<String, dynamic> json) => _$MechanicPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$MechanicPointModelToJson(this);

  @override
  String toString() {
    return "$instance | Func: $function | Args: $args";
  }
}