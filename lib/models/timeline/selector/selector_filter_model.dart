import 'package:json_annotation/json_annotation.dart';

part 'selector_filter_model.g.dart';

@JsonSerializable()
class SelectorFilterModel {
  SelectorFilterType type;
  bool negate;
  bool enforceOnRandom;
  dynamic param;

  SelectorFilterModel({
    this.type = SelectorFilterType.player,
    this.negate = false,
    this.enforceOnRandom = false,
    this.param,
  });

  factory SelectorFilterModel.fromJson(Map<String, dynamic> json) => _$SelectorFilterModelFromJson(json);

  Map<String, dynamic> toJson() => _$SelectorFilterModelToJson(this);

  SelectorFilterModel copyWith({
    SelectorFilterType? type,
    bool? negate,
    bool? enforceOnRandom,
    dynamic param,
  }) {
    return SelectorFilterModel(
      type: type ?? this.type,
      negate: negate ?? this.negate,
      enforceOnRandom: enforceOnRandom ?? this.enforceOnRandom,
      param: param ?? this.param,
    );
  }
}

enum SelectorFilterType {
  @JsonValue("insideRadius")
  insideRadius,
  @JsonValue("outsideRadius")
  outsideRadius,

  @JsonValue("player")
  player,
  @JsonValue("ally")
  ally,
  @JsonValue("ownBattalion")
  ownBattalion,

  @JsonValue("tank")
  tank,
  @JsonValue("healer")
  healer,
  @JsonValue("dps")
  dps,
  @JsonValue("rangedDps")
  rangedDps,

  @JsonValue("hasStatusEffect")
  hasStatusEffect,

  @JsonValue("topAggro")
  topAggro,
  @JsonValue("secondAggro")
  secondAggro,

  @JsonValue("allianceA")
  allianceA,
  @JsonValue("allianceB")
  allianceB,
  @JsonValue("allianceC")
  allianceC
}