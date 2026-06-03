import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/settings/game_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<GameSettings>();
    final colors   = AppColors.of(settings.theme);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Icon(Icons.arrow_back_ios_new, color: colors.textMid, size: 18),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text('SETTINGS',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 4, color: colors.textPrimary)),
                ],
              ),
              const SizedBox(height: 40),

              // ── THEME ──────────────────────────────────────────────────────
              Text('THEME',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 10, letterSpacing: 3, color: colors.textDim)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10, runSpacing: 10,
                children: AppTheme.values.map((t) {
                  final selected = settings.theme == t;
                  final tc       = AppColors.of(t);
                  return GestureDetector(
                    onTap: () => settings.setTheme(t),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? colors.accent.withValues(alpha: 0.15) : Colors.transparent,
                          border: Border.all(
                            color: selected ? colors.accent : colors.border,
                            width: selected ? 1.5 : 1,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: tc.accent)),
                            const SizedBox(width: 8),
                            Text(t.label,
                                style: TextStyle(fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.w600,
                                    letterSpacing: 2, color: selected ? colors.accent : colors.textMid)),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),

              // ── LIVES ──────────────────────────────────────────────────────
              Text('LIVES',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 10, letterSpacing: 3, color: colors.textDim)),
              const SizedBox(height: 16),
              Row(
                children: List.generate(5, (i) {
                  final n        = i + 1;
                  final selected = settings.maxLives == n;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => settings.setMaxLives(n),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: selected ? colors.accent.withValues(alpha: 0.15) : Colors.transparent,
                            border: Border.all(color: selected ? colors.accent : colors.border, width: selected ? 1.5 : 1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.center,
                          child: Text('$n',
                              style: TextStyle(fontFamily: 'monospace', fontSize: 18, fontWeight: FontWeight.w700,
                                  color: selected ? colors.accent : colors.textMid)),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text('misses before game over',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: colors.textDim)),

              const Spacer(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
