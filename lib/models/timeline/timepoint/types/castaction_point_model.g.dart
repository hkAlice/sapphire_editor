// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'castaction_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CastActionModel _$CastActionModelFromJson(Map<String, dynamic> json) =>
    CastActionModel(
      targetActor: json['targetActor'] as String,
      actionId: (json['actionId'] as num).toInt(),
    );

Map<String, dynamic> _$CastActionModelToJson(CastActionModel instance) =>
    <String, dynamic>{
      'targetActor': instance.targetActor,
      'actionId': instance.actionId,
    };
