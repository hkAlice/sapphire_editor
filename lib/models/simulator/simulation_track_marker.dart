import 'package:sapphire_editor/models/simulator/simulated_event.dart';

class SimulationTrackMarker {
  final int timestampMs;
  final String label;
  final SimulatedEventType type;
  final bool isPast;

  const SimulationTrackMarker({
    required this.timestampMs,
    required this.label,
    required this.type,
    required this.isPast,
  });
}
