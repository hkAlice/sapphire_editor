// todo: ideally this would be a service and handle everything timeline based (adding, etc)
import 'package:collection/collection.dart';
import 'package:sapphire_editor/models/timeline/conditions/phase_conditions_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';

class TimelineSanitySvc {
  static List<SanityItem> run(TimelineModel timeline) {
    List<SanityItem> items = [];

    // todo: copy and ignore disabled conditions and phases

    _checkStalls(timeline, items);
    
    return items..sortBy<num>((e) => e.severity.index);
  }

  static void _checkStalls(TimelineModel timeline, List<SanityItem> items) {
    bool hasCombatPhaseCondition = timeline.phaseConditions.where((e) => e.condition == PhaseConditionType.combatState).isNotEmpty;

    List<String> actorNameList = [];
    List<int> layoutIdList = [];

    for(var actor in timeline.actors) {
      if(actor.phases.isEmpty) {
        items.add(SanityItem(SanitySeverity.warning, "StallActor", "Actor ${actor.name} has no phases and may stall."));
      }

      if(actorNameList.contains(actor.name)) {
        items.add(SanityItem(SanitySeverity.error, "UnresolvedDuplicateActorRef", "Duplicate actor name ${actor.name}. Ensure that actors have distinct names."));
      }
      if(layoutIdList.contains(actor.layoutId)) {
        items.add(SanityItem(SanitySeverity.error, "UnresolvedDuplicateActorRef", "Duplicate actor layoutId ${actor.layoutId}. Ensure that actors have distinct layoutId."));
      }

      actorNameList.add(actor.name);
      layoutIdList.add(actor.layoutId);
    }

    actorNameList.where((e) => actorNameList.where((element) => element == e).length > 1).toSet().toList();
    layoutIdList.where((e) => layoutIdList.where((element) => element == e).length > 1).toSet().toList();

    if(timeline.phaseConditions.isEmpty) {
      items.add(const SanityItem(SanitySeverity.error, "StallNoConds", "No conditions to push phases with. Ensure that the timeline has conditions."));
    }

    {
      // check condition conflictsz (only check if the *NEXT* condition is a duplicate, allow inbetween conditions)
      // todo: there may be valid instances of duplicate conditions, not much point in raising warning issue here
      /*for(int i = 0; i < timeline.phaseConditions.length - 1; i++) {
        final cond1 = timeline.phaseConditions[i];
        final cond2 = timeline.phaseConditions[i + 1];
        if(cond1.paramData == cond && cond1.condition == cond2.condition) {
          items.add(SanityItem(SanitySeverity.warning, "DuplicateConditionConflict", "Condition of type ${cond1.condition} and params ${cond1.params.join(", ")} is duplicate of next condition"));
        }
      }*/
      
    }

    {
      // check if last phase in actor loops and has end scenario
      if(timeline.phaseConditions.isNotEmpty && !timeline.phaseConditions.last.loop) {
        items.add(SanityItem(SanitySeverity.warning, "MissingTailPhaseClosure", "Last phase ${timeline.phaseConditions.last.targetPhase} does not loop. Ensure that the phase ends with an enrage, fail flag, or idle phase."));
      }

      // check if timeline has on combat check
      if(!hasCombatPhaseCondition) {
        items.add(const SanityItem(SanitySeverity.warning, "NoCombatPhaseCondition", "Timeline is indifferent to whether mob is in combat or not."));
      }
    }

    {
      // check hp sanity
      /*List<PhaseConditionType> hpCondCheck = [PhaseConditionType.hpPctBetween, PhaseConditionType.hpPctLessThan];
      List<PhaseConditionModel?> hpCondList = timeline.phaseConditions.where((e) { if(hpCondCheck.contains(e.condition)) return true; return false; }).toList();
      if(hpCondList.isNotEmpty) {
        List<(int, int)> hpRanges = [];
        //int lastMax = -1;
        bool hasFirstCondAsHp = false;
        for(var cond in hpCondList) {
          if(cond == null)
            continue;

          if(cond == timeline.phaseConditions.first) {
            hasFirstCondAsHp = true;
          }

          
          if(cond.params[1] == 100) {
            items.add(const SanityItem(SanitySeverity.warning, "AvoidHP100Usage", "Avoid usage of HP% conditions == 100. Prefer checking if mob is in combat."));
          }

          if(hasFirstCondAsHp && !hasCombatPhaseCondition) {
            if(cond.params[1] != 100) {
              items.add(const SanityItem(SanitySeverity.warning, "PossibleHPGapStall", "Avoid priority of HP condition as initial phase as mob may not take damage and stall. Prefer checking if mob is in combat."));
            }
          }
          
          if(cond.condition == PhaseConditionType.hpPctLessThan) {
            if(cond.params[1] > 100) {
              items.add(const SanityItem(SanitySeverity.error, "InvalidHPVal", "Condition target HP is greater than 100."));
            }

            hpRanges.add((cond.params[1], lastMax));
            lastMax = cond.params[1];
          }

          if(cond.condition == PhaseConditionType.hpPctBetween) {
            if(cond.params[2] < cond.params[1]) {
              items.add(const SanityItem(SanitySeverity.error, "InvalidHPMinMax", "Minimum HP is greater than maximum HP for condition type hpPctBetween."));
            }
            if(cond.params[1] > 100 || cond.params[2] > 100) {
              items.add(const SanityItem(SanitySeverity.error, "InvalidHPVal", "Condition target HP is greater than 100."));
            }
            hpRanges.add((cond.params[1], cond.params[2]));
          }
        }
        
        for(var hpRange in hpRanges) {
          if(hpRange.$2 == -1) {
            items.add(SanityItem(SanitySeverity.warning, "UnconfirmedHPConditionGap", "HP condition gap between Min HP ${hpRange.$1}% and 100%. Ignore in complex cases."));
          }
          else if(hpRange.$1 > hpRange.$2) {
            items.add(SanityItem(SanitySeverity.warning, "UnorderedHPCondition", "Condition order does not match HP condition sequence. Min HP ${hpRange.$1}% > Max HP ${hpRange.$2}%"));
          }
        }
        print("1");
      }*/
    }
  }
}

class SanityItem {
  final SanitySeverity severity;
  final String type;
  final String desc;

  const SanityItem(this.severity, this.type, this.desc);
}

enum SanitySeverity {
  error,
  warning,
  info,
}