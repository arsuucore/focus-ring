import 'package:equatable/equatable.dart';
import '../../../shared/widgets/ring_config.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();
  @override
  List<Object?> get props => [];
}

class GameStarted extends GameEvent {
  const GameStarted({required this.mode, required this.maxLives});
  final String mode;
  final int    maxLives;
  @override
  List<Object?> get props => [mode, maxLives];
}

class GameTapRegistered extends GameEvent {
  const GameTapRegistered({required this.result});
  final TapResult result;
  @override
  List<Object?> get props => [result];
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
