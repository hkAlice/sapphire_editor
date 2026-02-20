// todo: ideally this would be a service and handle everything timeline based (adding, etc)
import 'package:collection/collection.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/condition/condition_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/bnpcdespawn_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/bnpcspawn_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/castaction_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/rollrng_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/snapshot_point_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/getaction_condition_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/hppctbetween_condition_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/scheduleactive_condition_model.dart';

class TimelineSanitySvc {
  static List<SanityItem> run(TimelineModel timeline) {
    List<SanityItem> items = [];

    _checkGlobal(timeline, items);
    _checkActors(timeline, items);
    _checkConditions(timeline, items);
    _checkUsage(timeline, items);

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

  static void _checkGlobal(TimelineModel timeline, List<SanityItem> items) {
    // check for duplicate selectors
    final selectorNames = <String>{};
    for(final selector in timeline.selectors) {
      if(selectorNames.contains(selector.name)) {
        _err(
            "DuplicateSelector",
            "Duplicate selector name '${selector.name}'. Selectors must have unique names.",
            items);
      }
      selectorNames.add(selector.name);
    }

    if(timeline.conditions.isEmpty) {
      _err(
          "StallNoConds",
          "No conditions defined. The timeline will never transition between schedules.",
          items);
    }
  }

  static void _checkActors(TimelineModel timeline, List<SanityItem> items) {
    final actorNames = <String>{};
    final layoutIds = <int>{};

    for(var actor in timeline.actors) {
      if(actorNames.contains(actor.name)) {
        _err("DuplicateActorName", "Duplicate actor name '${actor.name}'.",
            items);
      }
      actorNames.add(actor.name);

      if(layoutIds.contains(actor.layoutId)) {
        _err(
            "DuplicateActorLayoutId",
            "Duplicate actor layoutId ${actor.layoutId} for actor '${actor.name}'.",
            items);
      }
      layoutIds.add(actor.layoutId);

      if(actor.hp == 0) {
        _err("InvalidActorHP", "Actor '${actor.name}' has 0 HP.", items);
      }

      if(actor.schedules.isEmpty) {
        _warn("StallActor", "Actor '${actor.name}' has no schedules.", items);
      }

      _checkTimepoints(timeline, actor, items);
    }
  }

  static void _checkTimepoints(TimelineModel timeline, ActorModel actor, List<SanityItem> items) {
    final scheduleNames = <String>{};
    final actorRefNameList = [actor.name, ...actor.subactors];
    final allMainActorNames = timeline.actors.map((e) => e.name).toList();
    final selectorNames = timeline.selectors.map((e) => e.name).toSet();

    for(var schedule in actor.schedules) {
      if(schedule.timepoints.isEmpty) {
        _warn(
            "EmptySchedule",
            "Schedule ${actor.name}->${schedule.name} has no timepoints.",
            items);
      }

      if(scheduleNames.contains(schedule.name)) {
        _err(
            "DuplicateScheduleName",
            "Duplicate schedule name '${schedule.name}' in actor '${actor.name}'.",
            items);
      }
      scheduleNames.add(schedule.name);

      for(var timepoint in schedule.timepoints) {
        switch (timepoint.type) {
          case TimepointType.bNpcDespawn:
            var data = timepoint.data as BNpcDespawnPointModel;
            if(!allMainActorNames.contains(data.despawnActor)) {
              _err(
                  "InvalidActorRef",
                  "BNpcDespawn in ${actor.name}->${schedule.name} references invalid actor '${data.despawnActor}'.",
                  items);
            }
            break;
          case TimepointType.bNpcSpawn:
            var data = timepoint.data as BNpcSpawnPointModel;
            if(!allMainActorNames.contains(data.spawnActor)) {
              _err(
                  "InvalidActorRef",
                  "BNpcSpawn in ${actor.name}->${schedule.name} references invalid actor '${data.spawnActor}'.",
                  items);
            }
            break;
          case TimepointType.castAction:
            var data = timepoint.data as CastActionPointModel;
            if(data.actionId == 0) {
              _err(
                  "InvalidActionID",
                  "CastAction in ${actor.name}->${schedule.name} has ActionID 0.",
                  items);
            }
            if(data.actionId == 69) {
              _info(
                  "Nice",
                  "Schedule ${actor.name}->${schedule.name} has CastAction ActionID 69. Nice",
                  items);
            }
            if(!actorRefNameList.contains(data.sourceActor)) {
              _err(
                  "InvalidActorRef",
                  "CastAction in ${actor.name}->${schedule.name} references invalid local actor '${data.sourceActor}'.",
                  items);
            }
            if(data.targetType == ActorTargetType.selectorPos ||
                data.targetType == ActorTargetType.selectorTarget) {
              if(!selectorNames.contains(data.selectorName)) {
                _err(
                    "InvalidSelectorRef",
                    "CastAction in ${actor.name}->${schedule.name} references invalid selector '${data.selectorName}'.",
                    items);
              }
            }
            if(data.targetType == ActorTargetType.none) {
              _warn(
                  "UnsupportedTargetType",
                  "CastAction in ${actor.name}->${schedule.name} has TargetType 'none' (undefined behavior).",
                  items);
            }
            break;
          case TimepointType.snapshot:
            var data = timepoint.data as SnapshotPointModel;
            if(!selectorNames.contains(data.selectorName)) {
              _err(
                  "InvalidSelectorRef",
                  "Snapshot in ${actor.name}->${schedule.name} references invalid selector '${data.selectorName}'.",
                  items);
            }
            if(!actorRefNameList.contains(data.sourceActor)) {
              _err(
                  "InvalidActorRef",
                  "Snapshot in ${actor.name}->${schedule.name} references invalid local actor '${data.sourceActor}'.",
                  items);
            }
            break;
          case TimepointType.rollRNG:
            var data = timepoint.data as RollRNGPointModel;
            if(data.min > data.max) {
              _err(
                  "InvalidMinMax",
                  "RollRNG in ${actor.name}->${schedule.name} has min (${data.min}) > max (${data.max}).",
                  items);
            }
            break;
          default:
            break;
        }
      }
    }
  }

  static void _checkConditions(TimelineModel timeline, List<SanityItem> items) {
    if(timeline.conditions.isEmpty) return;

    bool hasCombatCheck = false;
    final allActorNames = timeline.actors.map((e) => e.name).toSet();

    for(var i = 0; i < timeline.conditions.length; i++) {
      final cond = timeline.conditions[i];
      if(!cond.enabled) continue;

      if(cond.condition == ConditionType.combatState) {
        hasCombatCheck = true;
      }

      // validate target actor and schedule
      if(cond.targetActor != null) {
        final targetActor =
            timeline.actors.firstWhereOrNull((a) => a.name == cond.targetActor);
        if(targetActor == null) {
          _err(
              "InvalidConditionTarget",
              "Condition #${cond.id} targets invalid actor '${cond.targetActor}'.",
              items);
        } else if(cond.targetSchedule != null &&
            cond.targetSchedule!.isNotEmpty) {
          if(!targetActor.schedules
              .any((s) => s.name == cond.targetSchedule)) {
            _err(
                "InvalidConditionTarget",
                "Condition #${cond.id} targets invalid schedule '${cond.targetSchedule}' for actor '${cond.targetActor}'.",
                items);
          }
        }
      }

      if(cond.condition == ConditionType.scheduleActive) {
        final data = cond.paramData as ScheduleActiveConditionModel;
        final sourceActor =
            timeline.actors.firstWhereOrNull((a) => a.name == data.sourceActor);
        if(sourceActor == null) {
          _err(
              "InvalidConditionRef",
              "ScheduleActive condition #${cond.id} references invalid source actor '${data.sourceActor}'.",
              items);
        } else if(!sourceActor.schedules
            .any((s) => s.name == data.scheduleName)) {
          _err(
              "InvalidConditionRef",
              "ScheduleActive condition #${cond.id} references invalid schedule '${data.scheduleName}' for actor '${data.sourceActor}'.",
              items);
        }
      }

      if(cond.condition == ConditionType.getAction) {
        final data = cond.paramData as GetActionConditionModel;
        if(data.actionId == 0) {
          _err("InvalidActionID",
              "GetAction condition #${cond.id} has ActionID 0.", items);
        }
        if(!allActorNames.contains(data.sourceActor)) {
          _err(
              "InvalidActorRef",
              "GetAction condition #${cond.id} references invalid source actor '${data.sourceActor}'.",
              items);
        }
      }
    }

    // hp sanity
    _checkHPSanity(timeline, items);

    // tail closure
    if(!timeline.conditions.last.loop) {
      _warn(
          "MissingTailScheduleClosure",
          "The last condition does not loop. Ensure it ends with an enrage or idle schedule.",
          items);
    }

    if(!hasCombatCheck) {
      _warn(
          "NoCombatScheduleCondition",
          "Timeline has no combat state check. It might trigger while out of combat.",
          items);
    }
  }

  static void _checkHPSanity(TimelineModel timeline, List<SanityItem> items) {
    final hpConds = timeline.conditions
        .where((c) =>
            c.enabled &&
            (c.condition == ConditionType.hpPctBetween ||
                c.condition == ConditionType.hpPctLessThan))
        .toList();

    if(hpConds.isEmpty) return;

    // group by source actor to check ranges per actor
    final condsByActor = <String, List<ConditionModel>>{};
    for(final cond in hpConds) {
      String? actorName;
      if(cond.condition == ConditionType.hpPctBetween) {
        actorName = (cond.paramData as HPPctBetweenConditionModel).sourceActor;
      } else if(cond.condition == ConditionType.hpPctLessThan) {
        final data = cond.paramData;
        if(data is Map && data.containsKey('sourceActor')) {
          actorName = data['sourceActor'] as String;
        }
      }
      if(actorName != null) {
        condsByActor.putIfAbsent(actorName, () => []).add(cond);
      }
    }

    condsByActor.forEach((actorName, actorConds) {
      final ranges = <({double min, double max, int id})>[];

      for(final cond in actorConds) {
        double min = 0, max = 100;
        if(cond.condition == ConditionType.hpPctBetween) {
          final data = cond.paramData as HPPctBetweenConditionModel;
          min = (data.hpMin ?? 0).toDouble();
          max = (data.hpMax ?? 100).toDouble();
        } else if(cond.condition == ConditionType.hpPctLessThan) {
          final data = cond.paramData;
          if(data is Map && data.containsKey('hpLessThan')) {
            max = (data['hpLessThan'] as num).toDouble();
            min = 0;
          }
        }

        if(min > max) {
          _err(
              "InvalidHPMinMax",
              "HP condition #${cond.id} has min HP ($min%) > max HP ($max%).",
              items);
        }
        if(max > 100 || min < 0) {
          _err(
              "InvalidHPVal",
              "HP condition #${cond.id} has percentage values outside 0-100 range.",
              items);
        }
        if(max == 100 && min < 100) {
          _warn(
              "AvoidHP100Usage",
              "HP condition #${cond.id} uses 100%. Prefer checking combat state.",
              items);
        }

        ranges.add((min: min, max: max, id: cond.id));
      }

      // Check for overlaps
      for(var i = 0; i < ranges.length; i++) {
        for(var j = i + 1; j < ranges.length; j++) {
          final r1 = ranges[i];
          final r2 = ranges[j];
          if(r1.min < r2.max && r2.min < r1.max) {
            _warn(
                "HPConditionOverlap",
                "HP conditions #${r1.id} and #${r2.id} for actor '$actorName' overlap ranges.",
                items);
          }
        }
      }
    });
  }

  static void _checkUsage(TimelineModel timeline, List<SanityItem> items) {
    final usedSchedules = <String, Set<String>>{}; // actorName -> scheduleNames
    final usedSelectors = <String>{};
    final usedActors = <String>{};

    // Mark initial actor names as used if they have any schedules
    for(final actor in timeline.actors) {
      if(actor.schedules.isNotEmpty) {
        // schedules might still be unused if no condition points to them
      }
    }

    for(final cond in timeline.conditions) {
      if(!cond.enabled) continue;
      if(cond.targetActor != null && cond.targetSchedule != null) {
        usedSchedules
            .putIfAbsent(cond.targetActor!, () => {})
            .add(cond.targetSchedule!);
        usedActors.add(cond.targetActor!);
      }

      if(cond.condition == ConditionType.scheduleActive) {
        final data = cond.paramData as ScheduleActiveConditionModel;
        usedSchedules
            .putIfAbsent(data.sourceActor, () => {})
            .add(data.scheduleName);
        usedActors.add(data.sourceActor);
      }

      if(cond.condition == ConditionType.getAction) {
        final data = cond.paramData as GetActionConditionModel;
        usedActors.add(data.sourceActor);
      }

      if(cond.condition == ConditionType.hpPctBetween) {
        final data = cond.paramData as HPPctBetweenConditionModel;
        if(data.sourceActor != null) usedActors.add(data.sourceActor!);
      }
    }

    for(final actor in timeline.actors) {
      for(final schedule in actor.schedules) {
        for(final timepoint in schedule.timepoints) {
          switch (timepoint.type) {
            case TimepointType.bNpcSpawn:
              usedActors
                  .add((timepoint.data as BNpcSpawnPointModel).spawnActor);
              break;
            case TimepointType.bNpcDespawn:
              usedActors
                  .add((timepoint.data as BNpcDespawnPointModel).despawnActor);
              break;
            case TimepointType.snapshot:
              usedSelectors
                  .add((timepoint.data as SnapshotPointModel).selectorName);
              break;
            case TimepointType.castAction:
              final data = timepoint.data as CastActionPointModel;
              if(data.targetType == ActorTargetType.selectorPos ||
                  data.targetType == ActorTargetType.selectorTarget) {
                usedSelectors.add(data.selectorName);
              }
              break;
            default:
              break;
          }
        }
      }
    }

    // Report unused schedules
    for(final actor in timeline.actors) {
      final actorUsedSchedules = usedSchedules[actor.name] ?? {};
      for(final schedule in actor.schedules) {
        if(!actorUsedSchedules.contains(schedule.name)) {
          _warn(
              "UnusedSchedule",
              "Schedule '${schedule.name}' for actor '${actor.name}' is never targeted and will never run.",
              items);
        }
      }

      if(!usedActors.contains(actor.name) && actor.schedules.isEmpty) {
        _warn(
            "UnusedActor",
            "Actor '${actor.name}' has no schedules and is never referenced.",
            items);
      }
    }

    // Report unused selectors
    for(final selector in timeline.selectors) {
      if(!usedSelectors.contains(selector.name)) {
        _warn("UnusedSelector",
            "Selector '${selector.name}' is defined but never used.", items);
      }
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
