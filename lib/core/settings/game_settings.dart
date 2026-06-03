import 'package:flutter/foundation.dart';
import '../theme/app_colors.dart';

/// Shared settings state held above the widget tree via ChangeNotifier.
class GameSettings extends ChangeNotifier {
  AppTheme _theme   = AppTheme.dark;
  int      _maxLives = 3;   // 1–5 selectable

  AppTheme get theme     => _theme;
  int      get maxLives  => _maxLives;

  void setTheme(AppTheme t) {
    if (_theme == t) return;
    _theme = t;
    notifyListeners();
  }

  void setMaxLives(int v) {
    if (_maxLives == v) return;
    _maxLives = v.clamp(1, 5);
    notifyListeners();
  }
}
