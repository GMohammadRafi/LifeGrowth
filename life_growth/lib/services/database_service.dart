import '../database/database.dart';
import '../models/daily_checkin.dart' as model;
import '../models/habit.dart' as model;
import '../models/habit.dart' show HabitFrequency;
import '../models/goal.dart' as model;
import '../models/goal.dart' show GoalCategory, GoalPriority;
import '../models/journal_entry.dart' as model;

/// Service class that provides access to the local SQLite database
class DatabaseService {
  static DatabaseService? _instance;
  static AppDatabase? _database;

  DatabaseService._();

  /// Get the singleton instance of DatabaseService
  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  /// Get the database instance
  AppDatabase get database {
    _database ??= AppDatabase();
    return _database!;
  }

  /// Initialize the database (call this in main.dart)
  static Future<void> initialize() async {
    final service = DatabaseService.instance;
    // This will create the database connection
    final db = service.database;

    // Ensure the database is properly initialized
    await db.customSelect('SELECT 1').get();
  }

  /// Close the database connection
  static Future<void> close() async {
    await _database?.close();
    _database = null;
    _instance = null;
  }

  // Removed all v1 DailyTask methods - replaced with v2 schema

  /// Clear all data (for testing or logout)
  Future<void> clearAllData() async {
    await database.clearAllData();
  }

  /// Clear data for a specific user
  Future<void> clearUserData(String userId) async {
    await database.clearUserData(userId);
  }

  // Methods for CSV export - get all data regardless of user
  
  /// Get all daily check-ins for export
  Future<List<model.DailyCheckin>> getAllDailyCheckins() async {
    return await database.customSelect(
      'SELECT * FROM daily_checkins ORDER BY date DESC',
    ).map((row) {
      return model.DailyCheckin(
        id: row.read<String>('id'),
        date: DateTime.parse(row.read<String>('date')),
        mood: row.read<int>('mood'),
        energy: row.read<int>('energy'),
        stress: row.read<int>('stress'),
        notes: row.read<String?>('notes') ?? '',
        createdAt: DateTime.parse(row.read<String>('created_at')),
        updatedAt: DateTime.parse(row.read<String>('updated_at')),
        needsSync: row.read<bool>('needs_sync'),
        lastSyncAt: row.read<String?>('last_sync_at') != null 
            ? DateTime.parse(row.read<String>('last_sync_at')) 
            : null,
      );
    }).get();
  }

  /// Get all habits for export
  Future<List<model.Habit>> getAllHabits() async {
    return await database.customSelect(
      'SELECT * FROM habits ORDER BY created_at DESC',
    ).map((row) {
      return model.Habit(
        id: row.read<String>('id'),
        name: row.read<String>('name'),
        description: row.read<String>('description'),
        frequency: HabitFrequency.values.firstWhere(
          (e) => e.name == row.read<String>('frequency'),
        ),
        isActive: row.read<bool>('is_active'),
        createdAt: DateTime.parse(row.read<String>('created_at')),
        updatedAt: DateTime.parse(row.read<String>('updated_at')),
        needsSync: row.read<bool>('needs_sync'),
        lastSyncAt: row.read<String?>('last_sync_at') != null 
            ? DateTime.parse(row.read<String>('last_sync_at')) 
            : null,
      );
    }).get();
  }

  /// Get all goals for export
  Future<List<model.Goal>> getAllGoals() async {
    return await database.customSelect(
      'SELECT * FROM goals ORDER BY created_at DESC',
    ).map((row) {
      return model.Goal(
        id: row.read<String>('id'),
        title: row.read<String>('title'),
        description: row.read<String>('description'),
        category: GoalCategory.values.firstWhere(
          (e) => e.name == row.read<String>('category'),
        ),
        priority: GoalPriority.values.firstWhere(
          (e) => e.name == row.read<String>('priority'),
        ),
        targetDate: DateTime.parse(row.read<String>('target_date')),
        isCompleted: row.read<bool>('is_completed'),
        completedAt: row.read<String?>('completed_at') != null 
            ? DateTime.parse(row.read<String>('completed_at')) 
            : null,
        progress: row.read<int>('progress'),
        createdAt: DateTime.parse(row.read<String>('created_at')),
        updatedAt: DateTime.parse(row.read<String>('updated_at')),
        needsSync: row.read<bool>('needs_sync'),
        lastSyncAt: row.read<String?>('last_sync_at') != null 
            ? DateTime.parse(row.read<String>('last_sync_at')) 
            : null,
      );
    }).get();
  }

  /// Get all journal entries for export
  Future<List<model.JournalEntry>> getAllJournalEntries() async {
    return await database.customSelect(
      'SELECT * FROM journal_entries ORDER BY created_at DESC',
    ).map((row) {
      return model.JournalEntry(
        id: row.read<String>('id'),
        title: row.read<String>('title'),
        content: row.read<String>('content'),
        mood: row.read<int>('mood'),
        tags: row.read<String>('tags').split(',').where((tag) => tag.isNotEmpty).toList(),
        createdAt: DateTime.parse(row.read<String>('created_at')),
        updatedAt: DateTime.parse(row.read<String>('updated_at')),
        needsSync: row.read<bool>('needs_sync'),
        lastSyncAt: row.read<String?>('last_sync_at') != null 
            ? DateTime.parse(row.read<String>('last_sync_at')) 
            : null,
      );
    }).get();
  }
}