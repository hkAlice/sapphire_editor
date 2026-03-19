// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_schedule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimelineScheduleModel _$TimelineScheduleModelFromJson(
        Map<String, dynamic> json) =>
    TimelineScheduleModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String? ?? "",
      loopType: $enumDecodeNullable(
              _$TimelineScheduleLoopTypeEnumMap, json['loopType']) ??
          TimelineScheduleLoopType.none,
      loopCount: (json['loopCount'] as num?)?.toInt() ?? 1,
    )..timepoints = (json['timepoints'] as List<dynamic>)
        .map((e) => TimepointModel.fromJson(e as Map<String, dynamic>))
        .toList();

Map<String, dynamic> _$TimelineScheduleModelToJson(
        TimelineScheduleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'loopType': _$TimelineScheduleLoopTypeEnumMap[instance.loopType]!,
      'loopCount': instance.loopCount,
      'timepoints': instance.timepoints.map((e) => e.toJson()).toList(),
    };

const _$TimelineScheduleLoopTypeEnumMap = {
  TimelineScheduleLoopType.none: 'none',
  TimelineScheduleLoopType.infinite: 'infinite',
  TimelineScheduleLoopType.finite: 'finite',
};
