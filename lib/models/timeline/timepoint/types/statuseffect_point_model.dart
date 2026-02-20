import 'package:json_annotation/json_annotation.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/castaction_point_model.dart';
import 'package:sapphire_editor/utils/text_utils.dart';

part 'statuseffect_point_model.g.dart';

@JsonSerializable()
class StatusEffectPointModel {
  ActorTargetType targetType;
  String selectorName;
  int selectorIndex;
  String sourceActor;
  int statusId;
  bool isRemove; // true to remove, false to add
  int duration; // milliseconds

  StatusEffectPointModel(
      {this.targetType = ActorTargetType.self,
      this.selectorName = "<unset>",
      this.selectorIndex = 0,
      this.sourceActor = "<unknown>",
      this.statusId = 0,
      this.isRemove = false,
      this.duration = 0});

  factory StatusEffectPointModel.fromJson(Map<String, dynamic> json) =>
      _$StatusEffectPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$StatusEffectPointModelToJson(this);

  @override
  String toString() {
    var sum = isRemove
        ? "Remove Status $statusId"
        : "Add Status $statusId ($duration ms)";

    sum += " to ${treatEnumName(targetType)}";

    if(targetType == ActorTargetType.selectorTarget ||
        targetType == ActorTargetType.selectorPos) {
      sum += " $selectorName#${selectorIndex + 1}";
    }

    return sum;
  }
}
