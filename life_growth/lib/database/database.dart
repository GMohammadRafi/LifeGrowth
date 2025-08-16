import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

// Conditional imports
import 'database_native.dart' if (dart.library.html) 'database_web_impl.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [DailyTasks])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(createDatabase());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Handle database upgrades here
    },
  );

  // CRUD operations for DailyTasks
  Future<DailyTask?> getDailyTask(String userId, DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    final query = select(dailyTasks)
      ..where((t) => t.userId.equals(userId) & t.date.equals(dateOnly));
    
    return await query.getSingleOrNull();
  }

  Future<List<DailyTask>> getAllDailyTasksForUser(String userId, {bool includeDeleted = false}) async {
    final query = select(dailyTasks)
      ..where((t) => t.userId.equals(userId))
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    
    if (!includeDeleted) {
      query.where((t) => t.deletedAt.isNull());
    }
    
    return await query.get();
  }

  Future<void> upsertDailyTask(DailyTask task) async {
    await into(dailyTasks).insertOnConflictUpdate(task);
  }

  Future<void> deleteDailyTask(String userId, DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    await (delete(dailyTasks)
      ..where((t) => t.userId.equals(userId) & t.date.equals(dateOnly))
    ).go();
  }

  Future<void> softDeleteDailyTask(String userId, DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    await (update(dailyTasks)
      ..where((t) => t.userId.equals(userId) & t.date.equals(dateOnly))
    ).write(DailyTasksCompanion(
      deletedAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> restoreDailyTask(String userId, DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    await (update(dailyTasks)
      ..where((t) => t.userId.equals(userId) & t.date.equals(dateOnly))
    ).write(const DailyTasksCompanion(
      deletedAt: Value(null),
      updatedAt: Value.absent(),
    ));
  }

  Future<List<DailyTask>> getTasksToSync() async {
    final query = select(dailyTasks)
      ..where((t) => t.needsSync.equals(true))
      ..orderBy([(t) => OrderingTerm.asc(t.updatedAt)]);
    
    return await query.get();
  }

  Future<void> markTaskAsSynced(String userId, DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    await (update(dailyTasks)
      ..where((t) => t.userId.equals(userId) & t.date.equals(dateOnly))
    ).write(DailyTasksCompanion(
      needsSync: const Value(false),
      lastSyncAt: Value(DateTime.now()),
    ));
  }

  Future<void> clearAllData() async {
    await delete(dailyTasks).go();
  }

  Future<void> clearUserData(String userId) async {
    await (delete(dailyTasks)
      ..where((t) => t.userId.equals(userId))
    ).go();
  }
}

// Platform-specific database creation is handled in the imported files