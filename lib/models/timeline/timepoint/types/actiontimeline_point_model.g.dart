// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'actiontimeline_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActionTimelinePointModel _$ActionTimelinePointModelFromJson(
        Map<String, dynamic> json) =>
    ActionTimelinePointModel(
      actorName: json['actorName'] as String? ?? "<unknown>",
      actionTimelineId: (json['actionTimelineId'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ActionTimelinePointModelToJson(
        ActionTimelinePointModel instance) =>
    <String, dynamic>{
      'actorName': instance.actorName,
      'actionTimelineId': instance.actionTimelineId,
    };
