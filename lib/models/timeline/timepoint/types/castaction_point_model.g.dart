// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'castaction_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CastActionPointModel _$CastActionPointModelFromJson(
        Map<String, dynamic> json) =>
    CastActionPointModel(
      sourceActor: json['sourceActor'] as String? ?? "<unknown>",
      actionId: (json['actionId'] as num?)?.toInt() ?? 6116,
    );

Map<String, dynamic> _$CastActionPointModelToJson(
        CastActionPointModel instance) =>
    <String, dynamic>{
      'sourceActor': instance.sourceActor,
      'actionId': instance.actionId,
    };
