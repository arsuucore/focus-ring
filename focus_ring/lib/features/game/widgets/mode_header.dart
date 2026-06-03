import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ModeHeader extends StatelessWidget {
  const ModeHeader({
    super.key,
    required this.modeLabel,
    required this.remainingSeconds,
  });

  final String modeLabel;
  final int    remainingSeconds;

  @override
  Widget build(BuildContext context) {
    final isUrgent = remainingSeconds <= 3;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            modeLabel.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize:    11,
              fontWeight:  FontWeight.w600,
              letterSpacing: 3,
              color: AppColors.textMid,
            ),
          ),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize:   28,
              fontWeight: FontWeight.w700,
              color: isUrgent ? AppColors.accent : AppColors.textPrimary,
            ),
            child: Text('$remainingSeconds'),
          ),
        ],
      ),
    );
  }
}
