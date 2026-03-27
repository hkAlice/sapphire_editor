class PlaybackConfig {
  final double dpsPctPerSecond;
  final double speedMultiplier;
  final int tickIntervalMs;

  const PlaybackConfig({
    this.dpsPctPerSecond = 0.5,
    this.speedMultiplier = 1.0,
    this.tickIntervalMs = 100,
  });

  PlaybackConfig copyWith({
    double? dpsPctPerSecond,
    double? speedMultiplier,
    int? tickIntervalMs,
  }) {
    return PlaybackConfig(
      dpsPctPerSecond: dpsPctPerSecond ?? this.dpsPctPerSecond,
      speedMultiplier: speedMultiplier ?? this.speedMultiplier,
      tickIntervalMs: tickIntervalMs ?? this.tickIntervalMs,
    );
  }
}
