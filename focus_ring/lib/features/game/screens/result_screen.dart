import 'package:flutter/material.dart';

import '../../../core/models/game_session.dart';
import '../../../core/theme/app_colors.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.session});
  final GameSession session;

  @override
  Widget build(BuildContext context) {
    final accuracyPct = (session.accuracy * 100).round();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              const Text(
                'RESULT',
                style: TextStyle(
                  fontFamily:    'monospace',
                  fontSize:      11,
                  fontWeight:    FontWeight.w600,
                  letterSpacing: 4,
                  color:         AppColors.textDim,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                '${session.score}',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize:   72,
                  fontWeight: FontWeight.w800,
                  color:      AppColors.textPrimary,
                  height:     1,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'POINTS',
                style: TextStyle(
                  fontFamily:    'monospace',
                  fontSize:      11,
                  letterSpacing: 3,
                  color:         AppColors.textDim,
                ),
              ),

              const SizedBox(height: 40),

              _StatRow(label: 'PERFECT',    value: '${session.perfects}',   color: AppColors.accent),
              _StatRow(label: 'GOOD',       value: '${session.goods}',      color: AppColors.textPrimary),
              _StatRow(label: 'MISS',       value: '${session.misses}',     color: AppColors.textMid),
              _StatRow(label: 'BEST COMBO', value: '×${session.bestCombo}', color: AppColors.accent),
              _StatRow(label: 'ACCURACY',   value: '$accuracyPct%',         color: AppColors.textPrimary),

              const Spacer(),

              _ActionButton(
                label:   'PLAY AGAIN',
                primary: true,
                onTap:   () => Navigator.of(context).pop(),
              ),

              const SizedBox(height: 12),

              _ActionButton(
                label:   'HOME',
                primary: false,
                onTap:   () => Navigator.of(context)
                  ..pop()
                  ..pop(),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color  color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                fontFamily:    'monospace',
                fontSize:      11,
                letterSpacing: 2,
                color:         AppColors.textMid,
              )),
          Text(value,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize:   22,
                fontWeight: FontWeight.w700,
                color:      color,
              )),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.primary,
    required this.onTap,
  });

  final String       label;
  final bool         primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width:  double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: primary ? AppColors.accent : Colors.transparent,
            border: primary
                ? null
                : Border.all(color: AppColors.border, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily:    'monospace',
              fontSize:      12,
              fontWeight:    FontWeight.w700,
              letterSpacing: 3,
              color: primary ? AppColors.background : AppColors.textMid,
            ),
          ),
        ),
      ),
    );
  }
}
