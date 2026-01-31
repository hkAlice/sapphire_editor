// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'condition_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConditionModel _$ConditionModelFromJson(Map<String, dynamic> json) =>
    ConditionModel(
      id: (json['id'] as num).toInt(),
      condition: $enumDecode(_$ConditionTypeEnumMap, json['condition']),
      loop: json['loop'] as bool,
      paramData: json['paramData'],
      enabled: json['enabled'] as bool? ?? true,
      description: json['description'] as String? ?? "",
      targetActor: json['targetActor'] as String?,
      targetSchedule: json['targetSchedule'] as String?,
    );

Map<String, dynamic> _$ConditionModelToJson(ConditionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'condition': _$ConditionTypeEnumMap[instance.condition]!,
      'paramData': instance.paramData,
      'loop': instance.loop,
      'enabled': instance.enabled,
      'targetActor': instance.targetActor,
      'targetSchedule': instance.targetSchedule,
    };

const _$ConditionTypeEnumMap = {
  ConditionType.combatState: 'combatState',
  ConditionType.directorVarGreaterThan: 'directorVarGreaterThan',
  ConditionType.elapsedTimeGreaterThan: 'elapsedTimeGreaterThan',
  ConditionType.getAction: 'getAction',
  ConditionType.hpPctBetween: 'hpPctBetween',
  ConditionType.hpPctLessThan: 'hpPctLessThan',
  ConditionType.scheduleActive: 'scheduleActive',
  ConditionType.interruptedAction: 'interruptedAction',
  ConditionType.rngEquals: 'rngEquals',
};
