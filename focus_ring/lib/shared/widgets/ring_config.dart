library;

enum TapResult { perfect, good, miss }

class RingConfig {
  const RingConfig({
    this.ringDiameter           = 220.0,
    this.trackWidth             = 28.0,
    this.perfectWindowFraction  = 0.10,
    this.goodWindowFraction     = 0.22,
    this.rotationDurationMs     = 1800,
  });

  final double ringDiameter;
  final double trackWidth;
  final double perfectWindowFraction;
  final double goodWindowFraction;
  final int    rotationDurationMs;
}
