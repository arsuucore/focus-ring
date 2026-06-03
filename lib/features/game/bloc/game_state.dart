import 'package:equatable/equatable.dart';
import '../../../core/models/game_session.dart';
import '../../../core/models/tap_event.dart';
import '../../../shared/widgets/ring_config.dart';

enum GamePhase { idle, countdown, playing, finished }

class GameState extends Equatable {
  const GameState({
    required this.phase,
    required this.mode,
    required this.score,
    required this.combo,
    required this.bestCombo,
    required this.lives,
    required this.maxLives,
    required this.countdownCount,
    required this.taps,
    required this.lastResult,
    this.session,
  });

  factory GameState.initial({int maxLives = 3}) => GameState(
    phase:          GamePhase.idle,
    mode:           '',
    score:          0,
    combo:          0,
    bestCombo:      0,
    lives:          maxLives,
    maxLives:       maxLives,
    countdownCount: 3,
    taps:           const [],
    lastResult:     null,
    session:        null,
  );

  final GamePhase      phase;
  final String         mode;
  final int            score;
  final int            combo;
  final int            bestCombo;
  final int            lives;
  final int            maxLives;
  final int            countdownCount;
  final List<TapEvent> taps;
  final TapResult?     lastResult;
  final GameSession?   session;

  int get perfects => taps.where((t) => t.result == TapResult.perfect).length;
  int get goods    => taps.where((t) => t.result == TapResult.good).length;
  int get misses   => taps.where((t) => t.result == TapResult.miss).length;

  GameState copyWith({
    GamePhase?               phase,
    String?                  mode,
    int?                     score,
    int?                     combo,
    int?                     bestCombo,
    int?                     lives,
    int?                     maxLives,
    int?                     countdownCount,
    List<TapEvent>?          taps,
    TapResult? Function()?   lastResult,
    GameSession? Function()? session,
  }) {
    return GameState(
      phase:          phase          ?? this.phase,
      mode:           mode           ?? this.mode,
      score:          score          ?? this.score,
      combo:          combo          ?? this.combo,
      bestCombo:      bestCombo      ?? this.bestCombo,
      lives:          lives          ?? this.lives,
      maxLives:       maxLives       ?? this.maxLives,
      countdownCount: countdownCount ?? this.countdownCount,
      taps:           taps           ?? this.taps,
      lastResult:     lastResult  != null ? lastResult()  : this.lastResult,
      session:        session     != null ? session()     : this.session,
    );
  }

  @override
  List<Object?> get props => [
    phase, mode, score, combo, bestCombo,
    lives, maxLives, countdownCount, taps, lastResult, session,
  ];
}
