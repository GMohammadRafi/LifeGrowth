import 'package:drift/drift.dart';

// Conditional imports
import 'database_web_impl.dart' if (dart.library.io) 'database_native.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
    tables: [Habits, DailyCheckins, Goals, JournalEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(createDatabase());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            // Add new tables in version 2
            await m.createTable(habits);
            await m.createTable(dailyCheckins);
            await m.createTable(goals);
            await m.createTable(journalEntries);
          }
        },
      );

  // Removed all DailyTasks CRUD operations - replaced with v2 schema

  Future<void> clearAllData() async {
    await delete(habits).go();
    await delete(dailyCheckins).go();
    await delete(goals).go();
    await delete(journalEntries).go();
  }

  Future<void> clearUserData(String userId) async {
    await (delete(habits)..where((tbl) => tbl.userId.equals(userId))).go();
    await (delete(dailyCheckins)..where((tbl) => tbl.userId.equals(userId)))
        .go();
    await (delete(goals)..where((tbl) => tbl.userId.equals(userId))).go();
    await (delete(journalEntries)..where((tbl) => tbl.userId.equals(userId)))
        .go();
  }

  // Habits CRUD operations
  Future<Habit?> getHabit(String id) async {
    return await (select(habits)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<Habit>> getAllHabitsForUser(String userId) async {
    return await (select(habits)..where((tbl) => tbl.userId.equals(userId)))
        .get();
  }

  Future<void> upsertHabit(HabitsCompanion habit) async {
    await into(habits).insertOnConflictUpdate(habit);
  }

  Future<void> deleteHabit(String id) async {
    await (delete(habits)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<List<Habit>> getHabitsToSync(String userId) async {
    return await (select(habits)
          ..where(
              (tbl) => tbl.userId.equals(userId) & tbl.needsSync.equals(true)))
        .get();
  }

  Future<void> markHabitAsSynced(String id) async {
    await (update(habits)..where((tbl) => tbl.id.equals(id))).write(
      HabitsCompanion(
        needsSync: const Value(false),
        lastSyncAt: Value(DateTime.now()),
      ),
    );
  }

  // DailyCheckins CRUD operations
  Future<DailyCheckin?> getDailyCheckin(String id) async {
    return await (select(dailyCheckins)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<DailyCheckin>> getAllDailyCheckinsForUser(String userId) async {
    return await (select(dailyCheckins)
          ..where((tbl) => tbl.userId.equals(userId)))
        .get();
  }

  Future<void> upsertDailyCheckin(DailyCheckinsCompanion checkin) async {
    await into(dailyCheckins).insertOnConflictUpdate(checkin);
  }

  Future<void> deleteDailyCheckin(String id) async {
    await (delete(dailyCheckins)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<List<DailyCheckin>> getDailyCheckinsToSync(String userId) async {
    return await (select(dailyCheckins)
          ..where(
              (tbl) => tbl.userId.equals(userId) & tbl.needsSync.equals(true)))
        .get();
  }

  Future<void> markDailyCheckinAsSynced(String id) async {
    await (update(dailyCheckins)..where((tbl) => tbl.id.equals(id))).write(
      DailyCheckinsCompanion(
        needsSync: const Value(false),
        lastSyncAt: Value(DateTime.now()),
      ),
    );
  }

  // Goals CRUD operations
  Future<Goal?> getGoal(String id) async {
    return await (select(goals)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<Goal>> getAllGoalsForUser(String userId) async {
    return await (select(goals)..where((tbl) => tbl.userId.equals(userId)))
        .get();
  }

  Future<void> upsertGoal(GoalsCompanion goal) async {
    await into(goals).insertOnConflictUpdate(goal);
  }

  Future<void> deleteGoal(String id) async {
    await (delete(goals)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<List<Goal>> getGoalsToSync(String userId) async {
    return await (select(goals)
          ..where(
              (tbl) => tbl.userId.equals(userId) & tbl.needsSync.equals(true)))
        .get();
  }

  Future<void> markGoalAsSynced(String id) async {
    await (update(goals)..where((tbl) => tbl.id.equals(id))).write(
      GoalsCompanion(
        needsSync: const Value(false),
        lastSyncAt: Value(DateTime.now()),
      ),
    );
  }

  // JournalEntries CRUD operations
  Future<JournalEntry?> getJournalEntry(String id) async {
    return await (select(journalEntries)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<JournalEntry>> getAllJournalEntriesForUser(String userId) async {
    return await (select(journalEntries)
          ..where((tbl) => tbl.userId.equals(userId)))
        .get();
  }

  Future<void> upsertJournalEntry(JournalEntriesCompanion entry) async {
    await into(journalEntries).insertOnConflictUpdate(entry);
  }

  Future<void> deleteJournalEntry(String id) async {
    await (delete(journalEntries)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<List<JournalEntry>> getJournalEntriesToSync(String userId) async {
    return await (select(journalEntries)
          ..where(
              (tbl) => tbl.userId.equals(userId) & tbl.needsSync.equals(true)))
        .get();
  }

  Future<void> markJournalEntryAsSynced(String id) async {
    await (update(journalEntries)..where((tbl) => tbl.id.equals(id))).write(
      JournalEntriesCompanion(
        needsSync: const Value(false),
        lastSyncAt: Value(DateTime.now()),
      ),
    );
  }
}

// Platform-specific database creation is handled in the imported files
