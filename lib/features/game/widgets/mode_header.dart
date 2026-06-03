import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ModeHeader extends StatelessWidget {
  const ModeHeader({
    super.key,
    required this.modeLabel,
    required this.lives,
    required this.maxLives,
    required this.colors,
  });

  final String   modeLabel;
  final int      lives;
  final int      maxLives;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            modeLabel.toUpperCase(),
            style: TextStyle(
              fontFamily:    'monospace',
              fontSize:       11,
              fontWeight:     FontWeight.w600,
              letterSpacing:  3,
              color: colors.textMid,
            ),
          ),
          _LivesRow(lives: lives, maxLives: maxLives, colors: colors),
        ],
      ),
    );
  }
}

class _LivesRow extends StatelessWidget {
  const _LivesRow({required this.lives, required this.maxLives, required this.colors});
  final int lives;
  final int maxLives;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxLives, (i) {
        final filled = i < lives;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 10, height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled ? colors.accent : colors.border,
            ),
          ),
        );
      }),
    );
  }
}
