
import 'package:json_annotation/json_annotation.dart';

part 'position3_model.g.dart';

@JsonSerializable()
class Position3 {
  double x = 0.0;
  double y = 0.0;
  double z = 0.0;
  
  Position3(this.x, this.y, this.z);

  factory Position3.fromJson(Map<String, dynamic> json) => _$Position3FromJson(json);

  Map<String, dynamic> toJson() => _$Position3ToJson(this);
}