import '../database/database.dart';

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
  Future<List<DailyTask>> getAllDailyTasksForUser(
    String userId, {
    bool includeDeleted = false,
  }) async {
    return await database.getAllDailyTasksForUser(
      userId,
      includeDeleted: includeDeleted,
    );
  }

  /// Insert or update a daily task
  Future<void> upsertDailyTask(DailyTask task) async {
    await database.upsertDailyTask(task);
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
  Future<List<DailyTask>> getTasksToSync() async {
    return await database.getTasksToSync();
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
  Future<List<DailyTask>> getCurrentWeekTasks(String userId) async {
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
  Future<List<DailyTask>> getCurrentMonthTasks(String userId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    // Get all tasks for user and filter by date range
    final allTasks = await getAllDailyTasksForUser(userId);
    return allTasks.where((task) {
      return task.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
             task.date.isBefore(endOfMonth.add(const Duration(days: 1)));
    }).toList();
  }
}