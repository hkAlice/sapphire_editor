import 'package:json_annotation/json_annotation.dart';

part 'combatstate_condition_model.g.dart';

@JsonSerializable()
class CombatStateConditionModel {
  String? sourceActor;
  ActorCombatState? combatState;

  CombatStateConditionModel({
    this.sourceActor = "<unknown>",
    this.combatState = ActorCombatState.combat,
  });

  factory CombatStateConditionModel.fromJson(Map<String, dynamic> json) => _$CombatStateConditionModelFromJson(json);

  Map<String, dynamic> toJson() => _$CombatStateConditionModelToJson(this);
}

enum ActorCombatState {
  @JsonValue(0)
  idle,
  @JsonValue(1)
  combat,
  @JsonValue(2)
  retreat,
  @JsonValue(3)
  roaming,
  @JsonValue(4)
  justDied,
  @JsonValue(5)
  dead,
}