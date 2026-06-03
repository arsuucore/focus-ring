import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'core/audio/audio_service.dart';
import 'core/settings/game_settings.dart';
import 'core/theme/app_colors.dart';
import 'features/game/bloc/game_bloc.dart';
import 'features/game/screens/game_screen.dart';
import 'features/settings/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameSettings(),
      child: const FocusApp(),
    ),
  );
}

class FocusApp extends StatelessWidget {
  const FocusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const _HomeScreen(),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<GameSettings>();
    final colors   = AppColors.of(settings.theme);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Settings icon top-right
            Positioned(
              top: 16, right: 20,
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.tune, color: colors.textMid, size: 20),
                  ),
                ),
              ),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('FOCUS',
                      style: TextStyle(
                        fontFamily:    'monospace',
                        fontSize:       36,
                        fontWeight:     FontWeight.w800,
                        letterSpacing:  12,
                        color: colors.textPrimary,
                      )),
                  const SizedBox(height: 12),
                  // Lives preview dots
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(settings.maxLives, (_) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: colors.accent)),
                    )),
                  ),
                  const SizedBox(height: 64),
                  _HomeButton(label: 'PLAY', primary: true, colors: colors,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => BlocProvider(
                        create: (_) => GameBloc(maxLives: settings.maxLives, audio: AudioService()),
                        child: const GameScreen(mode: 'rush'),
                      )),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _HomeButton(label: 'SETTINGS', primary: false, colors: colors,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  const _HomeButton({required this.label, required this.primary, required this.colors, required this.onTap});
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
          width: 200, height: 52,
          decoration: BoxDecoration(
            color: primary ? colors.accent : Colors.transparent,
            border: primary ? null : Border.all(color: colors.border, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyle(
                fontFamily:    'monospace',
                fontSize:       12,
                fontWeight:     FontWeight.w700,
                letterSpacing:  6,
                color: primary ? colors.background : colors.textMid,
              )),
        ),
      ),
    );
  }
}
