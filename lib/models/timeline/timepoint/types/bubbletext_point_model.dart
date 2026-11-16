import 'package:json_annotation/json_annotation.dart';

part 'bubbletext_point_model.g.dart';

@JsonSerializable()
class BubbleTextPointModel {
  String talkerActorName;
  int balloonId;

  @JsonKey(defaultValue: [0])
  List<int> params = [0];

  BubbleTextPointModel({this.talkerActorName  = "<unknown>", this.balloonId = 0});

  factory BubbleTextPointModel.fromJson(Map<String, dynamic> json) => _$BubbleTextPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$BubbleTextPointModelToJson(this);

  @override
  String toString() {
    return "Balloon ID#$balloonId params: $params";
  }
}