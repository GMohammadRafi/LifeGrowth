import '../database/database.dart';
import '../models/daily_checkin.dart' as model;
import '../models/daily_task.dart' as model;
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

  // Convenience methods that delegate to the database

  /// Get a daily task by user ID and date
  Future<DailyTask?> getDailyTask(String userId, DateTime date) async {
    return await database.getDailyTask(userId, date);
  }

  /// Get all daily tasks for a user
  Future<List<model.DailyTask>> getAllDailyTasksForUser(
    String userId, {
    bool includeDeleted = false,
  }) async {
    final dbTasks = await database.getAllDailyTasksForUser(
      userId,
      includeDeleted: includeDeleted,
    );
    return dbTasks.map((dbTask) => _convertDailyTaskToModel(dbTask)).toList();
  }

  /// Insert or update a daily task
  Future<void> upsertDailyTask(model.DailyTask task, {bool needsSync = true}) async {
    final dbTask = _convertModelToDailyTask(task, needsSync: needsSync);
    await database.upsertDailyTask(dbTask);
  }

  /// Delete a daily task (hard delete)
  Future<void> deleteDailyTask(String userId, DateTime date) async {
    await database.deleteDailyTask(userId, date);
  }

  /// Soft delete a daily task
  Future<void> softDeleteDailyTask(String userId, DateTime date) async {
    await database.softDeleteDailyTask(userId, date);
  }

  /// Restore a soft-deleted daily task
  Future<void> restoreDailyTask(String userId, DateTime date) async {
    await database.restoreDailyTask(userId, date);
  }

  /// Get tasks that need to be synced
  Future<List<model.DailyTask>> getTasksToSync() async {
    final dbTasks = await database.getTasksToSync();
    return dbTasks.map((dbTask) => _convertDailyTaskToModel(dbTask)).toList();
  }

  /// Mark a task as synced
  Future<void> markTaskAsSynced(String userId, DateTime date) async {
    await database.markTaskAsSynced(userId, date);
  }

  /// Clear all data (for testing or logout)
  Future<void> clearAllData() async {
    await database.clearAllData();
  }

  /// Clear data for a specific user
  Future<void> clearUserData(String userId) async {
    await database.clearUserData(userId);
  }

  /// Permanently delete a daily task (hard delete)
  Future<void> permanentlyDeleteDailyTask(String userId, DateTime date) async {
    await database.deleteDailyTask(userId, date);
  }

  /// Get the current week's tasks for a user
  Future<List<model.DailyTask>> getCurrentWeekTasks(String userId) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    // Get all tasks for user and filter by date range
    final allTasks = await getAllDailyTasksForUser(userId);
    return allTasks.where((task) {
      return task.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          task.date.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).toList();
  }

  /// Get the current month's tasks for a user
  Future<List<model.DailyTask>> getCurrentMonthTasks(String userId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    // Get all tasks for user and filter by date range
    final allTasks = await getAllDailyTasksForUser(userId);
    return allTasks.where((task) {
      return task.date
              .isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
          task.date.isBefore(endOfMonth.add(const Duration(days: 1)));
    }).toList();
  }

  /// Convert model DailyTask to database DailyTask
  DailyTask _convertModelToDailyTask(model.DailyTask modelTask, {bool needsSync = true}) {
    // Normalize date to date-only format (required by database constraint)
    final dateOnly = DateTime(modelTask.date.year, modelTask.date.month, modelTask.date.day);

    return DailyTask(
      userId: modelTask.userId!,
      date: dateOnly,
      readingBookCompleted: modelTask.readingBookCompleted,
      readingBookPages: modelTask.readingBookPages,
      readingBookTime: modelTask.readingBookTime,
      stretchCompleted: modelTask.stretchCompleted,
      stretchMinutes: modelTask.stretchMinutes,
      stretchType: modelTask.stretchType,
      meditationCompleted: modelTask.meditationCompleted,
      meditationMinutes: modelTask.meditationMinutes,
      readingDocsCompleted: modelTask.readingDocsCompleted,
      readingDocsPages: modelTask.readingDocsPages,
      readingDocsTime: modelTask.readingDocsTime,
      readingDocsNameLink: modelTask.readingDocsNameLink,
      learningTechCompleted: modelTask.learningTechCompleted,
      learningTechName: modelTask.learningTechName,
      learningTechTime: modelTask.learningTechTime,
      learningTechSource: modelTask.learningTechSource,
      learningTechUrl: modelTask.learningTechUrl,
      walkingCompleted: modelTask.walkingCompleted,
      walkingSteps: modelTask.walkingSteps,
      walkingTime: modelTask.walkingTime,
      avoidHabitLabel: modelTask.avoidHabitLabel,
      avoidHabitValue: modelTask.avoidHabitValue,
      avoidSweetsValue: modelTask.avoidSweetsValue,
      workDoneValue: modelTask.workDoneValue,
      movieSeriesName: modelTask.movieSeriesName,
      movieSeriesDuration: modelTask.movieSeriesDuration,
      movieSeriesCompleted: modelTask.movieSeriesCompleted,
      timezoneOffset: modelTask.timezoneOffset,
      createdAt: modelTask.createdAt ?? DateTime.now(),
      updatedAt: modelTask.updatedAt ?? DateTime.now(),
      needsSync: needsSync,
      lastSyncAt: needsSync ? null : DateTime.now(),
    );
  }

  /// Convert database DailyTask to model DailyTask
  model.DailyTask _convertDailyTaskToModel(DailyTask dbTask) {
    return model.DailyTask(
      id: '${dbTask.userId}_${dbTask.date.millisecondsSinceEpoch}', // Generate composite ID
      userId: dbTask.userId,
      date: dbTask.date,
      readingBookPages: dbTask.readingBookPages,
      readingBookTime: dbTask.readingBookTime,
      readingBookCompleted: dbTask.readingBookCompleted,
      stretchType: dbTask.stretchType,
      stretchMinutes: dbTask.stretchMinutes,
      stretchCompleted: dbTask.stretchCompleted,
      meditationMinutes: dbTask.meditationMinutes,
      meditationCompleted: dbTask.meditationCompleted,
      readingDocsNameLink: dbTask.readingDocsNameLink,
      readingDocsPages: dbTask.readingDocsPages,
      readingDocsTime: dbTask.readingDocsTime,
      readingDocsCompleted: dbTask.readingDocsCompleted,
      learningTechName: dbTask.learningTechName,
      learningTechSource: dbTask.learningTechSource,
      learningTechUrl: dbTask.learningTechUrl,
      learningTechTime: dbTask.learningTechTime,
      learningTechCompleted: dbTask.learningTechCompleted,
      walkingSteps: dbTask.walkingSteps,
      walkingTime: dbTask.walkingTime,
      walkingCompleted: dbTask.walkingCompleted,
      avoidHabitLabel: dbTask.avoidHabitLabel,
      avoidHabitValue: dbTask.avoidHabitValue,
      avoidSweetsValue: dbTask.avoidSweetsValue,
      workDoneValue: dbTask.workDoneValue,
      movieSeriesName: dbTask.movieSeriesName,
      movieSeriesDuration: dbTask.movieSeriesDuration,
      movieSeriesCompleted: dbTask.movieSeriesCompleted,
      timezoneOffset: dbTask.timezoneOffset ?? 0,
      createdAt: dbTask.createdAt,
      updatedAt: dbTask.updatedAt,
    );
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

  /// Get all daily tasks for export
  Future<List<model.DailyTask>> getAllDailyTasks() async {
    final results = await database.customSelect(
      'SELECT * FROM daily_tasks ORDER BY date DESC',
    ).get();
    
    return results.map((row) {
      return model.DailyTask(
        id: row.read<String>('id'),
        userId: row.read<String>('user_id'),
        date: DateTime.parse(row.read<String>('date')),
        readingBookPages: row.read<int?>('reading_book_pages'),
        readingBookTime: row.read<int?>('reading_book_time'),
        readingBookCompleted: row.read<bool>('reading_book_completed'),
        stretchType: row.read<String?>('stretch_type'),
        stretchMinutes: row.read<int?>('stretch_minutes'),
        stretchCompleted: row.read<bool>('stretch_completed'),
        meditationMinutes: row.read<int?>('meditation_minutes'),
        meditationCompleted: row.read<bool>('meditation_completed'),
        readingDocsNameLink: row.read<String?>('reading_docs_name_link'),
        readingDocsPages: row.read<int?>('reading_docs_pages'),
        readingDocsTime: row.read<int?>('reading_docs_time'),
        readingDocsCompleted: row.read<bool>('reading_docs_completed'),
        learningTechName: row.read<String?>('learning_tech_name'),
        learningTechSource: row.read<String?>('learning_tech_source'),
        learningTechUrl: row.read<String?>('learning_tech_url'),
        learningTechTime: row.read<int?>('learning_tech_time'),
        learningTechCompleted: row.read<bool>('learning_tech_completed'),
        walkingSteps: row.read<int?>('walking_steps'),
        walkingTime: row.read<int?>('walking_time'),
        walkingCompleted: row.read<bool>('walking_completed'),
        avoidHabitLabel: row.read<String?>('avoid_habit_name'),
        avoidHabitValue: row.read<bool>('avoid_habit_completed'),
        avoidSweetsValue: false, // Default value
        workDoneValue: false, // Default value
        movieSeriesName: row.read<String?>('movie_series_name'),
        movieSeriesDuration: row.read<int?>('movie_series_time'),
        movieSeriesCompleted: row.read<bool>('movie_series_completed'),
        timezoneOffset: 0, // Default value
        createdAt: DateTime.parse(row.read<String>('created_at')),
        updatedAt: DateTime.parse(row.read<String>('updated_at')),
      );
    }).toList();
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
        tags: (row.read<String>('tags') ?? '').split(',').where((tag) => tag.isNotEmpty).toList(),
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
