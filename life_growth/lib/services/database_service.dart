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

  // Removed all v1 DailyTask methods - replaced with v2 schema

  /// Clear all data (for testing or logout)
  Future<void> clearAllData() async {
    await database.clearAllData();
  }

  /// Clear data for a specific user
  Future<void> clearUserData(String userId) async {
    await database.clearUserData(userId);
  }


}