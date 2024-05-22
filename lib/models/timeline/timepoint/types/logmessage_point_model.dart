import 'package:json_annotation/json_annotation.dart';

part 'logmessage_point_model.g.dart';

@JsonSerializable()
class LogMessagePointModel {
  int messageId;

  @JsonKey(defaultValue: [0])
  List<int> params;

  LogMessagePointModel({required this.messageId, required this.params});

  factory LogMessagePointModel.fromJson(Map<String, dynamic> json) => _$LogMessagePointModelFromJson(json);

  Map<String, dynamic> toJson() => _$LogMessagePointModelToJson(this);
}