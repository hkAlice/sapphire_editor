import 'package:json_annotation/json_annotation.dart';

part 'rollrng_point_model.g.dart';

@JsonSerializable()
class RollRNGPointModel {
  int min;
  int max;

  RollRNGPointModel({ this.min = 0, this.max = 2 });

  factory RollRNGPointModel.fromJson(Map<String, dynamic> json) => _$RollRNGPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$RollRNGPointModelToJson(this);

  @override
  String toString() {
    return "Roll RNG ($min, $max)";
  }
}