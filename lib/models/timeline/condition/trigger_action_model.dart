import 'package:json_annotation/json_annotation.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';

part 'trigger_action_model.g.dart';

@JsonSerializable(explicitToJson: true)
class TriggerActionModel {
  String type;
  String? phaseId;
  TimepointModel? timepoint;

  TriggerActionModel({
    required this.type,
    this.phaseId,
    this.timepoint,
  });

  factory TriggerActionModel.fromJson(Map<String, dynamic> json) {
    final normalized = <String, dynamic>{...json};
    normalized['phaseId'] ??= normalized['target'];
    return _$TriggerActionModelFromJson(normalized);
  }

  Map<String, dynamic> toJson() => _$TriggerActionModelToJson(this);

  TriggerActionModel copyWith({
    String? type,
    String? phaseId,
    TimepointModel? timepoint,
  }) {
    return TriggerActionModel(
      type: type ?? this.type,
      phaseId: phaseId ?? this.phaseId,
      timepoint: timepoint ?? this.timepoint,
    );
  }
}
