// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'combatstate_condition_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CombatStateConditionModel _$CombatStateConditionModelFromJson(
        Map<String, dynamic> json) =>
    CombatStateConditionModel(
      sourceActor: json['sourceActor'] as String? ?? "<unknown>",
      combatState:
          $enumDecodeNullable(_$ActorCombatStateEnumMap, json['combatState']) ??
              ActorCombatState.combat,
    );

Map<String, dynamic> _$CombatStateConditionModelToJson(
        CombatStateConditionModel instance) =>
    <String, dynamic>{
      'sourceActor': instance.sourceActor,
      'combatState': _$ActorCombatStateEnumMap[instance.combatState],
    };

const _$ActorCombatStateEnumMap = {
  ActorCombatState.idle: 0,
  ActorCombatState.combat: 1,
  ActorCombatState.retreat: 2,
  ActorCombatState.roaming: 3,
  ActorCombatState.justDied: 4,
  ActorCombatState.dead: 5,
};
