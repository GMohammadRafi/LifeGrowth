import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class ThemeProvider extends ChangeNotifier {
  late ThemeService _themeService;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _themeService = await ThemeService.getInstance();
    _themeMode = _themeService.getThemeMode();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
    await _themeService.setThemeMode(themeMode);
    notifyListeners();
  }

  bool get isDarkMode {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;
    // For system mode, we'll need to check the system brightness
    // This will be handled by the MaterialApp's theme selection
    return false;
  }

  String get themeModeString {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
}