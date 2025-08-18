import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = 'theme_mode';
  static ThemeService? _instance;
  static SharedPreferences? _prefs;

  ThemeService._();

  static Future<ThemeService> getInstance() async {
    _instance ??= ThemeService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // Get current theme mode
  ThemeMode getThemeMode() {
    final themeIndex = _prefs?.getInt(_themeKey) ?? 0;
    return ThemeMode.values[themeIndex];
  }

  // Set theme mode
  Future<bool> setThemeMode(ThemeMode themeMode) async {
    return await _prefs?.setInt(_themeKey, themeMode.index) ?? false;
  }

  // Light theme with accessibility considerations
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.green,
        brightness: Brightness.light,
      ).copyWith(
        // Ensure high contrast ratios
        primary: const Color(0xFF2E7D32), // Dark green for better contrast
        onPrimary: Colors.white,
        secondary: const Color(0xFF388E3C),
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: const Color(0xFF212121), // Dark text for contrast
        background: const Color(0xFFFAFAFA),
        onBackground: const Color(0xFF212121),
        error: const Color(0xFFD32F2F),
        onError: Colors.white,
      ),
      // Ensure minimum tap target sizes
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      
      // Button themes with accessibility
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 48), // Minimum 48x48 dp
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48), // Minimum 48x48 dp
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48), // Minimum 48x48 dp
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      // Icon button theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48), // Minimum 48x48 dp
          padding: const EdgeInsets.all(12),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: const InputDecorationTheme(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(),
      ),
      
      // Card theme
      cardTheme: const CardThemeData(
        elevation: 2,
        margin: EdgeInsets.all(8),
      ),
      
      // List tile theme
      listTileTheme: const ListTileThemeData(
        minVerticalPadding: 12,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  // Dark theme with accessibility considerations
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.green,
        brightness: Brightness.dark,
      ).copyWith(
        // Ensure high contrast ratios for dark mode
        primary: const Color(0xFF81C784), // Light green for dark background
        onPrimary: const Color(0xFF1B5E20),
        secondary: const Color(0xFFA5D6A7),
        onSecondary: const Color(0xFF2E7D32),
        surface: const Color(0xFF121212),
        onSurface: const Color(0xFFE0E0E0), // Light text for contrast
        background: const Color(0xFF121212),
        onBackground: const Color(0xFFE0E0E0),
        error: const Color(0xFFEF5350),
        onError: const Color(0xFF000000),
      ),
      // Ensure minimum tap target sizes
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      
      // Button themes with accessibility
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 48), // Minimum 48x48 dp
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48), // Minimum 48x48 dp
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48), // Minimum 48x48 dp
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      // Icon button theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48), // Minimum 48x48 dp
          padding: const EdgeInsets.all(12),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: const InputDecorationTheme(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(),
      ),
      
      // Card theme
      cardTheme: const CardThemeData(
        elevation: 4,
        margin: EdgeInsets.all(8),
      ),
      
      // List tile theme
      listTileTheme: const ListTileThemeData(
        minVerticalPadding: 12,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}