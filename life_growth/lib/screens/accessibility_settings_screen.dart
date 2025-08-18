import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class AccessibilitySettingsScreen extends StatelessWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Accessibility Settings',
          semanticsLabel: 'Accessibility Settings Screen',
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Theme Selection Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Theme Settings',
                          style: Theme.of(context).textTheme.headlineSmall,
                          semanticsLabel: 'Theme Settings Section',
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Choose your preferred theme mode for better visibility and comfort.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        
                        // Light Theme Option
                        Semantics(
                          label: 'Light theme option',
                          child: RadioListTile<ThemeMode>(
                            title: const Text('Light Theme'),
                            subtitle: const Text('Use light colors for better visibility in bright environments'),
                            value: ThemeMode.light,
                            groupValue: themeProvider.themeMode,
                            onChanged: (ThemeMode? value) {
                              if (value != null) {
                                themeProvider.setThemeMode(value);
                              }
                            },
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                        
                        // Dark Theme Option
                        Semantics(
                          label: 'Dark theme option',
                          child: RadioListTile<ThemeMode>(
                            title: const Text('Dark Theme'),
                            subtitle: const Text('Use dark colors to reduce eye strain in low light'),
                            value: ThemeMode.dark,
                            groupValue: themeProvider.themeMode,
                            onChanged: (ThemeMode? value) {
                              if (value != null) {
                                themeProvider.setThemeMode(value);
                              }
                            },
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                        
                        // System Theme Option
                        Semantics(
                          label: 'System theme option',
                          child: RadioListTile<ThemeMode>(
                            title: const Text('System Theme'),
                            subtitle: const Text('Follow your device\'s system theme setting'),
                            value: ThemeMode.system,
                            groupValue: themeProvider.themeMode,
                            onChanged: (ThemeMode? value) {
                              if (value != null) {
                                themeProvider.setThemeMode(value);
                              }
                            },
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Accessibility Information Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Accessibility Features',
                          style: Theme.of(context).textTheme.headlineSmall,
                          semanticsLabel: 'Accessibility Features Section',
                        ),
                        const SizedBox(height: 16),
                        
                        // Feature list
                        _buildFeatureItem(
                          context,
                          Icons.touch_app,
                          'Touch Targets',
                          'All interactive elements are at least 48x48 dp for easy tapping',
                        ),
                        
                        _buildFeatureItem(
                          context,
                          Icons.accessibility,
                          'Screen Reader Support',
                          'Optimized for screen readers with proper labels and descriptions',
                        ),
                        
                        _buildFeatureItem(
                          context,
                          Icons.contrast,
                          'High Contrast',
                          'Colors meet WCAG accessibility guidelines for contrast ratios',
                        ),
                        
                        _buildFeatureItem(
                          context,
                          Icons.text_fields,
                          'Text Scaling',
                          'Supports system text size settings up to 140% scaling',
                        ),
                        
                        _buildFeatureItem(
                          context,
                          Icons.dark_mode,
                          'Dark Mode',
                          'Reduces eye strain in low-light environments',
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Current Theme Display
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Settings',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              themeProvider.themeMode == ThemeMode.dark
                                  ? Icons.dark_mode
                                  : themeProvider.themeMode == ThemeMode.light
                                      ? Icons.light_mode
                                      : Icons.brightness_auto,
                              semanticLabel: 'Current theme icon',
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Theme: ${themeProvider.themeModeString}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.brightness_1,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              semanticLabel: 'Current brightness indicator',
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Active: ${Theme.of(context).brightness == Brightness.dark ? "Dark" : "Light"}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildFeatureItem(BuildContext context, IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            semanticLabel: '$title icon',
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}