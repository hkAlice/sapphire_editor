import 'package:json_annotation/json_annotation.dart';

part 'selector_filter_model.g.dart';

@JsonSerializable()
class SelectorFilterModel {
  SelectorFilterType type;
  dynamic data = {};

  SelectorFilterModel({
    this.type = SelectorFilterType.player,
    this.data,
  });

  factory SelectorFilterModel.fromJson(Map<String, dynamic> json) => _$SelectorFilterModelFromJson(json);

  Map<String, dynamic> toJson() => _$SelectorFilterModelToJson(this);
}

enum SelectorFilterType {
  @JsonValue("Player")
  player, // idx  = val
  @JsonValue("Furthest")
  furthest, // idx += val
  @JsonValue("Role")
  role,
  @JsonValue("NotAggro")
  notAggro
}