// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interruptaction_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InterruptActionPointModel _$InterruptActionPointModelFromJson(
        Map<String, dynamic> json) =>
    InterruptActionPointModel(
      sourceActor: json['sourceActor'] as String? ?? "<unknown>",
      actionId: (json['actionId'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$InterruptActionPointModelToJson(
        InterruptActionPointModel instance) =>
    <String, dynamic>{
      'sourceActor': instance.sourceActor,
      'actionId': instance.actionId,
    };
