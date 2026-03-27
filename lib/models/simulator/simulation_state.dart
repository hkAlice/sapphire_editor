import 'package:sapphire_editor/models/simulator/playback_config.dart';
import 'package:sapphire_editor/models/simulator/simulated_event.dart';
import 'package:sapphire_editor/models/simulator/simulation_track_marker.dart';
import 'package:sapphire_editor/models/timeline/condition/types/combatstate_condition_model.dart';

class ActorSimulationViewState {
  final int actorId;
  final String actorName;
  final double hpPct;
  final ActorCombatState combatState;
  final int currentPhaseId;
  final String currentPhaseName;
  final int phaseElapsedMs;

  const ActorSimulationViewState({
    required this.actorId,
    required this.actorName,
    required this.hpPct,
    required this.combatState,
    required this.currentPhaseId,
    required this.currentPhaseName,
    required this.phaseElapsedMs,
  });
}

class SimulationState {
  final bool isPlaying;
  final bool isInSyncWithEditor;
  final String syncStatus;
  final int elapsedMs;
  final PlaybackConfig config;
  final List<ActorSimulationViewState> actors;
  final List<SimulatedEvent> events;
  final List<SimulationTrackMarker> trackMarkers;

  const SimulationState({
    required this.isPlaying,
    required this.isInSyncWithEditor,
    required this.syncStatus,
    required this.elapsedMs,
    required this.config,
    required this.actors,
    required this.events,
    required this.trackMarkers,
  });
}
