import 'dart:async';
import 'dart:convert';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_phase_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_schedule_model.dart';
import 'package:sapphire_editor/models/timeline/condition/trigger_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/combatstate_condition_model.dart';
import 'package:sapphire_editor/models/timeline/selector/selector_model.dart';
import 'package:sapphire_editor/models/timeline/selector/selector_filter_model.dart';
import 'package:sapphire_editor/services/storage_helper.dart';
import 'package:sapphire_editor/models/timeline/condition/trigger_action_model.dart';

class TimelineEditorSignal {
  final Signal<TimelineModel> timeline;

  final Signal<int?> selectedActorId;
  final Signal<String?> selectedPhaseId;
  final Signal<int?> selectedScheduleId;

  late final Computed<ActorModel> selectedActor;
  late final Computed<TimelinePhaseModel> selectedPhase;
  late final Computed<TimelineScheduleModel?> selectedSchedule;

  late final Computed<String> jsonOutput;

  late final Computed<bool> isValid;

  final _history = <String>[];
  final Signal<int> _historyIndex;
  late final Computed<bool> canUndo;
  late final Computed<bool> canRedo;

  Timer? _autosaveTimer;
  final Signal<DateTime?> lastAutosave;

  Timer? _jsonDebounceTimer;
  final Signal<String> _pendingJsonInput;

  TimelineEditorSignal([TimelineModel? initialTimeline])
      : timeline =
            signal<TimelineModel>(initialTimeline ?? _createDefaultTimeline()),
        selectedActorId = signal(0),
        selectedPhaseId = signal(null),
        selectedScheduleId = signal(0),
        _historyIndex = signal(-1),
        lastAutosave = signal<DateTime?>(null),
        _pendingJsonInput = signal('') {
    selectedActor = computed(() {
      final actors = timeline.value.actors;
      if(actors.isEmpty) {
        return throw StateError("Timeline must contain at least one actor");
      }
      final id = selectedActorId.value;
      return actors.firstWhere((a) => a.id == id, orElse: () => actors.first);
    });

    selectedPhase = computed(() {
      final phases = selectedActor.value.phases;
      if(phases.isEmpty) {
        return throw StateError("Actor must contain at least one phase");
      }
      final id = selectedPhaseId.value;
      return phases.firstWhere((p) => p.id == id, orElse: () => phases.first);
    });

    selectedSchedule = computed(() {
      final schedules = selectedPhase.value.schedules;
      if(schedules.isEmpty) {
        return null;
      }
      final id = selectedScheduleId.value;
      return schedules.firstWhere((s) => s.id == id,
          orElse: () => schedules.first);
    });

    effect(() {
      final actors = timeline.value.actors;
      if(actors.isEmpty) return;
      final currentId = selectedActorId.value;
      final exists = actors.any((a) => a.id == currentId);
      if(!exists) {
        Future.microtask(() => selectedActorId.value = actors.first.id);
      }
    });

    effect(() {
      final actor = selectedActor.value;

      if(actor.phases.isEmpty) {
        return;
      }

      final selectedPhase = selectedPhaseId.value;
      final phaseExists = selectedPhase != null &&
          actor.phases.any((p) => p.id == selectedPhase);

      if(!phaseExists) {
        Future.microtask(() => selectedPhaseId.value = actor.phases.first.id);
        return;
      }

      final phase =
          actor.phases.firstWhere((p) => p.id == selectedPhaseId.value);
      final selectedSchedule = selectedScheduleId.value;
      final scheduleExists = selectedSchedule != null &&
          phase.schedules.any((schedule) => schedule.id == selectedSchedule);

      if(!scheduleExists) {
        Future.microtask(() {
          selectedScheduleId.value =
              phase.schedules.isEmpty ? null : phase.schedules.first.id;
        });
      }
    });

    jsonOutput = computed(() {
      try {
        return jsonEncode(timeline.value.toJson());
      } catch (_) {
        return '{}';
      }
    });

    isValid = computed(() => _validateTimeline(timeline.value));

    canUndo = computed(() => _historyIndex.value > 0);
    canRedo = computed(() => _historyIndex.value < _history.length - 1);

    effect(() {
      final json = jsonOutput.value;
      _scheduleAutosave(json);
    });

    _saveToHistory();
  }

  String _defaultPhaseIdForActor(ActorModel actor) {
    if(actor.phases.isEmpty) {
      throw StateError("Actor must contain at least one phase");
    }

    final selectedId = selectedPhaseId.peek();
    if(selectedId != null &&
        actor.phases.any((phase) => phase.id == selectedId)) {
      return selectedId;
    }

    return actor.phases.first.id;
  }

  String _resolvePhaseIdForActor(int actorId, [String? requestedPhaseId]) {
    final actor = timeline.value.actors.firstWhere(
      (item) => item.id == actorId,
      orElse: () => timeline.value.actors.first,
    );

    if(requestedPhaseId != null &&
        actor.phases.any((phase) => phase.id == requestedPhaseId)) {
      return requestedPhaseId;
    }

    return _defaultPhaseIdForActor(actor);
  }

  String _resolvePhaseIdByScheduleId(int actorId, int scheduleId,
      [String? fallbackPhaseId]) {
    final actor = timeline.value.actors.firstWhere(
      (item) => item.id == actorId,
      orElse: () => timeline.value.actors.first,
    );

    if(fallbackPhaseId != null) {
      final fallbackPhase =
          actor.phases.where((phase) => phase.id == fallbackPhaseId);
      if(fallbackPhase.isNotEmpty &&
          fallbackPhase.first.schedules
              .any((schedule) => schedule.id == scheduleId)) {
        return fallbackPhaseId;
      }
    }

    for(final phase in actor.phases) {
      if(phase.schedules.any((schedule) => schedule.id == scheduleId)) {
        return phase.id;
      }
    }

    return _resolvePhaseIdForActor(actorId, fallbackPhaseId);
  }

  int generateNextTimepointIdForPhase(int actorId, String phaseId) {
    if(timeline.value.actors.isEmpty) {
      return 1;
    }

    final actor = timeline.value.actors.firstWhere(
      (item) => item.id == actorId,
      orElse: () => timeline.value.actors.first,
    );

    if(actor.phases.isEmpty) {
      return 1;
    }

    final resolvedPhaseId = _resolvePhaseIdForActor(actor.id, phaseId);
    final phase = actor.phases.firstWhere(
      (item) => item.id == resolvedPhaseId,
      orElse: () => actor.phases.first,
    );

    final allTimepointIds = [
      ...phase.onEnter.map((tp) => tp.id),
      ...phase.schedules
          .expand((schedule) => schedule.timepoints)
          .map((tp) => tp.id),
    ];

    if(allTimepointIds.isEmpty) {
      return 1;
    }

    return allTimepointIds.reduce((a, b) => a > b ? a : b) + 1;
  }

  void updateTimepointInPhase(int actorId, String phaseId, int? scheduleId,
      int timepointId, TimepointModel newTimepoint) {
    final resolvedPhaseId = _resolvePhaseIdForActor(actorId, phaseId);

    batch(() {
      final actorIndex =
          timeline.value.actors.indexWhere((a) => a.id == actorId);
      if(actorIndex == -1) return;
      final actor = timeline.value.actors[actorIndex];
      final newActor = _replaceTimepoint(
          actor, resolvedPhaseId, scheduleId, timepointId, newTimepoint);
      final newActors = [...timeline.value.actors];
      newActors[actorIndex] = newActor;
      timeline.value = timeline.value.copyWith(actors: newActors);
    });
    _saveToHistory();
  }

  void updateTimepoint(
      int actorId, int scheduleId, int timepointId, TimepointModel newTimepoint) {
    if(scheduleId < 0) {
      final phaseId = _resolvePhaseIdForActor(actorId, selectedPhaseId.peek());
      updateTimepointInPhase(actorId, phaseId, null, timepointId, newTimepoint);
      return;
    }

    final phaseId = _resolvePhaseIdByScheduleId(
        actorId, scheduleId, selectedPhaseId.peek());
    updateTimepointInPhase(
        actorId, phaseId, scheduleId, timepointId, newTimepoint);
  }

  void addTimepointInPhase(
      int actorId, String phaseId, int? scheduleId, TimepointModel timepoint) {
    final resolvedPhaseId = _resolvePhaseIdForActor(actorId, phaseId);
    final actorIndex = timeline.value.actors.indexWhere((a) => a.id == actorId);
    if(actorIndex == -1) return;
    final actor = timeline.value.actors[actorIndex];
    final phaseIndex = actor.phases.indexWhere((p) => p.id == resolvedPhaseId);
    if(phaseIndex == -1) return;
    final phase = actor.phases[phaseIndex];

    if(scheduleId == null) {
      final newTimepoints = [...phase.onEnter, timepoint];
      newTimepoints.sort((a, b) => a.startTime.compareTo(b.startTime));
      final newPhase = phase.copyWith(onEnter: newTimepoints);
      updatePhase(phase, newPhase, actorId);
    } else {
      final scheduleIndex =
          phase.schedules.indexWhere((s) => s.id == scheduleId);
      if(scheduleIndex == -1) return;
      final schedule = phase.schedules[scheduleIndex];
      final newTimepoints = [...schedule.timepoints, timepoint];
      newTimepoints.sort((a, b) => a.startTime.compareTo(b.startTime));
      final newSchedule = schedule.copyWith(timepoints: newTimepoints);
      updateSchedule(resolvedPhaseId, schedule, newSchedule, actorId);
    }
    _saveToHistory();
  }

  void addTimepoint(int actorId, int scheduleId, TimepointModel timepoint) {
    final phaseId = _resolvePhaseIdByScheduleId(
        actorId, scheduleId, selectedPhaseId.peek());
    addTimepointInPhase(actorId, phaseId, scheduleId, timepoint);
  }

  void removeTimepointInPhase(
      int actorId, String phaseId, int? scheduleId, TimepointModel timepoint) {
    final resolvedPhaseId = _resolvePhaseIdForActor(actorId, phaseId);
    final actorIndex = timeline.value.actors.indexWhere((a) => a.id == actorId);
    if(actorIndex == -1) return;
    final actor = timeline.value.actors[actorIndex];
    final phaseIndex = actor.phases.indexWhere((p) => p.id == resolvedPhaseId);
    if(phaseIndex == -1) return;
    final phase = actor.phases[phaseIndex];

    if(scheduleId == null) {
      final newPhase = phase.copyWith(
          onEnter: phase.onEnter.where((t) => t != timepoint).toList());
      updatePhase(phase, newPhase, actorId);
    } else {
      final scheduleIndex =
          phase.schedules.indexWhere((s) => s.id == scheduleId);
      if(scheduleIndex == -1) return;
      final schedule = phase.schedules[scheduleIndex];
      final newSchedule = schedule.copyWith(
          timepoints:
              schedule.timepoints.where((t) => t != timepoint).toList());
      updateSchedule(resolvedPhaseId, schedule, newSchedule, actorId);
    }
    _saveToHistory();
  }

  void removeTimepoint(
      TimelineScheduleModel schedule, TimepointModel timepoint, int actorId) {
    final phaseId = _resolvePhaseIdByScheduleId(
        actorId, schedule.id, selectedPhaseId.peek());
    removeTimepointInPhase(actorId, phaseId, schedule.id, timepoint);
  }

  void duplicateTimepointInPhase(
      int actorId, String phaseId, int? scheduleId, TimepointModel timepoint) {
    final resolvedPhaseId = _resolvePhaseIdForActor(actorId, phaseId);

    batch(() {
      final actorIndex =
          timeline.value.actors.indexWhere((a) => a.id == actorId);
      if(actorIndex == -1) return;
      final actor = timeline.value.actors[actorIndex];
      final phaseIndex = actor.phases.indexWhere((p) => p.id == resolvedPhaseId);
      if(phaseIndex == -1) return;
      final phase = actor.phases[phaseIndex];

      final newTimepoint =
          TimepointModel.fromJson(jsonDecode(jsonEncode(timepoint)));

      final nextTimepointId =
          generateNextTimepointIdForPhase(actorId, resolvedPhaseId);
      newTimepoint.id = nextTimepointId;

      if(scheduleId == null) {
        final newTimepoints = [...phase.onEnter, newTimepoint];
        newTimepoints.sort((a, b) => a.startTime.compareTo(b.startTime));
        final newPhase = phase.copyWith(onEnter: newTimepoints);
        updatePhase(phase, newPhase, actorId);
      } else {
        final scheduleIndex =
            phase.schedules.indexWhere((s) => s.id == scheduleId);
        if(scheduleIndex == -1) return;
        final schedule = phase.schedules[scheduleIndex];
        final newTimepoints = [...schedule.timepoints, newTimepoint];
        newTimepoints.sort((a, b) => a.startTime.compareTo(b.startTime));
        final newSchedule = schedule.copyWith(timepoints: newTimepoints);
        updateSchedule(resolvedPhaseId, schedule, newSchedule, actorId);
      }
    });
    _saveToHistory();
  }

  void duplicateTimepoint(
      TimelineScheduleModel schedule, TimepointModel timepoint, int actorId) {
    final phaseId = _resolvePhaseIdByScheduleId(
        actorId, schedule.id, selectedPhaseId.peek());
    duplicateTimepointInPhase(actorId, phaseId, schedule.id, timepoint);
  }

  void reorderTimepointInPhase(
      int actorId, String phaseId, int? scheduleId, int oldIndex, int newIndex) {
    final resolvedPhaseId = _resolvePhaseIdForActor(actorId, phaseId);

    batch(() {
      final actorIndex =
          timeline.value.actors.indexWhere((a) => a.id == actorId);
      if(actorIndex == -1) return;
      final actor = timeline.value.actors[actorIndex];
      final phaseIndex = actor.phases.indexWhere((p) => p.id == resolvedPhaseId);
      if(phaseIndex == -1) return;
      final phase = actor.phases[phaseIndex];

      if(newIndex > oldIndex) {
        newIndex -= 1;
      }

      if(scheduleId == null) {
        final timepoints = [...phase.onEnter];
        final item = timepoints.removeAt(oldIndex);
        timepoints.insert(newIndex, item);
        final newPhase = phase.copyWith(onEnter: timepoints);
        updatePhase(phase, newPhase, actorId);
      } else {
        final scheduleIndex =
            phase.schedules.indexWhere((s) => s.id == scheduleId);
        if(scheduleIndex == -1) return;
        final schedule = phase.schedules[scheduleIndex];
        final timepoints = [...schedule.timepoints];
        final item = timepoints.removeAt(oldIndex);
        timepoints.insert(newIndex, item);
        final newSchedule = schedule.copyWith(timepoints: timepoints);
        updateSchedule(resolvedPhaseId, schedule, newSchedule, actorId);
      }
    });
    _saveToHistory();
  }

  void reorderTimepoint(
      TimelineScheduleModel schedule, int oldIndex, int newIndex, int actorId) {
    final phaseId = _resolvePhaseIdByScheduleId(
        actorId, schedule.id, selectedPhaseId.peek());
    reorderTimepointInPhase(actorId, phaseId, schedule.id, oldIndex, newIndex);
  }

  void selectActor(int id) {
    selectedActorId.value = id;
    selectedPhaseId.value = null;
    selectedScheduleId.value = null;
  }

  void selectPhase(String id) {
    selectedPhaseId.value = id;
    selectedScheduleId.value = null;
  }

  void selectSchedule(int id) {
    selectedScheduleId.value = id;
  }

  bool loadFromJson(String jsonStr) {
    try {
      final json = jsonDecode(jsonStr);
      timeline.value = TimelineModel.fromJson(json);
      _saveToHistory();
      return true;
    } catch (_) {
      return false;
    }
  }

  void setPendingJson(String json) {
    _jsonDebounceTimer?.cancel();
    _pendingJsonInput.value = json;
    _jsonDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      if(_pendingJsonInput.value.isNotEmpty) {
        loadFromJson(_pendingJsonInput.value);
        _pendingJsonInput.value = '';
      }
    });
  }

  void undo() {
    if(!canUndo.peek()) return;
    batch(() {
      _historyIndex.value--;
      timeline.value =
          TimelineModel.fromJson(jsonDecode(_history[_historyIndex.value]));
    });
  }

  void redo() {
    if(!canRedo.peek()) return;
    batch(() {
      _historyIndex.value++;
      timeline.value =
          TimelineModel.fromJson(jsonDecode(_history[_historyIndex.value]));
    });
  }

  void updateActor(int actorId, ActorModel newActor) {
    batch(() {
      final actorIndex =
          timeline.value.actors.indexWhere((a) => a.id == actorId);
      if(actorIndex == -1) return;
      final newActors = [...timeline.value.actors];
      newActors[actorIndex] = newActor;
      timeline.value = timeline.value.copyWith(actors: newActors);
    });
  }

  void addActor(
      {required String bnpcName, required int layoutId, required int hp}) {
    List<ActorModel> newActors = [...timeline.value.actors];
    if(newActors.length == 1 &&
        newActors.first.name == "Generic Actor" &&
        newActors.first.layoutId == 0) {
      newActors.clear();
    }
    int nextId = 1;
    if(newActors.isNotEmpty) {
      nextId = newActors.map((a) => a.id).reduce((a, b) => a > b ? a : b) + 1;
    }
    final actorModel = ActorModel(
        id: nextId,
        name: bnpcName,
        type: "bnpc",
        layoutId: layoutId,
        hp: hp,
        phaseList: [TimelinePhaseModel(id: 'phase_1', name: 'Initial Phase')]);
    newActors.add(actorModel);
    timeline.value = timeline.value.copyWith(actors: newActors);
    _saveToHistory();
  }

  void addPhase([ActorModel? actor]) {
    actor ??= selectedActor.value;
    int uniqueSuffix = actor.phases.length + 1;
    var phaseId = "phase_$uniqueSuffix";
    while(actor.phases.any((phase) => phase.id == phaseId)) {
      uniqueSuffix += 1;
      phaseId = "phase_$uniqueSuffix";
    }

    final newPhase = TimelinePhaseModel(
        id: phaseId, name: "Phase ${actor.phases.length + 1}");
    final newActor = actor.copyWith(phases: [...actor.phases, newPhase]);
    final newActors = List<ActorModel>.from(timeline.value.actors);
    final actorIndex =
        timeline.value.actors.indexWhere((a) => a.id == newActor.id);
    newActors[actorIndex] = newActor;
    timeline.value = timeline.value.copyWith(actors: newActors);
    _saveToHistory();
  }

  void removePhase(TimelinePhaseModel phase, int actorId) {
    final actorIndex = timeline.value.actors.indexWhere((a) => a.id == actorId);
    if(actorIndex == -1) return;
    final actor = timeline.value.actors[actorIndex];
    if(actor.phases.length <= 1) {
      return;
    }
    final newPhases = actor.phases.where((p) => p.id != phase.id).toList();
    final newActor = actor.copyWith(phases: newPhases);
    final newActors = [...timeline.value.actors];
    newActors[actorIndex] = newActor;
    timeline.value = timeline.value.copyWith(actors: newActors);
    _saveToHistory();
  }

  void duplicatePhase(TimelinePhaseModel phase, int actorId) {
    batch(() {
      final actorIndex =
          timeline.value.actors.indexWhere((a) => a.id == actorId);
      if(actorIndex == -1) return;
      final actor = timeline.value.actors[actorIndex];
      int uniqueSuffix = actor.phases.length + 1;
      var newId = "phase_$uniqueSuffix";
      while(actor.phases.any((phaseItem) => phaseItem.id == newId)) {
        uniqueSuffix += 1;
        newId = "phase_$uniqueSuffix";
      }

      final copy = TimelinePhaseModel.fromJson({
        ...jsonDecode(jsonEncode(phase.toJson())) as Map<String, dynamic>,
        'id': newId,
        'name': '${phase.name} (copy)',
      });
      final newActor = actor.copyWith(phases: [...actor.phases, copy]);
      final newActors = [...timeline.value.actors];
      newActors[actorIndex] = newActor;
      timeline.value = timeline.value.copyWith(actors: newActors);
    });
    _saveToHistory();
  }

  void reorderPhase(ActorModel actor, int oldIndex, int newIndex) {
    batch(() {
      final phases = [...actor.phases];
      if(newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = phases.removeAt(oldIndex);
      phases.insert(newIndex, item);
      final newActor = actor.copyWith(phases: phases);
      final actorIndex =
          timeline.value.actors.indexWhere((a) => a.id == actor.id);
      if(actorIndex == -1) return;
      final newActors = [...timeline.value.actors];
      newActors[actorIndex] = newActor;
      timeline.value = timeline.value.copyWith(actors: newActors);
    });
    _saveToHistory();
  }

  void updatePhase(
      TimelinePhaseModel oldPhase, TimelinePhaseModel newPhase, int actorId) {
    final actorIndex = timeline.value.actors.indexWhere((a) => a.id == actorId);
    if(actorIndex == -1) return;
    final actor = timeline.value.actors[actorIndex];
    final phaseIndex = actor.phases.indexWhere((p) => p.id == oldPhase.id);
    if(phaseIndex == -1) return;
    final newPhases = [...actor.phases];
    newPhases[phaseIndex] = newPhase;
    final newActor = actor.copyWith(phases: newPhases);
    final newActors = [...timeline.value.actors];
    newActors[actorIndex] = newActor;
    timeline.value = timeline.value.copyWith(actors: newActors);
  }

  void addScheduleToPhase(String phaseId, [ActorModel? actor]) {
    actor ??= selectedActor.value;
    final phaseIndex = actor.phases.indexWhere((p) => p.id == phaseId);
    if(phaseIndex == -1) return;
    final phase = actor.phases[phaseIndex];
    final maxScheduleId = actor.phases
        .expand((phaseItem) => phaseItem.schedules)
        .fold<int>(
            0, (maxId, schedule) => schedule.id > maxId ? schedule.id : maxId);
    final newSchedule = TimelineScheduleModel(
        id: maxScheduleId + 1, name: "Schedule ${phase.schedules.length + 1}");
    final newPhase =
        phase.copyWith(schedules: [...phase.schedules, newSchedule]);
    updatePhase(phase, newPhase, actor.id);
    _saveToHistory();
  }

  void addSchedule([ActorModel? actor]) {
    actor ??= selectedActor.value;
    final phaseId = _resolvePhaseIdForActor(actor.id, selectedPhaseId.peek());
    addScheduleToPhase(phaseId, actor);
  }

  void removeScheduleFromPhase(
      String phaseId, TimelineScheduleModel schedule, int actorId) {
    final actorIndex = timeline.value.actors.indexWhere((a) => a.id == actorId);
    if(actorIndex == -1) return;
    final actor = timeline.value.actors[actorIndex];
    final phaseIndex = actor.phases.indexWhere((p) => p.id == phaseId);
    if(phaseIndex == -1) return;
    final phase = actor.phases[phaseIndex];
    final newSchedules =
        phase.schedules.where((s) => s.id != schedule.id).toList();
    final newPhase = phase.copyWith(schedules: newSchedules);
    updatePhase(phase, newPhase, actorId);
    _saveToHistory();
  }

  void removeSchedule(TimelineScheduleModel schedule, int actorId) {
    final phaseId = _resolvePhaseIdByScheduleId(
        actorId, schedule.id, selectedPhaseId.peek());
    removeScheduleFromPhase(phaseId, schedule, actorId);
  }

  void duplicateScheduleInPhase(
      String phaseId, TimelineScheduleModel schedule, int actorId) {
    batch(() {
      final actorIndex =
          timeline.value.actors.indexWhere((a) => a.id == actorId);
      if(actorIndex == -1) return;
      final actor = timeline.value.actors[actorIndex];
      final phaseIndex = actor.phases.indexWhere((p) => p.id == phaseId);
      if(phaseIndex == -1) return;
      final phase = actor.phases[phaseIndex];
      final maxScheduleId = actor.phases
          .expand((phaseItem) => phaseItem.schedules)
          .fold<int>(
              0,
              (maxId, scheduleItem) =>
                  scheduleItem.id > maxId ? scheduleItem.id : maxId);
      final newId = maxScheduleId + 1;
      final copy = TimelineScheduleModel.fromJson({
        ...jsonDecode(jsonEncode(schedule.toJson())) as Map<String, dynamic>,
        'id': newId,
        'name': '${schedule.name} (copy)',
      });
      final newPhase = phase.copyWith(schedules: [...phase.schedules, copy]);
      updatePhase(phase, newPhase, actorId);
    });
    _saveToHistory();
  }

  void duplicateSchedule(TimelineScheduleModel schedule, int actorId) {
    final phaseId = _resolvePhaseIdByScheduleId(
        actorId, schedule.id, selectedPhaseId.peek());
    duplicateScheduleInPhase(phaseId, schedule, actorId);
  }

  void reorderScheduleInPhase(
      String phaseId, int actorId, int oldIndex, int newIndex) {
    batch(() {
      final actorIndex =
          timeline.value.actors.indexWhere((a) => a.id == actorId);
      if(actorIndex == -1) return;
      final phaseIndex = timeline.value.actors[actorIndex].phases
          .indexWhere((p) => p.id == phaseId);
      if(phaseIndex == -1) return;
      final phase = timeline.value.actors[actorIndex].phases[phaseIndex];
      final schedules = [...phase.schedules];
      if(newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = schedules.removeAt(oldIndex);
      schedules.insert(newIndex, item);
      final newPhase = phase.copyWith(schedules: schedules);
      updatePhase(phase, newPhase, actorId);
    });
    _saveToHistory();
  }

  void reorderTriggersInPhase(
      int actorId, String phaseId, int oldIndex, int newIndex) {
    final actorIndex = timeline.value.actors.indexWhere((a) => a.id == actorId);
    if(actorIndex == -1) return;

    final actor = timeline.value.actors[actorIndex];
    final phaseIndex = actor.phases.indexWhere((p) => p.id == phaseId);
    if(phaseIndex == -1) return;

    final phase = actor.phases[phaseIndex];
    final triggers = [...phase.triggers];

    if(newIndex > oldIndex) {
      newIndex -= 1;
    }

    final item = triggers.removeAt(oldIndex);
    triggers.insert(newIndex, item);

    final newPhase = phase.copyWith(triggers: triggers);
    updatePhase(phase, newPhase, actorId);
    _saveToHistory();
  }

  void reorderSchedule(ActorModel actor, int oldIndex, int newIndex) {
    final phaseId = _resolvePhaseIdForActor(actor.id, selectedPhaseId.peek());
    reorderScheduleInPhase(phaseId, actor.id, oldIndex, newIndex);
  }

  void updateSchedule(String phaseId, TimelineScheduleModel oldSchedule,
      TimelineScheduleModel newSchedule, int actorId) {
    final resolvedPhaseId = _resolvePhaseIdForActor(actorId, phaseId);

    final actorIndex = timeline.value.actors.indexWhere((a) => a.id == actorId);
    if(actorIndex == -1) return;
    final actor = timeline.value.actors[actorIndex];
    final phaseIndex = actor.phases.indexWhere((p) => p.id == resolvedPhaseId);
    if(phaseIndex == -1) return;
    final phase = actor.phases[phaseIndex];
    final scheduleIndex =
        phase.schedules.indexWhere((s) => s.id == oldSchedule.id);
    if(scheduleIndex == -1) return;
    final newSchedules = [...phase.schedules];
    newSchedules[scheduleIndex] = newSchedule;
    final newPhase = phase.copyWith(schedules: newSchedules);
    updatePhase(phase, newPhase, actorId);
  }

  void updateScheduleById(TimelineScheduleModel oldSchedule,
      TimelineScheduleModel newSchedule, int actorId) {
    final phaseId = _resolvePhaseIdByScheduleId(
        actorId, oldSchedule.id, selectedPhaseId.peek());
    updateSchedule(phaseId, oldSchedule, newSchedule, actorId);
  }

  void _saveToHistory() {
    if(_historyIndex.value < _history.length - 1) {
      _history.removeRange(_historyIndex.value + 1, _history.length);
    }
    final json = jsonEncode(timeline.value.toJson());
    _history.add(json);
    _historyIndex.value++;
    while(_history.length > 50) {
      _history.removeAt(0);
      _historyIndex.value--;
    }
  }

  void _scheduleAutosave(String json) {
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(const Duration(seconds: 1), () async {
      final autosaveBox =
          StorageHelper().getTable(StorageTable.autosaveTimeline);
      final timestamp = DateTime.now();
      await autosaveBox.put(timestamp.millisecondsSinceEpoch.toString(), json);
      lastAutosave.value = timestamp;
    });
  }

  ActorModel _replaceTimepoint(ActorModel actor, String phaseId,
      int? scheduleId, int timepointId, TimepointModel newTp) {
    final phaseIndex = actor.phases.indexWhere((p) => p.id == phaseId);
    if(phaseIndex == -1) return actor;
    final phase = actor.phases[phaseIndex];
    if(scheduleId == null) {
      final timepointIndex =
          phase.onEnter.indexWhere((t) => t.id == timepointId);
      if(timepointIndex == -1) return actor;
      final newTimepoints = [...phase.onEnter];
      newTimepoints[timepointIndex] = newTp;
      newTimepoints.sort((a, b) => a.startTime.compareTo(b.startTime));
      final newPhase = phase.copyWith(onEnter: newTimepoints);
      final newPhases = [...actor.phases];
      newPhases[phaseIndex] = newPhase;
      return actor.copyWith(phases: newPhases);
    } else {
      final scheduleIndex =
          phase.schedules.indexWhere((s) => s.id == scheduleId);
      if(scheduleIndex == -1) return actor;
      final schedule = phase.schedules[scheduleIndex];
      final timepointIndex =
          schedule.timepoints.indexWhere((s) => s.id == timepointId);
      if(timepointIndex == -1) return actor;
      final newTimepoints = [...schedule.timepoints];
      newTimepoints[timepointIndex] = newTp;
      newTimepoints.sort((a, b) => a.startTime.compareTo(b.startTime));
      final newSchedule = schedule.copyWith(timepoints: newTimepoints);
      final newSchedules = [...phase.schedules];
      newSchedules[scheduleIndex] = newSchedule;
      final newPhase = phase.copyWith(schedules: newSchedules);
      final newPhases = [...actor.phases];
      newPhases[phaseIndex] = newPhase;
      return actor.copyWith(phases: newPhases);
    }
  }

  int _generateConditionId() {
    final allConditions = timeline.value.actors
        .expand((actor) => actor.phases)
        .expand((phase) => phase.triggers)
        .toList();

    if(allConditions.isEmpty) {
      return 1;
    }

    return allConditions.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  void updateCondition(
      int actorId, String phaseId, int conditionId, TriggerModel newCondition) {
    final resolvedPhaseId = _resolvePhaseIdForActor(actorId, phaseId);

    batch(() {
      final actorIndex =
          timeline.value.actors.indexWhere((a) => a.id == actorId);
      if(actorIndex == -1) return;
      final actor = timeline.value.actors[actorIndex];
      final phaseIndex = actor.phases.indexWhere((p) => p.id == resolvedPhaseId);
      if(phaseIndex == -1) return;
      final phase = actor.phases[phaseIndex];
      final conditionIndex =
          phase.triggers.indexWhere((c) => c.id == conditionId);
      if(conditionIndex == -1) return;
      final newConditions = [...phase.triggers];
      newConditions[conditionIndex] = newCondition;
      final newPhase = phase.copyWith(triggers: newConditions);
      updatePhase(phase, newPhase, actorId);
    });
    _saveToHistory();
  }

  void updateConditionForSelected(int conditionId, TriggerModel newCondition) {
    final actorId = selectedActorId.peek() ?? timeline.value.actors.first.id;
    final phaseId = _resolvePhaseIdForActor(actorId, selectedPhaseId.peek());
    updateCondition(actorId, phaseId, conditionId, newCondition);
  }

  void removeCondition(int actorId, String phaseId, int conditionId) {
    final resolvedPhaseId = _resolvePhaseIdForActor(actorId, phaseId);

    batch(() {
      final actorIndex =
          timeline.value.actors.indexWhere((a) => a.id == actorId);
      if(actorIndex == -1) return;
      final actor = timeline.value.actors[actorIndex];
      final phaseIndex = actor.phases.indexWhere((p) => p.id == resolvedPhaseId);
      if(phaseIndex == -1) return;
      final phase = actor.phases[phaseIndex];
      final newConditions =
          phase.triggers.where((c) => c.id != conditionId).toList();
      final newPhase = phase.copyWith(triggers: newConditions);
      updatePhase(phase, newPhase, actorId);
    });
    _saveToHistory();
  }

  void removeConditionForSelected(int conditionId) {
    final actorId = selectedActorId.peek() ?? timeline.value.actors.first.id;
    final phaseId = _resolvePhaseIdForActor(actorId, selectedPhaseId.peek());
    removeCondition(actorId, phaseId, conditionId);
  }

  void addCondition(
      [int? actorIdMaybe, String? phaseIdMaybe, TriggerModel? condition]) {
    final actorId = actorIdMaybe ??
        selectedActorId.peek() ??
        timeline.value.actors.first.id;
    final phaseId = _resolvePhaseIdForActor(
        actorId, phaseIdMaybe ?? selectedPhaseId.peek());

    final actorIndex = timeline.value.actors.indexWhere((a) => a.id == actorId);
    if(actorIndex == -1) return;
    final actor = timeline.value.actors[actorIndex];
    final phaseIndex = actor.phases.indexWhere((p) => p.id == phaseId);
    if(phaseIndex == -1) return;
    final phase = actor.phases[phaseIndex];
    final nextPhaseId = (phaseIndex + 1) < actor.phases.length
        ? actor.phases[phaseIndex + 1].id
        : phase.id;

    condition ??= TriggerModel(
      id: _generateConditionId(),
      condition: ConditionType.combatState,
      paramData: CombatStateConditionModel(
          combatState: ActorCombatState.combat, sourceActor: actor.name),
      action: TriggerActionModel(type: 'transitionPhase', target: nextPhaseId),
      description: "",
    );

    if(condition.action == null) {
      condition = condition.copyWith(
        action:
            TriggerActionModel(type: 'transitionPhase', target: nextPhaseId),
      );
    }

    final newConditions = [...phase.triggers, condition];
    final newPhase = phase.copyWith(triggers: newConditions);
    updatePhase(phase, newPhase, actorId);
    _saveToHistory();
  }

  int _generateSelectorId() {
    if(timeline.value.selectors.isEmpty) return 1;
    return timeline.value.selectors
            .map((s) => s.id)
            .reduce((a, b) => a > b ? a : b) +
        1;
  }

  void updateSelector(int selectorId, SelectorModel newSelector) {
    batch(() {
      final selectorIndex =
          timeline.value.selectors.indexWhere((s) => s.id == selectorId);
      if(selectorIndex == -1) return;
      final newSelectors = [...timeline.value.selectors];
      newSelectors[selectorIndex] = newSelector;
      timeline.value = timeline.value.copyWith(selectors: newSelectors);
    });
    _saveToHistory();
  }

  void removeSelector(int selectorId) {
    batch(() {
      final newSelectors =
          timeline.value.selectors.where((s) => s.id != selectorId).toList();
      timeline.value = timeline.value.copyWith(selectors: newSelectors);
    });
    _saveToHistory();
  }

  void addSelector([SelectorModel? selector]) {
    selector ??= SelectorModel(
        id: _generateSelectorId(),
        name: "Selector ${timeline.value.selectors.length + 1}",
        count: 1,
        description: "",
        fillRandomEntries: false,
        filterList: [
          SelectorFilterModel(type: SelectorFilterType.player),
        ]);
    final newSelectors = [...timeline.value.selectors, selector];
    timeline.value = timeline.value.copyWith(selectors: newSelectors);
    _saveToHistory();
  }

  void reorderSelector(int oldIndex, int newIndex) {
    batch(() {
      final selectors = [...timeline.value.selectors];
      if(newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = selectors.removeAt(oldIndex);
      selectors.insert(newIndex, item);
      timeline.value = timeline.value.copyWith(selectors: selectors);
    });
    _saveToHistory();
  }

  bool _validateTimeline(TimelineModel timeline) {
    if(timeline.actors.isEmpty) return false;
    return timeline.actors.every((a) => a.phases.isNotEmpty);
  }

  static TimelineModel _createDefaultTimeline() {
    final timeline = TimelineModel(name: "Brand new timeline");
    timeline.addNewActor(bnpcName: "Generic Actor", layoutId: 0, hp: 0xFF14);
    return timeline;
  }

  void createNewTimeline() {
    timeline.value = _createDefaultTimeline();
    _history.clear();
    _historyIndex.value = -1;
    _saveToHistory();
  }

  void dispose() {
    _autosaveTimer?.cancel();
    _jsonDebounceTimer?.cancel();
  }
}
