import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [DailyTasks])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle future schema migrations here
        if (from < 2) {
          // Example migration for version 2
          // await m.addColumn(dailyTasks, dailyTasks.newColumn);
        }
      },
    );
  }

  // CRUD operations for DailyTasks
  
  /// Get a daily task by user ID and date
  Future<DailyTask?> getDailyTask(String userId, DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    final query = select(dailyTasks)
      ..where((t) => t.userId.equals(userId) & t.date.equals(dateOnly));
    
    return await query.getSingleOrNull();
  }

  /// Get all daily tasks for a user
  Future<List<DailyTask>> getAllDailyTasksForUser(String userId) async {
    final query = select(dailyTasks)
      ..where((t) => t.userId.equals(userId))
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    
    return await query.get();
  }

  /// Get daily tasks for a user within a date range
  Future<List<DailyTask>> getDailyTasksInRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    
    final query = select(dailyTasks)
      ..where((t) => 
          t.userId.equals(userId) & 
          t.date.isBetweenValues(start, end))
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    
    return await query.get();
  }

  /// Insert or update a daily task
  Future<DailyTask> upsertDailyTask(DailyTasksCompanion task) async {
    return await into(dailyTasks).insertReturning(
      task,
      mode: InsertMode.insertOrReplace,
    );
  }

  /// Update a daily task
  Future<bool> updateDailyTask(DailyTask task) async {
    return await update(dailyTasks).replace(task);
  }

  /// Delete a daily task (hard delete)
  Future<int> deleteDailyTask(String userId, DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    return await (delete(dailyTasks)
      ..where((t) => t.userId.equals(userId) & t.date.equals(dateOnly))
    ).go();
  }

  /// Soft delete a daily task
  Future<bool> softDeleteDailyTask(String userId, DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    final result = await (update(dailyTasks)
      ..where((t) => t.userId.equals(userId) & t.date.equals(dateOnly))
    ).write(DailyTasksCompanion(
      deletedAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    ));
    
    return result > 0;
  }

  /// Restore a soft-deleted daily task
  Future<bool> restoreDailyTask(String userId, DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    final result = await (update(dailyTasks)
      ..where((t) => t.userId.equals(userId) & t.date.equals(dateOnly))
    ).write(DailyTasksCompanion(
      deletedAt: const Value(null),
      updatedAt: Value(DateTime.now()),
    ));
    
    return result > 0;
  }

  /// Get tasks that need to be synced (have pending changes)
  Future<List<DailyTask>> getTasksToSync(String userId) async {
    final query = select(dailyTasks)
      ..where((t) => 
          t.userId.equals(userId) & 
          t.needsSync.equals(true))
      ..orderBy([(t) => OrderingTerm.asc(t.updatedAt)]);
    
    return await query.get();
  }

  /// Mark a task as synced
  Future<bool> markTaskAsSynced(String userId, DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    final result = await (update(dailyTasks)
      ..where((t) => t.userId.equals(userId) & t.date.equals(dateOnly))
    ).write(DailyTasksCompanion(
      needsSync: const Value(false),
      lastSyncAt: Value(DateTime.now()),
    ));
    
    return result > 0;
  }

  /// Clear all data (for testing or logout)
  Future<void> clearAllData() async {
    await delete(dailyTasks).go();
  }

  /// Clear data for a specific user
  Future<int> clearUserData(String userId) async {
    return await (delete(dailyTasks)
      ..where((t) => t.userId.equals(userId))
    ).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'life_growth.db'));

    // Make sure sqlite3 is available on mobile platforms
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    // Create the database connection
    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}