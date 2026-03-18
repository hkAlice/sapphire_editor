import 'package:json_annotation/json_annotation.dart';

part 'trigger_action_model.g.dart';

@JsonSerializable()
class TriggerActionModel {
  String type;
  String target;

  TriggerActionModel({
    required this.type,
    required this.target,
  });

  factory TriggerActionModel.fromJson(Map<String, dynamic> json) =>
      _$TriggerActionModelFromJson(json);

  Map<String, dynamic> toJson() => _$TriggerActionModelToJson(this);

  TriggerActionModel copyWith({
    String? type,
    String? target,
  }) {
    return TriggerActionModel(
      type: type ?? this.type,
      target: target ?? this.target,
    );
  }
}
