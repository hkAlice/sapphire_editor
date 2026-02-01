import 'package:json_annotation/json_annotation.dart';
import 'package:sapphire_editor/utils/text_utils.dart';

part 'rollrng_point_model.g.dart';

@JsonSerializable()
class RollRNGPointModel {
  int min;
  int max;
  RNGVarType type;
  int index;

  RollRNGPointModel({ this.min = 0, this.max = 2, this.type = RNGVarType.director, this.index = 0 });

  factory RollRNGPointModel.fromJson(Map<String, dynamic> json) => _$RollRNGPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$RollRNGPointModelToJson(this);

  @override
  String toString() {
    return "Roll RNG ($min, $max) to ${treatEnumName(type)} var Index $index";
  }
}

enum RNGVarType {
  @JsonValue("director")
  director,
  @JsonValue("custom")
  custom,
  @JsonValue("pack")
  pack
}