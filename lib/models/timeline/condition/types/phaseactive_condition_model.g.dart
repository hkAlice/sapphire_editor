// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phaseactive_condition_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PhaseActiveConditionModel _$PhaseActiveConditionModelFromJson(
        Map<String, dynamic> json) =>
    PhaseActiveConditionModel(
      sourceActor: json['sourceActor'] as String? ?? "<unknown>",
      phaseName: json['phaseName'] as String? ?? "<unset>",
    );

Map<String, dynamic> _$PhaseActiveConditionModelToJson(
        PhaseActiveConditionModel instance) =>
    <String, dynamic>{
      'sourceActor': instance.sourceActor,
      'phaseName': instance.phaseName,
    };
