// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'getaction_condition_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetActionConditionModel _$GetActionConditionModelFromJson(
        Map<String, dynamic> json) =>
    GetActionConditionModel(
      sourceActor: json['sourceActor'] as String? ?? "<unknown>",
      actionId: (json['actionId'] as num?)?.toInt() ?? 0xFF14,
    );

Map<String, dynamic> _$GetActionConditionModelToJson(
        GetActionConditionModel instance) =>
    <String, dynamic>{
      'sourceActor': instance.sourceActor,
      'actionId': instance.actionId,
    };
