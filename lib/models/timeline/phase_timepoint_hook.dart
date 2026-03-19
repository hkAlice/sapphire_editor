enum PhaseTimepointHook {
  onEnter,
  onExit,
}

class PhaseHookScheduleIds {
  static const int onEnter = -1;
  static const int onExit = -2;

  static bool isPhaseHookScheduleId(int scheduleId) {
    return scheduleId == onEnter || scheduleId == onExit;
  }

  static PhaseTimepointHook? hookFromScheduleId(int? scheduleId) {
    if(scheduleId == null || scheduleId == onEnter) {
      return PhaseTimepointHook.onEnter;
    }

    if(scheduleId == onExit) {
      return PhaseTimepointHook.onExit;
    }

    return null;
  }

  static int scheduleIdForHook(PhaseTimepointHook hook) {
    return switch (hook) {
      PhaseTimepointHook.onEnter => onEnter,
      PhaseTimepointHook.onExit => onExit,
    };
  }
}
