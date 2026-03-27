enum SimulatedEventType {
  info,
  manual,
  phaseEnter,
  phaseExit,
  phaseTransition,
  triggerMatched,
  timepoint,
}

class SimulatedEvent {
  final int timestampMs;
  final SimulatedEventType type;
  final int actorId;
  final String actorName;
  final int phaseId;
  final String phaseName;
  final int? scheduleId;
  final int? triggerId;
  final int? timepointId;
  final String message;

  const SimulatedEvent({
    required this.timestampMs,
    required this.type,
    required this.actorId,
    required this.actorName,
    required this.phaseId,
    required this.phaseName,
    required this.message,
    this.scheduleId,
    this.triggerId,
    this.timepointId,
  });

  String get timeLabel {
    final totalSeconds = timestampMs ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final ms = timestampMs % 1000;
    final secLabel = seconds.toString().padLeft(2, '0');
    final msLabel = ms.toString().padLeft(3, '0');
    return '$minutes:$secLabel.$msLabel';
  }
}
