import 'package:equatable/equatable.dart';
import '../../shared/widgets/ring_config.dart';

class TapEvent extends Equatable {
  const TapEvent({
    required this.timestamp,
    required this.result,
    required this.comboAtTap,
  });

  final Duration timestamp;
  final TapResult result;
  final int comboAtTap;

  @override
  List<Object?> get props => [timestamp, result, comboAtTap];
}
