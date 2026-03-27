import 'dart:async';
import 'dart:convert';

import 'package:signals_flutter/signals_flutter.dart';
import 'package:sapphire_editor/models/simulator/simulation_state.dart';
import 'package:sapphire_editor/models/timeline/condition/types/combatstate_condition_model.dart';
import 'package:sapphire_editor/models/timeline/condition/types/varequals_condition_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_phase_model.dart';
import 'package:sapphire_editor/services/simulation_runner.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';

class SimulatorSignal {
  static const Duration _tickInterval = Duration(milliseconds: 100);
  static const Duration _editorSyncInterval = Duration(milliseconds: 500);

  final TimelineEditorSignal sourceSignal;
  late SimulationRunner _runner;

  late final Signal<SimulationState> state;
  final Signal<int?> selectedActorId;

  Timer? _playbackTimer;
  Timer? _editorSyncTimer;

  String _lastKnownSourceJson = '';

  SimulatorSignal(this.sourceSignal) : selectedActorId = signal<int?>(null) {
    _runner = SimulationRunner(sourceSignal.timeline.peek());
    _runner.setSyncStatus(
      isInSync: true,
      status: 'Synchronized with timeline editor.',
    );

    _lastKnownSourceJson = sourceSignal.jsonOutput.peek();

    state = signal<SimulationState>(_runner.snapshot());
    if(state.value.actors.isNotEmpty) {
      selectedActorId.value = state.value.actors.first.actorId;
    }

    _playbackTimer = Timer.periodic(_tickInterval, (_) {
      if(!state.peek().isPlaying) {
        return;
      }

      _syncFromEditorIfChanged();
      _runner.tick(_tickInterval.inMilliseconds);
      _publishState();
    });

    _editorSyncTimer = Timer.periodic(_editorSyncInterval, (_) {
      _syncFromEditorIfChanged();
    });
  }

  void dispose() {
    _playbackTimer?.cancel();
    _editorSyncTimer?.cancel();
  }

  void play() {
    _runner.setPlaying(true);
    _publishState();
  }

  void pause() {
    _runner.setPlaying(false);
    _publishState();
  }

  void togglePlay() {
    if(state.peek().isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void stepForward([int milliseconds = 1000]) {
    final safeMillis = milliseconds.clamp(1, 30000);
    _runner.tick(safeMillis);
    _publishState();
  }

  void reset() {
    _runner.reset();
    _runner.setSyncStatus(
      isInSync: true,
      status: 'Synchronized with timeline editor.',
    );
    _publishState();
  }

  void resyncNow() {
    _syncFromEditorIfChanged(force: true);
  }

  void setSpeedMultiplier(double value) {
    _runner.setSpeedMultiplier(value);
    _publishState();
  }

  void setDpsPctPerSecond(double value) {
    _runner.setDpsPctPerSecond(value);
    _publishState();
  }

  void selectActor(int? actorId) {
    selectedActorId.value = actorId;
  }

  ActorSimulationViewState? get selectedActorState {
    final id = selectedActorId.peek();
    if(id == null) {
      return state.peek().actors.firstOrNull;
    }

    return state.peek().actors.where((item) => item.actorId == id).firstOrNull;
  }

  List<TimelinePhaseModel> phasesForSelectedActor() {
    final actor = selectedActorState;
    if(actor == null) {
      return const <TimelinePhaseModel>[];
    }

    return _runner.phasesForActor(actor.actorId);
  }

  void setSelectedActorHpPct(double value) {
    final actor = selectedActorState;
    if(actor == null) {
      return;
    }

    _runner.setActorHpPct(actor.actorId, value);
    _publishState();
  }

  void setSelectedActorCombatState(ActorCombatState value) {
    final actor = selectedActorState;
    if(actor == null) {
      return;
    }

    _runner.setActorCombatState(actor.actorId, value);
    _publishState();
  }

  void transitionSelectedActorPhase(int phaseId) {
    final actor = selectedActorState;
    if(actor == null) {
      return;
    }

    _runner.transitionActorPhase(actor.actorId, phaseId);
    _publishState();
  }

  void injectSelectedActorAction(int actionId) {
    final actor = selectedActorState;
    if(actor == null) {
      return;
    }

    _runner.injectActionCast(actorId: actor.actorId, actionId: actionId);
    _publishState();
  }

  void injectSelectedActorInterruptedAction(int actionId) {
    final actor = selectedActorState;
    if(actor == null) {
      return;
    }

    _runner.injectInterruptedAction(actorId: actor.actorId, actionId: actionId);
    _publishState();
  }

  void injectEObjInteraction(String name) {
    _runner.injectEObjInteract(name);
    _publishState();
  }

  void setSelectedActorDirectorVar(int index, int value) {
    final actor = selectedActorState;
    if(actor == null) {
      return;
    }

    _runner.setVarValue(
      actorId: actor.actorId,
      type: VarType.director,
      index: index,
      value: value,
    );
    _publishState();
  }

  void _syncFromEditorIfChanged({bool force = false}) {
    final nextJson = sourceSignal.jsonOutput.peek();
    if(!force && nextJson == _lastKnownSourceJson) {
      return;
    }

    _lastKnownSourceJson = nextJson;
    try {
      final decoded = jsonDecode(nextJson);
      final timeline = TimelineModel.fromJson(decoded as Map<String, dynamic>);
      _runner.replaceTimeline(timeline);
      _runner.setSyncStatus(
        isInSync: true,
        status: 'Synchronized with timeline editor.',
      );
    } catch (_) {
      _runner.setPlaying(false);
      _runner.setSyncStatus(
        isInSync: false,
        status:
            'Editor timeline is currently invalid JSON; using last valid snapshot.',
      );
    }

    _publishState();
  }

  void _publishState() {
    final next = _runner.snapshot();
    state.value = next;

    final currentSelection = selectedActorId.peek();
    if(next.actors.isEmpty) {
      selectedActorId.value = null;
      return;
    }

    if(currentSelection == null ||
        !next.actors.any((item) => item.actorId == currentSelection)) {
      selectedActorId.value = next.actors.first.actorId;
    }
  }
}
