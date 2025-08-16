import '../database/database.dart';
import '../database/daily_task_dao.dart';
import '../models/daily_task.dart' as model;

/// Service class that provides access to the local SQLite database
class DatabaseService {
  static DatabaseService? _instance;
  static AppDatabase? _database;
  static DailyTaskDao? _dailyTaskDao;

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

  /// Get the DailyTaskDao instance
  DailyTaskDao get dailyTaskDao {
    _dailyTaskDao ??= DailyTaskDao(database);
    return _dailyTaskDao!;
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
    _dailyTaskDao = null;
    _instance = null;
  }

  // Convenience methods that delegate to the DAO

  /// Get a daily task by user ID and date
  Future<model.DailyTask?> getDailyTask(String userId, DateTime date) async {
    return await dailyTaskDao.getDailyTaskModel(userId, date);
  }

  /// Get all daily tasks for a user
  Future<List<model.DailyTask>> getAllDailyTasksForUser(
    String userId, {
    bool includeDeleted = false,
  }) async {
    return await dailyTaskDao.getAllDailyTasksForUserModel(
      userId,
      includeDeleted: includeDeleted,
    );
  }

  /// Get daily tasks for a user within a date range
  Future<List<model.DailyTask>> getDailyTasksInRange(
    String userId,
    DateTime startDate,
    DateTime endDate, {
    bool includeDeleted = false,
  }) async {
    return await dailyTaskDao.getDailyTasksInRangeModel(
      userId,
      startDate,
      endDate,
      includeDeleted: includeDeleted,
    );
  }

  /// Insert or update a daily task
  Future<model.DailyTask> upsertDailyTask(model.DailyTask task) async {
    return await dailyTaskDao.upsertDailyTask(task);
  }

  /// Update a daily task
  Future<model.DailyTask?> updateDailyTask(model.DailyTask task) async {
    return await dailyTaskDao.updateDailyTask(task);
  }

  /// Delete a daily task (hard delete)
  Future<int> deleteDailyTask(String userId, DateTime date) async {
    return await dailyTaskDao.deleteDailyTask(userId, date);
  }

  /// Soft delete a daily task
  Future<bool> softDeleteDailyTask(String userId, DateTime date) async {
    return await dailyTaskDao.softDeleteDailyTask(userId, date);
  }

  /// Restore a soft-deleted daily task
  Future<bool> restoreDailyTask(String userId, DateTime date) async {
    return await dailyTaskDao.restoreDailyTask(userId, date);
  }

  /// Get tasks that need to be synced
  Future<List<model.DailyTask>> getTasksToSync(String userId) async {
    return await dailyTaskDao.getTasksToSync(userId);
  }

  /// Mark a task as synced
  Future<bool> markTaskAsSynced(String userId, DateTime date) async {
    return await dailyTaskDao.markTaskAsSynced(userId, date);
  }

  /// Clear all data (for testing or logout)
  Future<void> clearAllData() async {
    await dailyTaskDao.clearAllData();
  }

  /// Clear data for a specific user
  Future<int> clearUserData(String userId) async {
    return await dailyTaskDao.clearUserData(userId);
  }

  /// Get the current week's tasks for a user
  Future<List<model.DailyTask>> getCurrentWeekTasks(String userId) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return await getDailyTasksInRange(userId, startOfWeek, endOfWeek);
  }

  /// Get the current month's tasks for a user
  Future<List<model.DailyTask>> getCurrentMonthTasks(String userId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    return await getDailyTasksInRange(userId, startOfMonth, endOfMonth);
  }

  /// Get task completion statistics for a date range
  Future<Map<String, dynamic>> getTaskStatistics(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final tasks = await getDailyTasksInRange(userId, startDate, endDate);
    
    if (tasks.isEmpty) {
      return {
        'totalDays': 0,
        'averageCompletion': 0.0,
        'totalTasks': 0,
        'completedTasks': 0,
        'taskBreakdown': <String, Map<String, int>>{},
      };
    }

    int totalTasks = 0;
    int completedTasks = 0;
    Map<String, Map<String, int>> taskBreakdown = {};

    for (final task in tasks) {
      final taskCounts = task.getTaskCounts();
      totalTasks += (taskCounts['total']! as num).toInt();
      completedTasks += (taskCounts['completed']! as num).toInt();
      
      // Track individual task completion
      final taskTypes = {
        'readingBook': task.isReadingBookEffectivelyCompleted,
        'stretch': task.isStretchEffectivelyCompleted,
        'meditation': task.isMeditationEffectivelyCompleted,
        'readingDocs': task.isReadingDocsEffectivelyCompleted,
        'learningTech': task.isLearningTechEffectivelyCompleted,
        'walking': task.isWalkingEffectivelyCompleted,
        'avoidHabit': task.avoidHabitValue,
        'avoidSweets': task.avoidSweetsValue,
        'workDone': task.workDoneValue,
        'movieSeries': task.isMovieSeriesEffectivelyCompleted,
      };
      
      for (final entry in taskTypes.entries) {
        taskBreakdown[entry.key] ??= {'completed': 0, 'total': 0};
        taskBreakdown[entry.key]!['total'] = taskBreakdown[entry.key]!['total']! + 1;
        if (entry.value) {
          taskBreakdown[entry.key]!['completed'] = taskBreakdown[entry.key]!['completed']! + 1;
        }
      }
    }

    return {
      'totalDays': tasks.length,
      'averageCompletion': totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0.0,
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'taskBreakdown': taskBreakdown,
    };
  }
}