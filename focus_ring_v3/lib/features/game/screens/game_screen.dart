import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/settings/game_settings.dart';
import '../../../shared/widgets/ring_config.dart';
import '../../../shared/widgets/focus_ring_widget.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../widgets/combo_display.dart';
import '../widgets/countdown_overlay.dart';
import '../widgets/mode_header.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.mode});
  final String mode;

  static String modeLabel(String mode) => switch (mode) {
    'rush'     => 'SURVIVAL',
    'survival' => 'SURVIVAL',
    _          => mode.toUpperCase(),
  };

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late final AnimationController _resultLabelCtrl;
  late final Animation<double>   _resultLabelOpacity;
  TapResult? _displayedResult;

  late final AnimationController _shakeCtrl;
  late final Animation<Offset>   _shakeAnim;

  late final AnimationController _flashCtrl;
  late final Animation<double>   _flashOpacity;

  late final AnimationController _scorePopCtrl;
  late final Animation<double>   _scorePop;

  @override
  void initState() {
    super.initState();

    _resultLabelCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _resultLabelOpacity = CurvedAnimation(
      parent: _resultLabelCtrl,
      curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
    ).drive(Tween<double>(begin: 1.0, end: 0.0));

    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = _shakeCtrl.drive(TweenSequence<Offset>([
      TweenSequenceItem(tween: Tween(begin: Offset.zero, end: const Offset(0.015, 0)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: const Offset(0.015, 0), end: const Offset(-0.015, 0.01)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: const Offset(-0.015, 0.01), end: const Offset(0.01, -0.01)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: const Offset(0.01, -0.01), end: const Offset(-0.008, 0.005)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: const Offset(-0.008, 0.005), end: Offset.zero), weight: 1),
    ]));

    _flashCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _flashOpacity = CurvedAnimation(parent: _flashCtrl, curve: Curves.easeOut)
        .drive(Tween<double>(begin: 0.45, end: 0.0));

    _scorePopCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _scorePop = CurvedAnimation(parent: _scorePopCtrl, curve: Curves.easeOutBack)
        .drive(Tween<double>(begin: 1.0, end: 1.25));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = context.read<GameSettings>();
      context.read<GameBloc>().add(GameStarted(mode: widget.mode, maxLives: settings.maxLives));
    });
  }

  @override
  void dispose() {
    _resultLabelCtrl.dispose();
    _shakeCtrl.dispose();
    _flashCtrl.dispose();
    _scorePopCtrl.dispose();
    super.dispose();
  }

  void _handleTap(TapResult result) {
    context.read<GameBloc>().add(GameTapRegistered(result: result));
    setState(() => _displayedResult = result);
    _resultLabelCtrl.forward(from: 0);
    if (result == TapResult.miss) {
      _shakeCtrl.forward(from: 0);
      _flashCtrl.forward(from: 0);
    } else {
      _scorePopCtrl.forward(from: 0).then((_) => _scorePopCtrl.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context.watch<GameSettings>().theme);

    return BlocListener<GameBloc, GameState>(
      listenWhen: (prev, curr) =>
          prev.phase != GamePhase.finished && curr.phase == GamePhase.finished,
      listener: (context, state) {
        if (state.session != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => ResultScreen(session: state.session!)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: BlocBuilder<GameBloc, GameState>(
            builder: (context, state) {
              final isPlaying   = state.phase == GamePhase.playing;
              final isCountdown = state.phase == GamePhase.countdown;

              return AnimatedBuilder(
                animation: _shakeAnim,
                builder: (context, child) => FractionalTranslation(
                  translation: _shakeAnim.value,
                  child: child,
                ),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 16),
                        ModeHeader(
                          modeLabel: GameScreen.modeLabel(widget.mode),
                          lives:     state.lives,
                          maxLives:  state.maxLives,
                          colors:    colors,
                        ),
                        const SizedBox(height: 32),
                        ScaleTransition(
                          scale: _scorePop,
                          child: _ScoreDisplay(score: state.score, colors: colors),
                        ),
                        const Spacer(),
                        Center(
                          child: FocusRingWidget(
                            config:   const RingConfig(),
                            enabled:  isPlaying,
                            combo:    state.combo,
                            colors:   colors,
                            onResult: isPlaying ? _handleTap : null,
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          height: 64,
                          child: Center(child: ComboDisplay(combo: state.combo, colors: colors)),
                        ),
                        SizedBox(
                          height: 32,
                          child: Center(
                            child: FadeTransition(
                              opacity: _resultLabelOpacity,
                              child: _ResultLabel(result: _displayedResult, colors: colors),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),

                    // Red flash overlay on miss
                    AnimatedBuilder(
                      animation: _flashOpacity,
                      builder: (_, __) => IgnorePointer(
                        child: Container(
                          color: const Color(0xFFFF1111).withValues(alpha: _flashOpacity.value),
                        ),
                      ),
                    ),

                    if (isCountdown)
                      CountdownOverlay(count: state.countdownCount, colors: colors),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ScoreDisplay extends StatelessWidget {
  const _ScoreDisplay({required this.score, required this.colors});
  final int       score;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$score',
            style: TextStyle(fontFamily: 'monospace', fontSize: 52, fontWeight: FontWeight.w700, color: colors.textPrimary, height: 1)),
        const SizedBox(height: 4),
        Text('SCORE',
            style: TextStyle(fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 4, color: colors.textDim)),
      ],
    );
  }
}

class _ResultLabel extends StatelessWidget {
  const _ResultLabel({required this.result, required this.colors});
  final TapResult? result;
  final AppColors  colors;

  @override
  Widget build(BuildContext context) {
    if (result == null) return const SizedBox.shrink();
    final (label, color) = switch (result!) {
      TapResult.perfect => ('PERFECT', colors.accent),
      TapResult.good    => ('GOOD',    colors.textPrimary),
      TapResult.miss    => ('MISS',    const Color(0xFFFF3333)),
    };
    return Text(label,
        style: TextStyle(fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 4, color: color));
  }
}
