import 'package:json_annotation/json_annotation.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';

part 'trigger_action_model.g.dart';

@JsonSerializable(explicitToJson: true)
class TriggerActionModel {
  String type;
  int? phaseId;
  TimepointModel? timepoint;

  TriggerActionModel({
    required this.type,
    this.phaseId,
    this.timepoint,
  });

  factory TriggerActionModel.fromJson(Map<String, dynamic> json) {
    final normalized = <String, dynamic>{...json};
    normalized['phaseId'] ??= normalized['target'];
    normalized['phaseId'] = _normalizePhaseId(normalized['phaseId']);
    return _$TriggerActionModelFromJson(normalized);
  }

  static int? _normalizePhaseId(dynamic value) {
    if(value == null) {
      return null;
    }

    if(value is int) {
      return value;
    }

    if(value is num) {
      return value.toInt();
    }

    if(value is String) {
      final normalized = value.trim();
      if(normalized.isEmpty) {
        return null;
      }

      final parsed = int.tryParse(normalized);
      if(parsed != null) {
        return parsed;
      }

      final match = RegExp(r'(\d+)$').firstMatch(normalized);
      return match == null ? null : int.tryParse(match.group(1)!);
    }

    return null;
  }

  Map<String, dynamic> toJson() => _$TriggerActionModelToJson(this);

  TriggerActionModel copyWith({
    String? type,
    int? phaseId,
    TimepointModel? timepoint,
  }) {
    return TriggerActionModel(
      type: type ?? this.type,
      phaseId: phaseId ?? this.phaseId,
      timepoint: timepoint ?? this.timepoint,
    );
  }
}
