import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/game_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/settings/game_settings.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.session});
  final GameSession session;

  @override
  Widget build(BuildContext context) {
    final colors      = AppColors.of(context.watch<GameSettings>().theme);
    final accuracyPct = (session.accuracy * 100).round();

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text('RESULT',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 4, color: colors.textDim)),
              const SizedBox(height: 8),
              Text('${session.score}',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 72, fontWeight: FontWeight.w800, color: colors.textPrimary, height: 1)),
              const SizedBox(height: 4),
              Text('POINTS',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 11, letterSpacing: 3, color: colors.textDim)),
              const SizedBox(height: 40),
              _StatRow(label: 'PERFECT',    value: '${session.perfects}',   color: colors.accent,       colors: colors),
              _StatRow(label: 'GOOD',       value: '${session.goods}',      color: colors.textPrimary,  colors: colors),
              _StatRow(label: 'MISS',       value: '${session.misses}',     color: colors.textMid,      colors: colors),
              _StatRow(label: 'BEST COMBO', value: '×${session.bestCombo}', color: colors.accent,       colors: colors),
              _StatRow(label: 'ACCURACY',   value: '$accuracyPct%',         color: colors.textPrimary,  colors: colors),
              _StatRow(label: 'TIME',
                value: '${session.duration.inSeconds}s',
                color: colors.textMid,
                colors: colors),
              const Spacer(),
              _ActionButton(label: 'PLAY AGAIN', primary: true,  colors: colors, onTap: () => Navigator.of(context).pop()),
              const SizedBox(height: 12),
              _ActionButton(label: 'HOME',        primary: false, colors: colors, onTap: () => Navigator.of(context)..pop()..pop()),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value, required this.color, required this.colors});
  final String    label;
  final String    value;
  final Color     color;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontFamily: 'monospace', fontSize: 11, letterSpacing: 2, color: colors.textMid)),
          Text(value, style: TextStyle(fontFamily: 'monospace', fontSize: 22, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.primary, required this.colors, required this.onTap});
  final String       label;
  final bool         primary;
  final AppColors    colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity, height: 52,
          decoration: BoxDecoration(
            color:  primary ? colors.accent : Colors.transparent,
            border: primary ? null : Border.all(color: colors.border, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyle(fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 3,
                  color: primary ? colors.background : colors.textMid)),
        ),
      ),
    );
  }
}
