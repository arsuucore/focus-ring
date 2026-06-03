import 'package:equatable/equatable.dart';
import 'tap_event.dart';
import '../../shared/widgets/ring_config.dart';

class GameSession extends Equatable {
  const GameSession({
    required this.id,
    required this.mode,
    required this.startedAt,
    required this.duration,
    required this.taps,
    required this.score,
    required this.bestCombo,
  });

  final String id;
  final String mode;
  final DateTime startedAt;
  final Duration duration;
  final List<TapEvent> taps;
  final int score;
  final int bestCombo;

  int get perfects => taps.where((t) => t.result == TapResult.perfect).length;
  int get goods    => taps.where((t) => t.result == TapResult.good).length;
  int get misses   => taps.where((t) => t.result == TapResult.miss).length;

  double get accuracy {
    final hits  = perfects + goods;
    final total = taps.length;
    return total == 0 ? 0.0 : hits / total;
  }

  @override
  List<Object?> get props =>
      [id, mode, startedAt, duration, taps, score, bestCombo];
}
