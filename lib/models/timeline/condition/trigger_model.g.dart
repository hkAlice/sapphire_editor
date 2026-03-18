// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trigger_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TriggerModel _$TriggerModelFromJson(Map<String, dynamic> json) => TriggerModel(
      id: (json['id'] as num).toInt(),
      condition: $enumDecode(_$ConditionTypeEnumMap, json['condition']),
      paramData: json['paramData'],
      description: json['description'] as String? ?? "",
      action: json['action'] == null
          ? null
          : TriggerActionModel.fromJson(json['action'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TriggerModelToJson(TriggerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'condition': _$ConditionTypeEnumMap[instance.condition]!,
      'paramData': instance.paramData,
      'action': instance.action,
    };

const _$ConditionTypeEnumMap = {
  ConditionType.combatState: 'combatState',
  ConditionType.eObjInteract: 'eObjInteract',
  ConditionType.directorVarGreaterThan: 'directorVarGreaterThan',
  ConditionType.elapsedTimeGreaterThan: 'elapsedTimeGreaterThan',
  ConditionType.getAction: 'getAction',
  ConditionType.hpPctBetween: 'hpPctBetween',
  ConditionType.hpPctLessThan: 'hpPctLessThan',
  ConditionType.scheduleActive: 'scheduleActive',
  ConditionType.interruptedAction: 'interruptedAction',
  ConditionType.varEquals: 'varEquals',
};
