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

  // Light theme with warm earth tone color palette
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        // Primary: Warm orange for main actions
        primary: Color(0xFFE2A95A),
        onPrimary: Color(0xFF2D2D2D),
        primaryContainer: Color(0xFFF2E9E0),
        onPrimaryContainer: Color(0xFF2D2D2D),
        
        // Secondary: Olive green for secondary actions
        secondary: Color(0xFF817C42),
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFE8D4B9),
        onSecondaryContainer: Color(0xFF2D2D2D),
        
        // Tertiary: Terracotta for accents
        tertiary: Color(0xFFC15D3B),
        onTertiary: Colors.white,
        tertiaryContainer: Color(0xFFEBB99E),
        onTertiaryContainer: Color(0xFF2D2D2D),
        
        // Surface and background: Light cream tones
        surface: Color(0xFFF2E9E0),
        onSurface: Color(0xFF2D2D2D),
        surfaceVariant: Color(0xFFE8D4B9),
        onSurfaceVariant: Color(0xFF2D2D2D),
        
        background: Color(0xFFFFFBF7),
        onBackground: Color(0xFF2D2D2D),
        
        // Error colors
        error: Color(0xFFD32F2F),
        onError: Colors.white,
        errorContainer: Color(0xFFFFEBEE),
        onErrorContainer: Color(0xFFD32F2F),
        
        // Outline and shadow
        outline: Color(0xFF817C42),
        shadow: Color(0xFF2D2D2D),
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

  // Dark theme with warm earth tone color palette
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        // Primary: Muted warm orange for dark mode
        primary: Color(0xFFE2A95A),
        onPrimary: Color(0xFF1A1A1A),
        primaryContainer: Color(0xFF817C42),
        onPrimaryContainer: Color(0xFFE8D4B9),
        
        // Secondary: Darker olive green
        secondary: Color(0xFF9A9456),
        onSecondary: Color(0xFF1A1A1A),
        secondaryContainer: Color(0xFF5A5632),
        onSecondaryContainer: Color(0xFFE8D4B9),
        
        // Tertiary: Muted terracotta
        tertiary: Color(0xFFD4735A),
        onTertiary: Color(0xFF1A1A1A),
        tertiaryContainer: Color(0xFF8B3E26),
        onTertiaryContainer: Color(0xFFEBB99E),
        
        // Surface and background: Dark warm tones
        surface: Color(0xFF1F1E1B),
        onSurface: Color(0xFFE8D4B9),
        surfaceVariant: Color(0xFF2A2823),
        onSurfaceVariant: Color(0xFFE8D4B9),
        
        background: Color(0xFF1A1917),
        onBackground: Color(0xFFE8D4B9),
        
        // Error colors
        error: Color(0xFFEF5350),
        onError: Color(0xFF1A1A1A),
        errorContainer: Color(0xFF8B1538),
        onErrorContainer: Color(0xFFFFEBEE),
        
        // Outline and shadow
        outline: Color(0xFF817C42),
        shadow: Color(0xFF000000),
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