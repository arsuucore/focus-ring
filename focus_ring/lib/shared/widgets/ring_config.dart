library;

enum TapResult { perfect, good, miss }

class RingConfig {
  const RingConfig({
    this.ringDiameter           = 220.0,
    this.trackWidth             = 28.0,
    this.perfectWindowFraction  = 0.07,
    this.goodWindowFraction     = 0.16,
    this.rotationDurationMs     = 1100,
  });

  final double ringDiameter;
  final double trackWidth;
  final double perfectWindowFraction;
  final double goodWindowFraction;
  final int    rotationDurationMs;

  /// Returns a faster config based on combo level (1-8).
  RingConfig withCombo(int combo) {
    final speedBoost = (combo * 0.07).clamp(0.0, 0.5);
    final newDuration = (rotationDurationMs * (1.0 - speedBoost)).round().clamp(600, rotationDurationMs);
    return RingConfig(
      ringDiameter:          ringDiameter,
      trackWidth:            trackWidth,
      perfectWindowFraction: perfectWindowFraction,
      goodWindowFraction:    goodWindowFraction,
      rotationDurationMs:    newDuration,
    );
  }
}
