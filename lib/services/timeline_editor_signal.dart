import 'dart:async';
import 'dart:convert';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_schedule_model.dart';
import 'package:sapphire_editor/services/storage_helper.dart';

class TimelineEditorSignal {
  final Signal<TimelineModel> timeline;

  final Signal<int> selectedActorIndex;
  final Signal<int> selectedScheduleIndex;

  late final Computed<ActorModel> selectedActor;
  late final Computed<TimelineScheduleModel> selectedSchedule;

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
      : timeline = signal<TimelineModel>(initialTimeline ?? _createDefaultTimeline()),
        selectedActorIndex = signal(0),
        selectedScheduleIndex = signal(0),
        _historyIndex = signal(-1),
        lastAutosave = signal<DateTime?>(null),
        _pendingJsonInput = signal('') {
    selectedActor = computed(() {
      final actors = timeline.value.actors;
      if (actors.isEmpty) {
        throw StateError("Timeline must contain at least one actor");
      }

      final index = selectedActorIndex.value
          .clamp(0, actors.length - 1);

      return actors[index];
    });

    selectedSchedule = computed(() {
      final schedules = selectedActor.value.schedules;

      if (schedules.isEmpty) {
        throw StateError("Actor must contain at least one schedule");
      }

      final index = selectedScheduleIndex.value
          .clamp(0, schedules.length - 1);

      return schedules[index];
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
  }

  void updateTimepoint(ActorModel actor, TimelineScheduleModel schedule, TimepointModel oldTimepoint, TimepointModel newTimepoint) {
    _saveToHistory();

    final newActor = _replaceTimepoint(actor, schedule, oldTimepoint, newTimepoint);
    final actorIndex = timeline.value.actors.indexOf(actor);
    
    if (actorIndex == -1) return;
    
    final newActors = [...timeline.value.actors];
    newActors[actorIndex] = newActor;

    timeline.value = timeline.value.copyWith(actors: newActors);
  }

  void addTimepoint(TimelineScheduleModel schedule, TimepointModel timepoint) {
    _saveToHistory();

    final newSchedule = schedule.copyWith(
      timepoints: [...schedule.timepoints, timepoint]
    );

    _updateSchedule(schedule, newSchedule);
  }

  void removeTimepoint(TimelineScheduleModel schedule, TimepointModel timepoint) {
    _saveToHistory();

    final newSchedule = schedule.copyWith(
      timepoints: schedule.timepoints.where((t) => t != timepoint).toList()
    );

    _updateSchedule(schedule, newSchedule);
  }

  void duplicateTimepoint(TimelineScheduleModel schedule, TimepointModel timepoint) {
    _saveToHistory();

    final newTimepoint = TimepointModel.fromJson(jsonDecode(jsonEncode(timepoint)));
    final newSchedule = schedule.copyWith(
      timepoints: [...schedule.timepoints, newTimepoint]
    );

    _updateSchedule(schedule, newSchedule);
  }

  void reorderTimepoint(TimelineScheduleModel schedule, int oldIndex, int newIndex) {
    _saveToHistory();

    final timepoints = [...schedule.timepoints];
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = timepoints.removeAt(oldIndex);
    timepoints.insert(newIndex, item);

    final newSchedule = schedule.copyWith(timepoints: timepoints);
    _updateSchedule(schedule, newSchedule);
  }

  void selectActor(int index) {
    selectedActorIndex.value = index;
    selectedScheduleIndex.value = 0;
  }

  void selectSchedule(int index) {
    selectedScheduleIndex.value = index;
  }

  bool loadFromJson(String jsonStr) {
    try {
      final json = jsonDecode(jsonStr);
      _saveToHistory();
      timeline.value = TimelineModel.fromJson(json);
      return true;
    } catch (_) {
      return false;
    }
  }

  void setPendingJson(String json) {
    _jsonDebounceTimer?.cancel();
    _pendingJsonInput.value = json;
    
    _jsonDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_pendingJsonInput.value.isNotEmpty) {
        loadFromJson(_pendingJsonInput.value);
        _pendingJsonInput.value = '';
      }
    });
  }

  void undo() {
    if (!canUndo.value) return;

    _historyIndex.value--;
    timeline.value = TimelineModel.fromJson(jsonDecode(_history[_historyIndex.value]));
  }

  void redo() {
    if (!canRedo.value) return;

    _historyIndex.value++;
    timeline.value = TimelineModel.fromJson(jsonDecode(_history[_historyIndex.value]));
  }

  void addSchedule([ActorModel? actor]) {
    _saveToHistory();
    actor ??= selectedActor.value;

    final newSchedule = TimelineScheduleModel(id: actor.schedules.length + 1, name: "Schedule ${actor.schedules.length + 1}");
    final newActor = actor.copyWith(schedules: [...actor.schedules, newSchedule]);

    final newActors = List<ActorModel>.from(timeline.value.actors);
    final actorIndex = timeline.value.actors.indexOf(actor);
    newActors[actorIndex] = newActor;

    timeline.value = timeline.value.copyWith(actors: newActors);
  }

  void reorderSchedule(ActorModel actor, int oldIndex, int newIndex) {
    _saveToHistory();

    final schedules = [...actor.schedules];
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = schedules.removeAt(oldIndex);
    schedules.insert(newIndex, item);

    final newActor = actor.copyWith(schedules: schedules);

    final actorIndex = timeline.value.actors.indexOf(actor);
    if (actorIndex == -1) return;
    
    final newActors = [...timeline.value.actors];
    newActors[actorIndex] = newActor;

    timeline.value = timeline.value.copyWith(actors: newActors);
  }

  void _saveToHistory() {
    if (_historyIndex.value < _history.length - 1) {
      _history.removeRange(_historyIndex.value + 1, _history.length);
    }

    final json = jsonEncode(timeline.value.toJson());
    _history.add(json);
    _historyIndex.value++;

    while (_history.length > 50) {
      _history.removeAt(0);
      _historyIndex.value--;
    }
  }

  void _scheduleAutosave(String json) {
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(const Duration(seconds: 1), () async {
      final autosaveBox = StorageHelper().getTable(StorageTable.autosaveTimeline);
      final timestamp = DateTime.now();
      await autosaveBox.put(timestamp.millisecondsSinceEpoch.toString(), json);
      lastAutosave.value = timestamp;
    });
  }

  void _updateSchedule(TimelineScheduleModel oldSchedule, TimelineScheduleModel newSchedule) {
    final actorIndex = timeline.value.actors.indexOf(selectedActor.value);
    
    if (actorIndex == -1) return;
    
    final scheduleIndex = selectedActor.value.schedules.indexOf(oldSchedule);
    if (scheduleIndex == -1) return;

    final newSchedules = [...selectedActor.value.schedules];
    newSchedules[scheduleIndex] = newSchedule;
    
    final newActor = selectedActor.value.copyWith(schedules: newSchedules);
    final newActors = [...timeline.value.actors];
    newActors[actorIndex] = newActor;

    timeline.value = timeline.value.copyWith(actors: newActors);
  }

  ActorModel _replaceTimepoint(ActorModel actor, TimelineScheduleModel schedule, TimepointModel oldTp, TimepointModel newTp) {
    final scheduleIndex = actor.schedules.indexOf(schedule);
    
    if (scheduleIndex == -1) return actor;
    
    final timepointIndex = schedule.timepoints.indexOf(oldTp);
    if (timepointIndex == -1) return actor;
    
    final newTimepoints = [...schedule.timepoints];
    newTimepoints[timepointIndex] = newTp;
    
    final newSchedules = [...actor.schedules];
    newSchedules[scheduleIndex] = schedule.copyWith(timepoints: newTimepoints);

    return actor.copyWith(schedules: newSchedules);
  }

  bool _validateTimeline(TimelineModel timeline) {
    if (timeline.actors.isEmpty) return false;
    return timeline.actors.every((a) => a.schedules.isNotEmpty);
  }

  static TimelineModel _createDefaultTimeline() {
    final timeline = TimelineModel(name: "Brand new timeline");
    timeline.addNewActor(bnpcName: "Ifrit", layoutId: 4126276, hp: 13884);
    timeline.addNewActor(bnpcName: "Ifrit Control", layoutId: 4126284, hp: 445);
    timeline.addNewActor(bnpcName: "Ifrit Nail 1", layoutId: 4126281, hp: 445);
    timeline.addNewSchedule(timeline.actors.first);
    timeline.addNewCondition();
    return timeline;
  }

  void dispose() {
    _autosaveTimer?.cancel();
    _jsonDebounceTimer?.cancel();
  }
}
