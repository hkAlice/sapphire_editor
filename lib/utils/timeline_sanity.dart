// todo: ideally this would be a service and handle everything timeline based (adding, etc)
import 'package:collection/collection.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/condition/condition_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/bnpcdespawn_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/bnpcspawn_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/castaction_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/snapshot_point_model.dart';

class TimelineSanitySvc {
  static List<SanityItem> run(TimelineModel timeline) {
    List<SanityItem> items = [];

    // todo: copy and ignore disabled conditions and schedules

    _checkStalls(timeline, items);
    
    return items..sortBy<num>((e) => e.severity.index);
  }

  static void _info(String type, String desc, List<SanityItem> items) {
    items.add(SanityItem(SanitySeverity.info, type, desc));
  }

  static void _warn(String type, String desc, List<SanityItem> items) {
    items.add(SanityItem(SanitySeverity.warning, type, desc));
  }

  static void _err(String type, String desc, List<SanityItem> items) {
    items.add(SanityItem(SanitySeverity.error, type, desc));
  }

  static void _checkTimepoints(TimelineModel timeline, ActorModel actor, List<SanityItem> items) {
    List<String> refSelectors = [];
    List<String> snapshotSelectors = [];
    List<String> scheduleNameList = [];
    // todo: add bnpcpart here !! squid game
    List<String> actorRefNameList = [actor.name, ...actor.subactors];
    List<String> allMainActorRefNameList = timeline.actors.map((e) => e.name).toList();

    for(var schedule in actor.schedules) {
      if(schedule.timepoints.isEmpty) {
        _warn("EmptySchedule", "Schedule ${actor.name}->${schedule.name} has no timepoints.", items);
        continue;
      }

      if(scheduleNameList.contains(schedule.name)) {
        _err("UnresolvedDuplicateScheduleRef", "Duplicate schedule name ${actor.name}->${schedule.name}. Ensure that schedules have distinct names within an actor.", items);
      }

      scheduleNameList.add(schedule.name);

      for(var timepoint in schedule.timepoints) {
        if(timepoint.type == TimepointType.bNpcDespawn) {
          var pointData = timepoint.data as BNpcDespawnPointModel;
          if(!allMainActorRefNameList.contains(pointData.despawnActor)) {
            _err("InvalidActorRef", "Schedule ${actor.name}->${schedule.name} has BNpcDespawn with invalid actor ${pointData.despawnActor}.", items);
          }
        }
        if(timepoint.type == TimepointType.bNpcSpawn) {
          var pointData = timepoint.data as BNpcSpawnPointModel;
          if(!allMainActorRefNameList.contains(pointData.spawnActor)) {
            _err("InvalidActorRef", "Schedule ${actor.name}->${schedule.name} has BNpcSpawn with invalid actor ${pointData.spawnActor}.", items);
          }
        }
        // validate castAction timepoint
        if(timepoint.type == TimepointType.castAction) {
          var pointData = timepoint.data as CastActionPointModel;
          if(pointData.actionId == 0) {
            _err("InvalidActionID", "Schedule ${actor.name}->${schedule.name} has CastAction ActionID 0.", items);
          }

          if(pointData.actionId == 69) {
            _info("Nice", "Schedule ${actor.name}->${schedule.name} has CastAction ActionID 69. Nice", items);
          }

          if(pointData.targetType == ActorTargetType.selectorPos || pointData.targetType == ActorTargetType.selectorTarget) {
            if(!timeline.selectors.any((e) => e.name == pointData.selectorName)) {
              _err("InvalidSelectorRef", "Schedule ${actor.name}->${schedule.name} has CastAction with invalid selector ${pointData.selectorName}.", items);
            }
            else {
              if(!snapshotSelectors.contains(pointData.selectorName) && !pointData.snapshot) {
                _warn("NullSelectorSnapshotRef", "CastAction ID(${pointData.actionId.toString()}) uses selector ${pointData.selectorName} that has not been snapshot yet or null. Ignore if snapshotting selector via script or global selector.", items);
              }
              refSelectors.add(pointData.selectorName);
            }
          }
          if(!actorRefNameList.contains(pointData.sourceActor)) {
            _err("InvalidActorRef", "Schedule ${actor.name}->${schedule.name} has CastAction with invalid local actor ${pointData.sourceActor}.", items);
          }

          if(pointData.targetType == ActorTargetType.none) {
            _warn("UnsupportedTargetType", "Schedule ${actor.name}->${schedule.name} has CastAction TargetType 'none', and is undefined behavior.", items);
          }
        }

        if(timepoint.type == TimepointType.snapshot) {
          var pointData = timepoint.data as SnapshotPointModel;
          snapshotSelectors.add(pointData.selectorName);
          if(!timeline.selectors.any((e) => e.name == pointData.selectorName)) {
            _err("InvalidSelectorRef", "Schedule ${actor.name}->${schedule.name} has Snapshot with invalid selector ${pointData.selectorName}.", items);
          }
          if(!actorRefNameList.contains(pointData.sourceActor)) {
            _err("InvalidActorRef", "Schedule ${actor.name}->${schedule.name} has Snapshot with invalid local actor ${pointData.sourceActor}.", items);
          }
        }
      }
    }
  }

  static void _checkStalls(TimelineModel timeline, List<SanityItem> items) {
    bool hasCombatScheduleCondition = timeline.conditions.where((e) => e.condition == ConditionType.combatState).isNotEmpty;

    List<String> actorNameList = [];
    List<int> layoutIdList = [];

    for(var actor in timeline.actors) {
      if(actor.schedules.isEmpty) {
        _warn("StallActor", "Actor ${actor.name} has no schedules and may stall.", items);
      }

      if(actorNameList.contains(actor.name)) {
        _err("UnresolvedDuplicateActorRef", "Duplicate actor name ${actor.name}. Ensure that actors have distinct names.", items);
      }

      if(layoutIdList.contains(actor.layoutId)) {
        _err("UnresolvedDuplicateActorRef", "Duplicate actor layoutId ${actor.layoutId}. Ensure that actors have distinct layoutId.", items);
      }

      if(actor.hp == 0) {
        _err("InvalidActorHP", "Actor ${actor.name} has HP == 0.", items);
      }

      actorNameList.add(actor.name);
      layoutIdList.add(actor.layoutId);

      _checkTimepoints(timeline, actor, items);
    }

    actorNameList.where((e) => actorNameList.where((element) => element == e).length > 1).toSet().toList();
    layoutIdList.where((e) => layoutIdList.where((element) => element == e).length > 1).toSet().toList();

    if(timeline.conditions.isEmpty) {
      _err("StallNoConds", "No conditions to push schedules with. Ensure that the timeline has conditions.", items);
    }

    {
      // check condition conflictsz (only check if the *NEXT* condition is a duplicate, allow inbetween conditions)
      // todo: there may be valid instances of duplicate conditions, not much point in raising warning issue here
      /*for(int i = 0; i < timeline.scheduleConditions.length - 1; i++) {
        final cond1 = timeline.scheduleConditions[i];
        final cond2 = timeline.scheduleConditions[i + 1];
        if(cond1.paramData == cond && cond1.condition == cond2.condition) {
          items.add(SanityItem(SanitySeverity.warning, "DuplicateConditionConflict", "Condition of type ${cond1.condition} and params ${cond1.params.join(", ")} is duplicate of next condition"));
        }
      }*/
      
    }

    {
      // check if last schedule in actor loops and has end scenario
      if(timeline.conditions.isNotEmpty && !timeline.conditions.last.loop) {
        _warn("MissingTailScheduleClosure", "Last schedule ${timeline.conditions.last.targetSchedule} does not loop. Ensure that the schedule ends with an enrage, fail flag, or idle schedule.", items);
      }

      // check if timeline has on combat check
      if(!hasCombatScheduleCondition) {
        _warn("NoCombatScheduleCondition", "Timeline is indifferent to whether mob is in combat or not.", items);
      }
    }

    {
      // check hp sanity
      /*List<ScheduleConditionType> hpCondCheck = [ScheduleConditionType.hpPctBetween, ScheduleConditionType.hpPctLessThan];
      List<ScheduleConditionModel?> hpCondList = timeline.scheduleConditions.where((e) { if(hpCondCheck.contains(e.condition)) return true; return false; }).toList();
      if(hpCondList.isNotEmpty) {
        List<(int, int)> hpRanges = [];
        //int lastMax = -1;
        bool hasFirstCondAsHp = false;
        for(var cond in hpCondList) {
          if(cond == null)
            continue;

          if(cond == timeline.scheduleConditions.first) {
            hasFirstCondAsHp = true;
          }

          
          if(cond.params[1] == 100) {
            items.add(const SanityItem(SanitySeverity.warning, "AvoidHP100Usage", "Avoid usage of HP% conditions == 100. Prefer checking if mob is in combat."));
          }

          if(hasFirstCondAsHp && !hasCombatScheduleCondition) {
            if(cond.params[1] != 100) {
              items.add(const SanityItem(SanitySeverity.warning, "PossibleHPGapStall", "Avoid priority of HP condition as initial schedule as mob may not take damage and stall. Prefer checking if mob is in combat."));
            }
          }
          
          if(cond.condition == ScheduleConditionType.hpPctLessThan) {
            if(cond.params[1] > 100) {
              items.add(const SanityItem(SanitySeverity.error, "InvalidHPVal", "Condition target HP is greater than 100."));
            }

            hpRanges.add((cond.params[1], lastMax));
            lastMax = cond.params[1];
          }

          if(cond.condition == ScheduleConditionType.hpPctBetween) {
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