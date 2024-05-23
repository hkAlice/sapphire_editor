// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phase_conditions_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PhaseConditionModel _$PhaseConditionModelFromJson(Map<String, dynamic> json) =>
    PhaseConditionModel(
      id: (json['id'] as num).toInt(),
      condition: $enumDecode(_$PhaseConditionTypeEnumMap, json['condition']),
      loop: json['loop'] as bool,
      paramData: json['paramData'],
      enabled: json['enabled'] as bool? ?? true,
      description: json['description'] as String? ?? "",
      targetActor: json['targetActor'] as String?,
      targetPhase: json['targetPhase'] as String?,
    );

Map<String, dynamic> _$PhaseConditionModelToJson(
        PhaseConditionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'condition': _$PhaseConditionTypeEnumMap[instance.condition]!,
      'paramData': instance.paramData,
      'loop': instance.loop,
      'enabled': instance.enabled,
      'targetActor': instance.targetActor,
      'targetPhase': instance.targetPhase,
    };

const _$PhaseConditionTypeEnumMap = {
  PhaseConditionType.combatState: 'combatState',
  PhaseConditionType.directorVarGreaterThan: 'directorVarGreaterThan',
  PhaseConditionType.elapsedTimeGreaterThan: 'elapsedTimeGreaterThan',
  PhaseConditionType.hpPctBetween: 'hpPctBetween',
  PhaseConditionType.hpPctLessThan: 'hpPctLessThan',
};
