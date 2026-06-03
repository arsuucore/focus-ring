import 'dart:js_interop';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  _AudioContext? _ctx;
  _GainNode? _master;

  void init() {
    try {
      _ctx = _AudioContext();
    } catch (_) {}
  }

  void _ensureCtx() {
    if (_ctx == null) init();
  }

  void _tone({
    required double freq,
    required double gainPeak,
    required double durationSec,
    String type = 'sine',
  }) {
    try {
      _ensureCtx();
      if (_ctx == null) return;
      final ctx = _ctx!;
      final now = ctx.currentTime;
      final end = now + durationSec;

      final osc = ctx.createOscillator();
      final env = ctx.createGain();
      osc.connect(env);
      env.connect(_master!);

      osc.type = type.toJS;
      osc.frequency.setValueAtTime(freq.toJS, now.toJS);

      env.gain.setValueAtTime(0.0001.toJS, now.toJS);
      env.gain.exponentialRampToValueAtTime(gainPeak.toJS, (now + 0.01).toJS);
      env.gain.exponentialRampToValueAtTime(0.0001.toJS, end.toJS);

      osc.start(now.toJS);
      osc.stop((end + 0.05).toJS);
    } catch (_) { /* outside browser / not interactable yet */ }
  }

  void playPerfect()  => _tone(freq: 880, gainPeak: 0.28, durationSec: 0.18);
  void playGood()     => _tone(freq: 660, gainPeak: 0.22, durationSec: 0.14);
  void playMiss()     => _tone(freq: 180, gainPeak: 0.35, durationSec: 0.22, type: 'sawtooth');
  void playGameOver() {
    _tone(freq: 220, gainPeak: 0.30, durationSec: 0.35, type: 'sawtooth');
    Future.delayed(const Duration(milliseconds: 220),
        () => _tone(freq: 110, gainPeak: 0.25, durationSec: 0.60, type: 'sawtooth'));
  }
}

// -- dart:js_interop bindings --

@JS('AudioContext')
@staticInterop
class _AudioContext {
  external factory _AudioContext();
}
extension _AudioContextExt on _AudioContext {
  external double get currentTime;
  external _AudioDestinationNode get destination;
  external _OscillatorNode createOscillator();
  external _GainNode createGain();
}

@JS()
@staticInterop
class _AudioDestinationNode extends _AudioNode {}

@JS()
@staticInterop
class _AudioNode {}
extension _AudioNodeExt on _AudioNode {
  external void connect(JSObject destination);
}

@JS()
@staticInterop
class _AudioParam {}
extension _AudioParamExt on _AudioParam {
  external set value(JSNumber v);
  external void setValueAtTime(JSNumber value, JSNumber startTime);
  external void exponentialRampToValueAtTime(JSNumber value, JSNumber endTime);
}

@JS()
@staticInterop
class _OscillatorNode extends _AudioNode {}
extension _OscillatorNodeExt on _OscillatorNode {
  external set type(JSString t);
  external _AudioParam get frequency;
  external void start(JSNumber when);
  external void stop(JSNumber when);
}

@JS()
@staticInterop
class _GainNode extends _AudioNode {}
extension _GainNodeExt on _GainNode {
  external _AudioParam get gain;
}
