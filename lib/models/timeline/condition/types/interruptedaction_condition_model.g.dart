// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interruptedaction_condition_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InterruptedActionConditionModel _$InterruptedActionConditionModelFromJson(
        Map<String, dynamic> json) =>
    InterruptedActionConditionModel(
      sourceActor: json['sourceActor'] as String? ?? "<unknown>",
      actionId: (json['actionId'] as num?)?.toInt() ?? 0xFF14,
    );

Map<String, dynamic> _$InterruptedActionConditionModelToJson(
        InterruptedActionConditionModel instance) =>
    <String, dynamic>{
      'sourceActor': instance.sourceActor,
      'actionId': instance.actionId,
    };
