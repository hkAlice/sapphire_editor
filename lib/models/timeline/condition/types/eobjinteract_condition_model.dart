import 'package:json_annotation/json_annotation.dart';

part 'eobjinteract_condition_model.g.dart';

@JsonSerializable()
class EObjInteractConditionModel {
  String eObjName;

  EObjInteractConditionModel({
    this.eObjName = "",
  });

  factory EObjInteractConditionModel.fromJson(Map<String, dynamic> json) =>
      _$EObjInteractConditionModelFromJson(json);

  Map<String, dynamic> toJson() => _$EObjInteractConditionModelToJson(this);
}
