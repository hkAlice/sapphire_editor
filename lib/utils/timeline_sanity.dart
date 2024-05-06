// todo: ideally this would be a service and handle everything timeline based (adding, etc)
import 'package:collection/collection.dart';
import 'package:sapphire_editor/models/timeline/phase_conditions_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';

class TimelineSanitySvc {
  static List<SanityItem> run(TimelineModel timeline) {
    List<SanityItem> items = [];

    _checkStalls(timeline, items);
    
    return items..sortBy<num>((e) => e.severity.index);;
  }

  static void _checkStalls(TimelineModel timeline, List<SanityItem> items) {
    if(timeline.phases.isEmpty) {
      items.add(const SanityItem(SanitySeverity.error, "StallNoPhases", "No phases to push. Ensure that the timeline has phases."));
    }

    if(timeline.phaseConditions.isEmpty) {
      items.add(const SanityItem(SanitySeverity.error, "StallNoConds", "No conditions to push phases with. Ensure that the timeline has conditions."));
    }


    {
      // check if last phase loops and has end scenario
      if(timeline.phaseConditions.isNotEmpty && !timeline.phaseConditions.last.loop) {
        items.add(SanityItem(SanitySeverity.warning, "MissingTailPhaseClosure", "Last phase ${timeline.phaseConditions.last.phase} does not loop. Ensure that the phase ends with an enrage, fail flag, or idle phase."));
      }

      // check if timeline has on combat check
      if(timeline.phaseConditions.where((e) => e.condition == PhaseConditionType.combatState).isEmpty) {
        if(timeline.phaseConditions.where((e) => e.condition == PhaseConditionType.elapsedTimeGreaterThan).isEmpty)
          items.add(const SanityItem(SanitySeverity.warning, "NoCombatPhase", "Timeline is indifferent to whether mob is in combat or not."));
      }
    }

    {
      // check hp sanity
      List<PhaseConditionType> hpCondCheck = [PhaseConditionType.hpPctBetween, PhaseConditionType.hpPctLessThan];
      List<PhaseConditionModel?> hpCondList = timeline.phaseConditions.where((e) { if(hpCondCheck.contains(e.condition)) return true; return false; }).toList();
      if(hpCondList.isNotEmpty) {
        List<(int, int)> hpRanges = [];
        int lastMin = 100;
        for(var cond in hpCondList) {
          if(cond == null)
            continue;
          
          if(cond.condition == PhaseConditionType.hpPctLessThan) {
            hpRanges.add((cond.params[1], lastMin));
          }

          if(cond.condition == PhaseConditionType.hpPctBetween) {
            if(cond.params[2] < cond.params[1]) {
              items.add(const SanityItem(SanitySeverity.error, "InvalidHPMinMax", "Minimum HP is greater than maximum HP for condition type hpPctBetween."));
            }
            hpRanges.add((cond.params[1], cond.params[2]));
          }
        }
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