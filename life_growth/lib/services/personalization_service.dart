import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/personalization_settings.dart';

class PersonalizationService {
  static const String _settingsKey = 'personalization_settings';
  static PersonalizationService? _instance;
  static SharedPreferences? _prefs;

  PersonalizationService._();

  static Future<PersonalizationService> getInstance() async {
    _instance ??= PersonalizationService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // Load personalization settings
  Future<PersonalizationSettings> loadSettings() async {
    try {
      final String? settingsJson = _prefs?.getString(_settingsKey);
      if (settingsJson != null) {
        final Map<String, dynamic> settingsMap = json.decode(settingsJson);
        return PersonalizationSettings.fromJson(settingsMap);
      }
    } catch (e) {
      // If there's an error loading settings, return default
      print('Error loading personalization settings: $e');
    }
    return PersonalizationSettings.defaultSettings;
  }

  // Save personalization settings
  Future<bool> saveSettings(PersonalizationSettings settings) async {
    try {
      final String settingsJson = json.encode(settings.toJson());
      return await _prefs?.setString(_settingsKey, settingsJson) ?? false;
    } catch (e) {
      print('Error saving personalization settings: $e');
      return false;
    }
  }

  // Update task order
  Future<bool> updateTaskOrder(List<String> newOrder) async {
    final currentSettings = await loadSettings();
    final updatedSettings = currentSettings.copyWith(taskOrder: newOrder);
    return await saveSettings(updatedSettings);
  }

  // Toggle task visibility
  Future<bool> toggleTaskVisibility(String taskId) async {
    final currentSettings = await loadSettings();
    final Set<String> newHiddenTasks = Set.from(currentSettings.hiddenTasks);
    
    if (newHiddenTasks.contains(taskId)) {
      newHiddenTasks.remove(taskId);
    } else {
      newHiddenTasks.add(taskId);
    }
    
    final updatedSettings = currentSettings.copyWith(hiddenTasks: newHiddenTasks);
    return await saveSettings(updatedSettings);
  }

  // Update avoid habit label
  Future<bool> updateAvoidHabitLabel(String newLabel) async {
    final currentSettings = await loadSettings();
    final updatedSettings = currentSettings.copyWith(avoidHabitLabel: newLabel);
    return await saveSettings(updatedSettings);
  }

  // Toggle avoid sweets visibility
  Future<bool> toggleAvoidSweetsVisibility() async {
    final currentSettings = await loadSettings();
    final updatedSettings = currentSettings.copyWith(
      showAvoidSweets: !currentSettings.showAvoidSweets
    );
    return await saveSettings(updatedSettings);
  }

  // Reset to default settings
  Future<bool> resetToDefaults() async {
    return await saveSettings(PersonalizationSettings.defaultSettings);
  }

  // Check if task is visible
  Future<bool> isTaskVisible(String taskId) async {
    final settings = await loadSettings();
    if (taskId == 'avoidSweets' && !settings.showAvoidSweets) {
      return false;
    }
    return !settings.hiddenTasks.contains(taskId);
  }

  // Get task display name
  Future<String> getTaskDisplayName(String taskId) async {
    if (taskId == 'avoidHabit') {
      final settings = await loadSettings();
      return settings.avoidHabitLabel;
    }
    return _getDefaultTaskName(taskId);
  }

  // Get default task names
  String _getDefaultTaskName(String taskId) {
    switch (taskId) {
      case 'readingBook':
        return 'Reading Book';
      case 'stretch':
        return 'Stretch';
      case 'meditation':
        return 'Meditation';
      case 'readingDocs':
        return 'Reading Docs';
      case 'learningTech':
        return 'Learning Technology';
      case 'walking':
        return 'Walking';
      case 'avoidHabit':
        return 'Avoid X';
      case 'avoidSweets':
        return 'Avoid Sweets';
      case 'workDone':
        return 'Work Done';
      case 'movieSeries':
        return 'Movie/Series';
      default:
        return taskId;
    }
  }
}