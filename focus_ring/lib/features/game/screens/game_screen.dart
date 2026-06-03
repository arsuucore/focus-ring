import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
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
        'rush'     => '10 Second Rush',
        'survival' => 'Survival',
        'focus'    => 'Focus',
        'goal'     => 'Goal',
        'daily'    => 'Daily Challenge',
        _          => mode,
      };

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _resultLabelCtrl;
  late final Animation<double>   _resultLabelOpacity;
  TapResult? _displayedResult;

  @override
  void initState() {
    super.initState();
    _resultLabelCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _resultLabelOpacity = CurvedAnimation(
      parent: _resultLabelCtrl,
      curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
    ).drive(Tween<double>(begin: 1.0, end: 0.0));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameBloc>().add(GameStarted(mode: widget.mode));
    });
  }

  @override
  void dispose() {
    _resultLabelCtrl.dispose();
    super.dispose();
  }

  void _showResultLabel(TapResult result) {
    setState(() => _displayedResult = result);
    _resultLabelCtrl.forward(from: 0);
  }

  void _handleTap(TapResult result) {
    context.read<GameBloc>().add(GameTapRegistered(result: result));
    _showResultLabel(result);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GameBloc, GameState>(
      listenWhen: (prev, curr) =>
          prev.phase != GamePhase.finished &&
          curr.phase == GamePhase.finished,
      listener: (context, state) {
        if (state.session != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => ResultScreen(session: state.session!),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocBuilder<GameBloc, GameState>(
            builder: (context, state) {
              final isPlaying   = state.phase == GamePhase.playing;
              final isCountdown = state.phase == GamePhase.countdown;

              return Stack(
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 16),

                      ModeHeader(
                        modeLabel:        GameScreen.modeLabel(widget.mode),
                        remainingSeconds: state.remainingSeconds,
                      ),

                      const SizedBox(height: 32),

                      _ScoreDisplay(score: state.score),

                      const Spacer(),

                      Center(
                        child: FocusRingWidget(
                          config:   const RingConfig(),
                          enabled:  isPlaying,
                          onResult: isPlaying ? _handleTap : null,
                        ),
                      ),

                      const Spacer(),

                      SizedBox(
                        height: 64,
                        child: Center(
                          child: ComboDisplay(combo: state.combo),
                        ),
                      ),

                      SizedBox(
                        height: 32,
                        child: Center(
                          child: FadeTransition(
                            opacity: _resultLabelOpacity,
                            child: _ResultLabel(result: _displayedResult),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),

                  if (isCountdown)
                    CountdownOverlay(count: state.countdownCount),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ScoreDisplay extends StatelessWidget {
  const _ScoreDisplay({required this.score});
  final int score;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$score',
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize:   52,
            fontWeight: FontWeight.w700,
            color:      AppColors.textPrimary,
            height:     1,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'SCORE',
          style: TextStyle(
            fontFamily:    'monospace',
            fontSize:      10,
            fontWeight:    FontWeight.w600,
            letterSpacing: 4,
            color:         AppColors.textDim,
          ),
        ),
      ],
    );
  }
}

class _ResultLabel extends StatelessWidget {
  const _ResultLabel({required this.result});
  final TapResult? result;

  @override
  Widget build(BuildContext context) {
    if (result == null) return const SizedBox.shrink();

    final (label, color) = switch (result!) {
      TapResult.perfect => ('PERFECT', AppColors.accent),
      TapResult.good    => ('GOOD',    AppColors.textPrimary),
      TapResult.miss    => ('MISS',    AppColors.textMid),
    };

    return Text(
      label,
      style: TextStyle(
        fontFamily:    'monospace',
        fontSize:      13,
        fontWeight:    FontWeight.w700,
        letterSpacing: 4,
        color:         color,
      ),
    );
  }
}
