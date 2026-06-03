import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../core/audio/audio_service.dart';
import '../../../core/models/game_session.dart';
import '../../../core/models/tap_event.dart';
import '../../../shared/widgets/ring_config.dart';
import 'game_event.dart';
import 'game_state.dart';

const int _kMaxCombo    = 8;
const int _kBaseScore   = 100;
const int _kPerfectBonus = 50;

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc({required int maxLives, AudioService? audio})
      : _audio = audio ?? AudioService(),
        super(GameState.initial(maxLives: maxLives)) {
    on<GameStarted>(_onStarted);
    on<GameCountdownTicked>(_onCountdownTicked);
    on<GameTapRegistered>(_onTapRegistered);
    on<GameAborted>(_onAborted);
  }

  final AudioService _audio;
  Timer?             _countdownTimer;
  DateTime?          _sessionStart;
  final _uuid = const Uuid();

  Future<void> _onStarted(GameStarted event, Emitter<GameState> emit) async {
    emit(GameState.initial(maxLives: event.maxLives).copyWith(
      phase:          GamePhase.countdown,
      mode:           event.mode,
      countdownCount: 3,
    ));
    _startCountdown();
  }

  void _onCountdownTicked(GameCountdownTicked event, Emitter<GameState> emit) {
    if (event.count > 0) {
      emit(state.copyWith(countdownCount: event.count));
    } else {
      _sessionStart = DateTime.now();
      emit(state.copyWith(phase: GamePhase.playing));
    }
  }

  void _onTapRegistered(GameTapRegistered event, Emitter<GameState> emit) {
    if (state.phase != GamePhase.playing) return;

    final result  = event.result;
    final elapsed = _sessionStart != null
        ? DateTime.now().difference(_sessionStart!)
        : Duration.zero;

    // Combo
    final int newCombo = result == TapResult.miss
        ? 0
        : (state.combo + 1).clamp(0, _kMaxCombo);
    final int newBestCombo = newCombo > state.bestCombo ? newCombo : state.bestCombo;

    // Score
    int tapScore = 0;
    if (result != TapResult.miss) {
      final int base       = result == TapResult.perfect ? _kBaseScore + _kPerfectBonus : _kBaseScore;
      final int multiplier = newCombo.clamp(1, _kMaxCombo);
      tapScore = base * multiplier;
    }

    // Lives
    final int newLives = result == TapResult.miss
        ? (state.lives - 1).clamp(0, state.maxLives)
        : state.lives;

    // Audio
    switch (result) {
      case TapResult.perfect: _audio.playPerfect(); break;
      case TapResult.good:    _audio.playGood();    break;
      case TapResult.miss:    _audio.playMiss();    break;
    }

    final newTaps = List<TapEvent>.from(state.taps)
      ..add(TapEvent(timestamp: elapsed, result: result, comboAtTap: newCombo));

    // Emit intermediate state
    final next = state.copyWith(
      score:      state.score + tapScore,
      combo:      newCombo,
      bestCombo:  newBestCombo,
      lives:      newLives,
      taps:       newTaps,
      lastResult: () => result,
    );

    if (newLives <= 0) {
      _audio.playGameOver();
      _finishSession(emit, override: next);
    } else {
      emit(next);
    }
  }

  void _onAborted(GameAborted event, Emitter<GameState> emit) {
    _cancelTimers();
    emit(GameState.initial(maxLives: state.maxLives));
  }

  void _startCountdown() {
    int count = 3;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      count--;
      add(GameCountdownTicked(count: count));
      if (count <= 0) _countdownTimer?.cancel();
    });
  }

  void _finishSession(Emitter<GameState> emit, {GameState? override}) {
    _cancelTimers();
    final s = override ?? state;
    final session = GameSession(
      id:        _uuid.v4(),
      mode:      s.mode,
      startedAt: _sessionStart ?? DateTime.now(),
      duration:  _sessionStart != null
          ? DateTime.now().difference(_sessionStart!)
          : Duration.zero,
      taps:      List.unmodifiable(s.taps),
      score:     s.score,
      bestCombo: s.bestCombo,
    );
    emit(s.copyWith(
      phase:   GamePhase.finished,
      session: () => session,
    ));
  }

  void _cancelTimers() => _countdownTimer?.cancel();

  @override
  Future<void> close() {
    _cancelTimers();
    return super.close();
  }
}
