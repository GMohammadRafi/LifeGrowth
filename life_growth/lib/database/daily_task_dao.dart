import 'package:drift/drift.dart';
import '../models/daily_task.dart' as model;
import 'database.dart';
import 'tables.dart';

part 'daily_task_dao.g.dart';

@DriftAccessor(tables: [DailyTasks])
class DailyTaskDao extends DatabaseAccessor<AppDatabase> with _$DailyTaskDaoMixin {
  DailyTaskDao(AppDatabase db) : super(db);

  /// Get a daily task by user ID and date
  Future<DailyTask?> getDailyTask(String userId, DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    final query = select(dailyTasks)
      ..where((t) => t.userId.equals(userId) & t.date.equals(dateOnly));
    
    return await query.getSingleOrNull();
  }

  /// Get all daily tasks for a user (excluding soft-deleted)
  Future<List<DailyTask>> getAllDailyTasksForUser(String userId, {bool includeDeleted = false}) async {
    final query = select(dailyTasks)
      ..where((t) => t.userId.equals(userId))
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    
    if (!includeDeleted) {
      query.where((t) => t.deletedAt.isNull());
    }
    
    return await query.get();
  }

  /// Get daily tasks for a user within a date range
  Future<List<DailyTask>> getDailyTasksInRange(
    String userId,
    DateTime startDate,
    DateTime endDate, {
    bool includeDeleted = false,
  }) async {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    
    final query = select(dailyTasks)
      ..where((t) => 
          t.userId.equals(userId) & 
          t.date.isBetweenValues(start, end))
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    
    if (!includeDeleted) {
      query.where((t) => t.deletedAt.isNull());
    }
    
    return await query.get();
  }

  /// Convert model.DailyTask to DailyTasksCompanion for database operations
  DailyTasksCompanion _modelToCompanion(model.DailyTask task, {bool isUpdate = false}) {
    return DailyTasksCompanion(
      userId: Value(task.userId),
      date: Value(DateTime(task.date.year, task.date.month, task.date.day)),
      
      // Reading book
      readingBookCompleted: Value(task.readingBookCompleted),
      readingBookPages: Value(task.readingBookPages),
      readingBookTime: Value(task.readingBookTime),
      
      // Stretch
      stretchCompleted: Value(task.stretchCompleted),
      stretchMinutes: Value(task.stretchMinutes),
      stretchType: Value(task.stretchType),
      
      // Meditation
      meditationCompleted: Value(task.meditationCompleted),
      meditationMinutes: Value(task.meditationMinutes),
      
      // Reading docs
      readingDocsCompleted: Value(task.readingDocsCompleted),
      readingDocsPages: Value(task.readingDocsPages),
      readingDocsTime: Value(task.readingDocsTime),
      readingDocsNameLink: Value(task.readingDocsNameLink),
      
      // Learning tech
      learningTechCompleted: Value(task.learningTechCompleted),
      learningTechName: Value(task.learningTechName),
      learningTechTime: Value(task.learningTechTime),
      learningTechSource: Value(task.learningTechSource),
      learningTechUrl: Value(task.learningTechUrl),
      
      // Walking
      walkingCompleted: Value(task.walkingCompleted),
      walkingSteps: Value(task.walkingSteps),
      walkingTime: Value(task.walkingTime),
      
      // Avoid habit
      avoidHabitLabel: Value(task.avoidHabitLabel),
      avoidHabitValue: Value(task.avoidHabitValue),
      
      // Avoid sweets
      avoidSweetsValue: Value(task.avoidSweetsValue),
      
      // Work done
      workDoneValue: Value(task.workDoneValue),
      
      // Movie/series
      movieSeriesCompleted: Value(task.movieSeriesCompleted),
      movieSeriesName: Value(task.movieSeriesName),
      movieSeriesDuration: Value(task.movieSeriesDuration),
      movieSeriesStartTime: Value(task.movieSeriesStartTime),
      movieSeriesEndTime: Value(task.movieSeriesEndTime),
      
      // Notes
      notes: Value(task.notes),
      
      // Metadata
      createdAt: isUpdate ? const Value.absent() : Value(task.createdAt ?? DateTime.now()),
      updatedAt: Value(DateTime.now()),
      deletedAt: Value(task.deletedAt),
      timezoneOffset: Value(task.timezoneOffset),
      
      // Sync metadata
      needsSync: const Value(true),
      lastSyncAt: Value(task.lastSyncAt),
    );
  }

  /// Convert DailyTask (Drift) to model.DailyTask
  model.DailyTask _driftToModel(DailyTask driftTask) {
    return model.DailyTask(
      userId: driftTask.userId,
      date: driftTask.date,
      
      // Reading book
      readingBookCompleted: driftTask.readingBookCompleted,
      readingBookPages: driftTask.readingBookPages,
      readingBookTime: driftTask.readingBookTime,
      
      // Stretch
      stretchCompleted: driftTask.stretchCompleted,
      stretchMinutes: driftTask.stretchMinutes,
      stretchType: driftTask.stretchType,
      
      // Meditation
      meditationCompleted: driftTask.meditationCompleted,
      meditationMinutes: driftTask.meditationMinutes,
      
      // Reading docs
      readingDocsCompleted: driftTask.readingDocsCompleted,
      readingDocsPages: driftTask.readingDocsPages,
      readingDocsTime: driftTask.readingDocsTime,
      readingDocsNameLink: driftTask.readingDocsNameLink,
      
      // Learning tech
      learningTechCompleted: driftTask.learningTechCompleted,
      learningTechName: driftTask.learningTechName,
      learningTechTime: driftTask.learningTechTime,
      learningTechSource: driftTask.learningTechSource,
      learningTechUrl: driftTask.learningTechUrl,
      
      // Walking
      walkingCompleted: driftTask.walkingCompleted,
      walkingSteps: driftTask.walkingSteps,
      walkingTime: driftTask.walkingTime,
      
      // Avoid habit
      avoidHabitLabel: driftTask.avoidHabitLabel,
      avoidHabitValue: driftTask.avoidHabitValue,
      
      // Avoid sweets
      avoidSweetsValue: driftTask.avoidSweetsValue,
      
      // Work done
      workDoneValue: driftTask.workDoneValue,
      
      // Movie/series
      movieSeriesCompleted: driftTask.movieSeriesCompleted,
      movieSeriesName: driftTask.movieSeriesName,
      movieSeriesDuration: driftTask.movieSeriesDuration,
      movieSeriesStartTime: driftTask.movieSeriesStartTime,
      movieSeriesEndTime: driftTask.movieSeriesEndTime,
      
      // Notes
      notes: driftTask.notes,
      
      // Metadata
      createdAt: driftTask.createdAt,
      updatedAt: driftTask.updatedAt,
      deletedAt: driftTask.deletedAt,
      timezoneOffset: driftTask.timezoneOffset,
      lastSyncAt: driftTask.lastSyncAt,
    );
  }

  /// Insert or update a daily task using model.DailyTask
  Future<model.DailyTask> upsertDailyTask(model.DailyTask task) async {
    final companion = _modelToCompanion(task);
    final driftTask = await into(dailyTasks).insertReturning(
      companion,
      mode: InsertMode.insertOrReplace,
    );
    return _driftToModel(driftTask);
  }

  /// Update a daily task using model.DailyTask
  Future<model.DailyTask?> updateDailyTask(model.DailyTask task) async {
    final companion = _modelToCompanion(task, isUpdate: true);
    final dateOnly = DateTime(task.date.year, task.date.month, task.date.day);
    
    final result = await (update(dailyTasks)
      ..where((t) => t.userId.equals(task.userId) & t.date.equals(dateOnly))
    ).write(companion);
    
    if (result > 0) {
      return await getDailyTaskModel(task.userId, task.date);
    }
    return null;
  }

  /// Get a daily task as model.DailyTask
  Future<model.DailyTask?> getDailyTaskModel(String userId, DateTime date) async {
    final driftTask = await getDailyTask(userId, date);
    return driftTask != null ? _driftToModel(driftTask) : null;
  }

  /// Get all daily tasks for a user as model.DailyTask list
  Future<List<model.DailyTask>> getAllDailyTasksForUserModel(
    String userId, {
    bool includeDeleted = false,
  }) async {
    final driftTasks = await getAllDailyTasksForUser(userId, includeDeleted: includeDeleted);
    return driftTasks.map(_driftToModel).toList();
  }

  /// Get daily tasks in range as model.DailyTask list
  Future<List<model.DailyTask>> getDailyTasksInRangeModel(
    String userId,
    DateTime startDate,
    DateTime endDate, {
    bool includeDeleted = false,
  }) async {
    final driftTasks = await getDailyTasksInRange(
      userId,
      startDate,
      endDate,
      includeDeleted: includeDeleted,
    );
    return driftTasks.map(_driftToModel).toList();
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
      needsSync: const Value(true),
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
      needsSync: const Value(true),
    ));
    
    return result > 0;
  }

  /// Get tasks that need to be synced
  Future<List<model.DailyTask>> getTasksToSync(String userId) async {
    final query = select(dailyTasks)
      ..where((t) => 
          t.userId.equals(userId) & 
          t.needsSync.equals(true))
      ..orderBy([(t) => OrderingTerm.asc(t.updatedAt)]);
    
    final driftTasks = await query.get();
    return driftTasks.map(_driftToModel).toList();
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