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

  // Light theme with enhanced modern color palette
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        // Primary: Enhanced vibrant blue-green for main actions
        primary: Color(0xFF006A6B),
        onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFF6FF6F7),
        onPrimaryContainer: Color(0xFF002020),
        
        // Secondary: Warm amber for secondary actions
        secondary: Color(0xFF695C40),
        onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0xFFF1DFBB),
        onSecondaryContainer: Color(0xFF231B04),
        
        // Tertiary: Rich purple for accents
        tertiary: Color(0xFF5D5B7D),
        onTertiary: Color(0xFFFFFFFF),
        tertiaryContainer: Color(0xFFE3DFFF),
        onTertiaryContainer: Color(0xFF191537),
        
        // Surface and background: Clean whites and light grays
        surface: Color(0xFFFAFDFD),
        onSurface: Color(0xFF191C1C),
        surfaceVariant: Color(0xFFDAE5E5),
        onSurfaceVariant: Color(0xFF3F4949),
        
        background: Color(0xFFFAFDFD),
        onBackground: Color(0xFF191C1C),
        
        // Error colors with better contrast
        error: Color(0xFFBA1A1A),
        onError: Color(0xFFFFFFFF),
        errorContainer: Color(0xFFFFDAD6),
        onErrorContainer: Color(0xFF410002),
        
        // Outline and shadow with improved visibility
        outline: Color(0xFF6F7979),
        shadow: Color(0xFF000000),
        surfaceContainerHighest: Color(0xFFE0E3E3),
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

  // Dark theme with enhanced modern color palette
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        // Primary: Bright teal for dark mode visibility
        primary: Color(0xFF4DD0E1),
        onPrimary: Color(0xFF002020),
        primaryContainer: Color(0xFF004F50),
        onPrimaryContainer: Color(0xFF6FF6F7),
        
        // Secondary: Warm gold for secondary actions
        secondary: Color(0xFFD5C3A0),
        onSecondary: Color(0xFF231B04),
        secondaryContainer: Color(0xFF503E26),
        onSecondaryContainer: Color(0xFFF1DFBB),
        
        // Tertiary: Soft lavender for accents
        tertiary: Color(0xFFC7C3E8),
        onTertiary: Color(0xFF191537),
        tertiaryContainer: Color(0xFF443A64),
        onTertiaryContainer: Color(0xFFE3DFFF),
        
        // Surface and background: Rich dark grays
        surface: Color(0xFF0F1419),
        onSurface: Color(0xFFE0E3E3),
        surfaceVariant: Color(0xFF3F4949),
        onSurfaceVariant: Color(0xFFBFC9C9),
        
        background: Color(0xFF0F1419),
        onBackground: Color(0xFFE0E3E3),
        
        // Error colors with proper dark mode contrast
        error: Color(0xFFFFB4AB),
        onError: Color(0xFF410002),
        errorContainer: Color(0xFF93000A),
        onErrorContainer: Color(0xFFFFDAD6),
        
        // Outline and shadow with better visibility
        outline: Color(0xFF899393),
        shadow: Color(0xFF000000),
        surfaceContainerHighest: Color(0xFF2B2F2F),
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