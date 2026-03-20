import 'package:json_annotation/json_annotation.dart';

part 'phaseactive_condition_model.g.dart';

@JsonSerializable()
class PhaseActiveConditionModel {
  String sourceActor;
  int? phaseId;

  PhaseActiveConditionModel({
    this.sourceActor = "<unknown>",
    this.phaseId,
  });

  factory PhaseActiveConditionModel.fromJson(Map<String, dynamic> json) {
    final normalized = <String, dynamic>{...json};
    normalized['phaseId'] ??= normalized['scheduleName'];
    normalized['phaseId'] = _normalizePhaseId(normalized['phaseId']);
    return _$PhaseActiveConditionModelFromJson(normalized);
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

  Map<String, dynamic> toJson() => _$PhaseActiveConditionModelToJson(this);
}
