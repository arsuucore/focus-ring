import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../core/models/game_session.dart';
import '../../../core/models/tap_event.dart';
import '../../../shared/widgets/ring_config.dart';
import 'game_event.dart';
import 'game_state.dart';

const int _kMaxCombo            = 8;
const int _kBaseScore           = 100;
const int _kPerfectBonus        = 50;
const int _kRushDurationSeconds = 10;

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc() : super(GameState.initial()) {
    on<GameStarted>(_onStarted);
    on<GameCountdownTicked>(_onCountdownTicked);
    on<GameTapRegistered>(_onTapRegistered);
    on<GameTimerTicked>(_onTimerTicked);
    on<GameAborted>(_onAborted);
  }

  Timer?    _countdownTimer;
  Timer?    _sessionTimer;
  DateTime? _sessionStart;
  final _uuid = const Uuid();

  Future<void> _onStarted(GameStarted event, Emitter<GameState> emit) async {
    emit(GameState.initial().copyWith(
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
      emit(state.copyWith(
        phase:            GamePhase.playing,
        remainingSeconds: _kRushDurationSeconds,
      ));
      _startSessionTimer();
    }
  }

  void _onTapRegistered(GameTapRegistered event, Emitter<GameState> emit) {
    if (state.phase != GamePhase.playing) return;

    final result  = event.result;
    final elapsed = _sessionStart != null
        ? DateTime.now().difference(_sessionStart!)
        : Duration.zero;

    final int newCombo = result == TapResult.miss
        ? 0
        : (state.combo + 1).clamp(0, _kMaxCombo);
    final int newBestCombo =
        newCombo > state.bestCombo ? newCombo : state.bestCombo;

    int tapScore = 0;
    if (result != TapResult.miss) {
      final int base       = result == TapResult.perfect
          ? _kBaseScore + _kPerfectBonus
          : _kBaseScore;
      final int multiplier = newCombo.clamp(1, _kMaxCombo);
      tapScore = base * multiplier;
    }

    final newTaps = List<TapEvent>.from(state.taps)
      ..add(TapEvent(
        timestamp:  elapsed,
        result:     result,
        comboAtTap: newCombo,
      ));

    emit(state.copyWith(
      score:      state.score + tapScore,
      combo:      newCombo,
      bestCombo:  newBestCombo,
      taps:       newTaps,
      lastResult: () => result,
    ));
  }

  void _onTimerTicked(GameTimerTicked event, Emitter<GameState> emit) {
    if (event.remainingSeconds > 0) {
      emit(state.copyWith(remainingSeconds: event.remainingSeconds));
    } else {
      _finishSession(emit);
    }
  }

  void _onAborted(GameAborted event, Emitter<GameState> emit) {
    _cancelTimers();
    emit(GameState.initial());
  }

  void _startCountdown() {
    int count = 3;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      count--;
      add(GameCountdownTicked(count: count));
      if (count <= 0) _countdownTimer?.cancel();
    });
  }

  void _startSessionTimer() {
    int remaining = _kRushDurationSeconds;
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      remaining--;
      add(GameTimerTicked(remainingSeconds: remaining));
      if (remaining <= 0) _sessionTimer?.cancel();
    });
  }

  void _finishSession(Emitter<GameState> emit) {
    _cancelTimers();
    final session = GameSession(
      id:        _uuid.v4(),
      mode:      state.mode,
      startedAt: _sessionStart ?? DateTime.now(),
      duration:  const Duration(seconds: _kRushDurationSeconds),
      taps:      List.unmodifiable(state.taps),
      score:     state.score,
      bestCombo: state.bestCombo,
    );
    emit(state.copyWith(
      phase:   GamePhase.finished,
      session: () => session,
    ));
  }

  void _cancelTimers() {
    _countdownTimer?.cancel();
    _sessionTimer?.cancel();
  }

  @override
  Future<void> close() {
    _cancelTimers();
    return super.close();
  }
}
