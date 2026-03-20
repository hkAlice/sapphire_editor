import 'package:json_annotation/json_annotation.dart';
import 'package:sapphire_editor/models/timeline/condition/trigger_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_schedule_model.dart';

part 'timeline_phase_model.g.dart';

@JsonSerializable(explicitToJson: true)
class TimelinePhaseModel {
  int id;
  String name;

  List<TimepointModel> onEnter;
  List<TimepointModel> onExit;
  List<TimelineScheduleModel> schedules;
  List<TriggerModel> triggers;

  TimelinePhaseModel({
    required this.id,
    required this.name,
    List<TimepointModel>? onEnter,
    List<TimepointModel>? onExit,
    List<TimelineScheduleModel>? schedules,
    List<TriggerModel>? triggers,
  })  : onEnter = onEnter ?? [],
        onExit = onExit ?? [],
        schedules = schedules ?? [],
        triggers = triggers ?? [];

  factory TimelinePhaseModel.fromJson(Map<String, dynamic> json) {
    // todo: remove this and _normalizePhaseId in a few weeks when we are sure all timelines have been migrated to the new format
    final normalized = <String, dynamic>{...json};
    normalized['id'] = _normalizePhaseId(normalized['id']);
    return _$TimelinePhaseModelFromJson(normalized);
  }

  static int _normalizePhaseId(dynamic value) {
    if(value is int) {
      return value;
    }

    if(value is num) {
      return value.toInt();
    }

    if(value is String) {
      final normalized = value.trim();
      if(normalized.isEmpty) {
        return 0;
      }

      final parsed = int.tryParse(normalized);
      if(parsed != null) {
        return parsed;
      }

      final match = RegExp(r'(\d+)$').firstMatch(normalized);
      final suffix = match == null ? null : int.tryParse(match.group(1)!);
      if(suffix != null) {
        return suffix;
      }
    }

    return 0;
  }

  Map<String, dynamic> toJson() => _$TimelinePhaseModelToJson(this);

  TimelinePhaseModel copyWith({
    int? id,
    String? name,
    List<TimepointModel>? onEnter,
    List<TimepointModel>? onExit,
    List<TimelineScheduleModel>? schedules,
    List<TriggerModel>? triggers,
  }) {
    return TimelinePhaseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      onEnter: onEnter ?? this.onEnter,
      onExit: onExit ?? this.onExit,
      schedules: schedules ?? this.schedules,
      triggers: triggers ?? this.triggers,
    );
  }
}
