import 'package:json_annotation/json_annotation.dart';

part 'transitionphase_point_model.g.dart';

@JsonSerializable()
class TransitionPhasePointModel {
  int phaseId;

  TransitionPhasePointModel({this.phaseId = 1});

  factory TransitionPhasePointModel.fromJson(Map<String, dynamic> json) => _$TransitionPhasePointModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransitionPhasePointModelToJson(this);

  @override
  String toString() {
    return "Transition Phase to #$phaseId";
  }
}
