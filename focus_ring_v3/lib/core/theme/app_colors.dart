import 'package:flutter/material.dart';

enum AppTheme { dark, neon, ocean, sunset, mono }

extension AppThemeLabel on AppTheme {
  String get label => switch (this) {
    AppTheme.dark   => 'DARK',
    AppTheme.neon   => 'NEON',
    AppTheme.ocean  => 'OCEAN',
    AppTheme.sunset => 'SUNSET',
    AppTheme.mono   => 'MONO',
  };
}

class AppColors {
  const AppColors._({
    required this.background,
    required this.textPrimary,
    required this.textDim,
    required this.textMid,
    required this.border,
    required this.accent,
    required this.trackColor,
    required this.targetGood,
    required this.targetPerfect,
  });

  final Color background;
  final Color textPrimary;
  final Color textDim;
  final Color textMid;
  final Color border;
  final Color accent;
  final Color trackColor;
  final Color targetGood;
  final Color targetPerfect;

  static const AppColors dark = AppColors._(
    background:    Color(0xFF0A0A0F),
    textPrimary:   Color(0xFFFFFFFF),
    textDim:       Color(0xFF444455),
    textMid:       Color(0xFF666677),
    border:        Color(0xFF222233),
    accent:        Color(0xFFE0E0FF),
    trackColor:    Color(0xFF1A1A2E),
    targetGood:    Color(0xFF555570),
    targetPerfect: Color(0xFFFFFFFF),
  );

  static const AppColors neon = AppColors._(
    background:    Color(0xFF050510),
    textPrimary:   Color(0xFF00FFCC),
    textDim:       Color(0xFF003333),
    textMid:       Color(0xFF006655),
    border:        Color(0xFF003322),
    accent:        Color(0xFF00FFCC),
    trackColor:    Color(0xFF0A1A18),
    targetGood:    Color(0xFF004433),
    targetPerfect: Color(0xFF00FFCC),
  );

  static const AppColors ocean = AppColors._(
    background:    Color(0xFF04080F),
    textPrimary:   Color(0xFFB0D4FF),
    textDim:       Color(0xFF1A2E44),
    textMid:       Color(0xFF2E5070),
    border:        Color(0xFF112233),
    accent:        Color(0xFF4BA3FF),
    trackColor:    Color(0xFF0A1828),
    targetGood:    Color(0xFF1A3A5C),
    targetPerfect: Color(0xFF4BA3FF),
  );

  static const AppColors sunset = AppColors._(
    background:    Color(0xFF0F0508),
    textPrimary:   Color(0xFFFFDDB0),
    textDim:       Color(0xFF331A10),
    textMid:       Color(0xFF7A4030),
    border:        Color(0xFF221108),
    accent:        Color(0xFFFF7A30),
    trackColor:    Color(0xFF1A0A08),
    targetGood:    Color(0xFF4A2015),
    targetPerfect: Color(0xFFFF7A30),
  );

  static const AppColors mono = AppColors._(
    background:    Color(0xFF111111),
    textPrimary:   Color(0xFFEEEEEE),
    textDim:       Color(0xFF333333),
    textMid:       Color(0xFF666666),
    border:        Color(0xFF222222),
    accent:        Color(0xFFFFFFFF),
    trackColor:    Color(0xFF1E1E1E),
    targetGood:    Color(0xFF444444),
    targetPerfect: Color(0xFFFFFFFF),
  );

  static AppColors of(AppTheme theme) => switch (theme) {
    AppTheme.dark   => dark,
    AppTheme.neon   => neon,
    AppTheme.ocean  => ocean,
    AppTheme.sunset => sunset,
    AppTheme.mono   => mono,
  };

  /// Combo-driven dot color, theme-aware.
  Color comboColor(int combo) {
    if (combo >= 7) return const Color(0xFFFF3333);
    if (combo >= 5) return const Color(0xFFFF8800);
    if (combo >= 3) return const Color(0xFFFFDD00);
    return accent;
  }
}
