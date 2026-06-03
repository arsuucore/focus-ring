import 'package:equatable/equatable.dart';
import '../../../shared/widgets/ring_config.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();
  @override
  List<Object?> get props => [];
}

class GameStarted extends GameEvent {
  const GameStarted({required this.mode});
  final String mode;
  @override
  List<Object?> get props => [mode];
}

class GameTapRegistered extends GameEvent {
  const GameTapRegistered({required this.result});
  final TapResult result;
  @override
  List<Object?> get props => [result];
}

class GameTimerTicked extends GameEvent {
  const GameTimerTicked({required this.remainingSeconds});
  final int remainingSeconds;
  @override
  List<Object?> get props => [remainingSeconds];
}

class GameCountdownTicked extends GameEvent {
  const GameCountdownTicked({required this.count});
  final int count;
  @override
  List<Object?> get props => [count];
}

class GameAborted extends GameEvent {
  const GameAborted();
}
