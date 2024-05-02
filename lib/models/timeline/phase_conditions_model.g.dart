// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phase_conditions_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PhaseConditionModel _$PhaseConditionModelFromJson(Map<String, dynamic> json) =>
    PhaseConditionModel(
      condition: $enumDecode(_$PhaseConditionTypeEnumMap, json['condition']),
      params: (json['params'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      phase: json['phase'] as String,
      loop: json['loop'] as bool,
      enabled: json['enabled'] as bool? ?? true,
      description: json['description'] as String? ?? "",
    );

Map<String, dynamic> _$PhaseConditionModelToJson(
        PhaseConditionModel instance) =>
    <String, dynamic>{
      'description': instance.description,
      'condition': _$PhaseConditionTypeEnumMap[instance.condition]!,
      'params': instance.params,
      'phase': instance.phase,
      'loop': instance.loop,
      'enabled': instance.enabled,
    };

const _$PhaseConditionTypeEnumMap = {
  PhaseConditionType.hpPctLessThan: 'hpPctLessThan',
  PhaseConditionType.elapsedTimeGreaterThan: 'elapsedTimeGreaterThan',
  PhaseConditionType.hpPctBetween: 'hpPctBetween',
  PhaseConditionType.directorVarGreaterThan: 'directorVarGreaterThan',
};
