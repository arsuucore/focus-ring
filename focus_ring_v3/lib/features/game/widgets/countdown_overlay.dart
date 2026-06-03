import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CountdownOverlay extends StatelessWidget {
  const CountdownOverlay({super.key, required this.count, required this.colors});
  final int       count;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final label = count > 0 ? '$count' : 'GO';
    final isGo  = count == 0;
    return IgnorePointer(
      child: Container(
        color: Colors.black.withValues(alpha: 0.65),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: Tween<double>(begin: 0.6, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
              ),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Text(label,
              key: ValueKey(count),
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize:    isGo ? 56 : 96,
                fontWeight:  FontWeight.w700,
                letterSpacing: isGo ? 8 : 0,
                color: isGo ? colors.accent : colors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
