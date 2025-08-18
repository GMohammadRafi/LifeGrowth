import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/daily_task.dart' as model;
import '../database/database.dart';
import 'database_service.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Get the current user
  static User? get currentUser => _client.auth.currentUser;

  // Auth methods
  static Future<AuthResponse> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<AuthResponse> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  static Future<void> signInWithOAuth(OAuthProvider provider) async {
    await _client.auth.signInWithOAuth(provider);
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Database methods for daily_tasks (offline-first)
  static Future<model.DailyTask?> getDailyTask({
    required String userId,
    required DateTime date,
  }) async {
    // First, try to get from local database
    final localTask = await DatabaseService.instance.getDailyTask(userId, date);

    // If we have internet connection, try to sync with Supabase
    try {
      final response = await _client
          .from('daily_tasks')
          .select()
          .eq('user_id', userId)
          .eq('date', date.toIso8601String().split('T')[0])
          .isFilter('deleted_at', null)
          .maybeSingle();

      if (response != null) {
        final remoteTask = model.DailyTask.fromJson(response);

        // Convert model to database entity and update local database
        if (localTask == null ||
            (remoteTask.updatedAt != null &&
                remoteTask.updatedAt!.isAfter(localTask.updatedAt))) {
          // Remote task is newer or doesn't exist locally, mark as not needing sync
          final dbTask = _convertModelToDbTask(remoteTask, needsSync: false);
          await DatabaseService.instance.upsertDailyTask(dbTask);
          return remoteTask;
        }
      }
    } catch (e) {
      // Network error, fall back to local data
      print('Network error in getDailyTask: $e');
    }

    return localTask != null ? _convertDbToModelTask(localTask) : null;
  }

  static Future<List<DailyTask>> getDailyTasks({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    bool includeDeleted = false,
  }) async {
    // First, get from local database
    List<DailyTask> localTasks = await DatabaseService.instance
        .getAllDailyTasksForUser(userId, includeDeleted: includeDeleted);

    // Filter by date range if specified
    if (startDate != null || endDate != null) {
      localTasks = localTasks.where((task) {
        if (startDate != null && task.date.isBefore(startDate)) return false;
        if (endDate != null && task.date.isAfter(endDate)) return false;
        return true;
      }).toList();
    }

    // Try to sync with Supabase
    try {
      var query = _client.from('daily_tasks').select().eq('user_id', userId);

      if (startDate != null) {
        query = query.gte('date', startDate.toIso8601String().split('T')[0]);
      }

      if (endDate != null) {
        query = query.lte('date', endDate.toIso8601String().split('T')[0]);
      }

      if (!includeDeleted) {
        query = query.isFilter('deleted_at', null);
      }

      final response = await query.order('date', ascending: false);
      final remoteTasks = response
          .map<model.DailyTask>((json) => model.DailyTask.fromJson(json))
          .toList();

      // Merge remote tasks with local tasks (remote takes precedence if newer)
      for (final remoteTask in remoteTasks) {
        final localTaskIndex = localTasks.indexWhere(
          (t) =>
              t.userId == remoteTask.userId &&
              t.date.day == remoteTask.date.day &&
              t.date.month == remoteTask.date.month &&
              t.date.year == remoteTask.date.year,
        );

        final localTask =
            localTaskIndex >= 0 ? localTasks[localTaskIndex] : null;

        if (localTask == null ||
            (remoteTask.updatedAt != null &&
                remoteTask.updatedAt!.isAfter(localTask.updatedAt))) {
          // Remote task is newer, mark as not needing sync
          final dbTask = _convertModelToDbTask(remoteTask, needsSync: false);
          await DatabaseService.instance.upsertDailyTask(dbTask);
        }
      }

      // Return updated local tasks
      return await DatabaseService.instance
          .getAllDailyTasksForUser(userId, includeDeleted: includeDeleted)
          .then((tasks) {
        if (startDate != null || endDate != null) {
          return tasks.where((task) {
            if (startDate != null && task.date.isBefore(startDate))
              return false;
            if (endDate != null && task.date.isAfter(endDate)) return false;
            return true;
          }).toList();
        }
        return tasks;
      });
    } catch (e) {
      print('Network error in getDailyTasks: $e');
      return localTasks;
    }
  }

  static Future<model.DailyTask> upsertDailyTask(model.DailyTask task) async {
    // Convert model to database entity and save to local database first
    // Mark as needing sync since this is a local update
    final dbTask = _convertModelToDbTask(task, needsSync: true);
    await DatabaseService.instance.upsertDailyTask(dbTask);

    // Try to sync with Supabase in background
    _syncTaskToSupabase(dbTask).catchError((e) {
      print('Background sync error: $e');
      // If sync fails, the task will remain marked as needing sync
    });

    return task;
  }

  static Future<void> _syncTaskToSupabase(DailyTask task) async {
    try {
      final modelTask = _convertDbToModelTask(task);
      final taskJson = modelTask.toJson();
      taskJson['client_updated_at'] = DateTime.now().toIso8601String();

      // ON CONFLICT over a partial unique index (deleted_at is null) is not supported.
      // Find existing active row by (user_id, date, deleted_at is null) and upsert by primary key instead.
      final dateOnly = modelTask.date.toIso8601String().split('T')[0];
      final existingActive = await _client
          .from('daily_tasks')
          .select('id')
          .eq('user_id', modelTask.userId!)
          .eq('date', dateOnly)
          .isFilter('deleted_at', null)
          .maybeSingle();

      if (existingActive != null && existingActive['id'] != null) {
        taskJson['id'] = existingActive['id'];
      }

      await _client.from('daily_tasks').upsert(taskJson);

      // Mark as synced in local database by updating with needsSync: false
      final syncedDbTask = _convertModelToDbTask(modelTask, needsSync: false);
      await DatabaseService.instance.upsertDailyTask(syncedDbTask);
    } catch (e) {
      // Sync failed, task will remain marked as needing sync
      rethrow;
    }
  }

  static Future<void> softDeleteDailyTask({
    required String userId,
    required DateTime date,
  }) async {
    // Always update local database first
    await DatabaseService.instance.softDeleteDailyTask(userId, date);

    // Try to sync with Supabase in background
    _syncDeleteToSupabase(userId, date, true).catchError((e) {
      print('Background sync error for soft delete: $e');
    });
  }

  static Future<void> restoreDailyTask({
    required String userId,
    required DateTime date,
  }) async {
    // Always update local database first
    await DatabaseService.instance.restoreDailyTask(userId, date);

    // Try to sync with Supabase in background
    _syncDeleteToSupabase(userId, date, false).catchError((e) {
      print('Background sync error for restore: $e');
    });
  }

  static Future<void> _syncDeleteToSupabase(
      String userId, DateTime date, bool isDelete) async {
    try {
      await _client
          .from('daily_tasks')
          .update({
            'deleted_at': isDelete ? DateTime.now().toIso8601String() : null,
            'client_updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('date', date.toIso8601String().split('T')[0]);

      // Mark as synced in local database by getting the task and updating it
      final localTask =
          await DatabaseService.instance.getDailyTask(userId, date);
      if (localTask != null) {
        final modelTask = _convertDbToModelTask(localTask);
        final syncedDbTask = _convertModelToDbTask(modelTask, needsSync: false);
        await DatabaseService.instance.upsertDailyTask(syncedDbTask);
      }
    } catch (e) {
      // Sync failed, task will remain marked as needing sync
      rethrow;
    }
  }

  static Future<List<DailyTask>> getDeletedTasks({
    required String userId,
    int daysBack = 7,
  }) async {
    // First, get from local database
    final localTasks = await DatabaseService.instance
        .getAllDailyTasksForUser(userId, includeDeleted: true);

    final cutoffDate = DateTime.now().subtract(Duration(days: daysBack));
    final localDeletedTasks = localTasks
        .where((task) =>
            task.deletedAt != null && task.deletedAt!.isAfter(cutoffDate))
        .toList();

    // Try to sync with Supabase
    try {
      final response = await _client
          .from('daily_tasks')
          .select()
          .eq('user_id', userId)
          .not('deleted_at', 'is', null)
          .gte('deleted_at', cutoffDate.toIso8601String())
          .order('deleted_at', ascending: false);

      final remoteTasks = response
          .map<model.DailyTask>((json) => model.DailyTask.fromJson(json))
          .toList();

      // Merge and update local database
      for (final remoteTask in remoteTasks) {
        // Convert remote task and mark as not needing sync
        final dbTask = _convertModelToDbTask(remoteTask, needsSync: false);
        await DatabaseService.instance.upsertDailyTask(dbTask);
      }

      // Return updated local tasks
      final updatedLocalTasks = await DatabaseService.instance
          .getAllDailyTasksForUser(userId, includeDeleted: true);
      return updatedLocalTasks
          .where((task) =>
              task.deletedAt != null && task.deletedAt!.isAfter(cutoffDate))
          .toList();
    } catch (e) {
      print('Network error in getDeletedTasks: $e');
      return localDeletedTasks;
    }
  }

  static Future<void> permanentlyDeleteTask({
    required String userId,
    required DateTime date,
  }) async {
    // Always delete from local database first
    await DatabaseService.instance.permanentlyDeleteDailyTask(userId, date);

    // Try to sync with Supabase in background
    _syncPermanentDeleteToSupabase(userId, date).catchError((e) {
      print('Background sync error for permanent delete: $e');
    });
  }

  static Future<void> _syncPermanentDeleteToSupabase(
      String userId, DateTime date) async {
    try {
      await _client
          .from('daily_tasks')
          .delete()
          .eq('user_id', userId)
          .eq('date', date.toIso8601String().split('T')[0]);
    } catch (e) {
      // Sync failed, but local delete already happened
      rethrow;
    }
  }

  // Comprehensive sync method for offline support
  static Future<void> syncAllPendingChanges(String userId) async {
    try {
      // Get all tasks that need syncing
      final tasksToSync = await DatabaseService.instance.getTasksToSync();

      for (final task in tasksToSync) {
        await _syncTaskToSupabase(task);
      }

      // Pull latest changes from Supabase
      final lastSyncTime =
          DateTime.now().subtract(Duration(days: 30)); // Sync last 30 days
      final remoteTasks =
          await getTasksModifiedAfter(userId: userId, timestamp: lastSyncTime);

      // Update local database with remote changes
      for (final remoteTask in remoteTasks) {
        final localTask = await DatabaseService.instance
            .getDailyTask(userId, remoteTask.date);
        if (localTask == null ||
            remoteTask.updatedAt.isAfter(localTask.updatedAt)) {
          // Mark remote task as not needing sync and upsert
          final dbTask = remoteTask.copyWith(needsSync: false);
          await DatabaseService.instance.upsertDailyTask(dbTask);
        }
      }
    } catch (e) {
      print('Sync error: $e');
      rethrow;
    }
  }

  static Future<List<DailyTask>> getTasksModifiedAfter({
    required String userId,
    required DateTime timestamp,
  }) async {
    final response = await _client
        .from('daily_tasks')
        .select()
        .eq('user_id', userId)
        .gte('updated_at', timestamp.toIso8601String())
        .order('updated_at', ascending: true);

    return response
        .map<DailyTask>((json) => _convertModelToDbTask(
            model.DailyTask.fromJson(json),
            needsSync: false))
        .toList();
  }

  static Future<List<DailyTask>> syncTasks(List<DailyTask> localTasks) async {
    final List<DailyTask> syncedTasks = [];

    for (final task in localTasks) {
      try {
        // Convert database task to model task, sync it, then convert back
        final modelTask = _convertDbToModelTask(task);
        final syncedModelTask = await upsertDailyTask(modelTask);
        final syncedDbTask = _convertModelToDbTask(syncedModelTask);
        syncedTasks.add(syncedDbTask);
      } catch (e) {
        // Handle conflict resolution here
        // For now, just rethrow the error
        rethrow;
      }
    }

    return syncedTasks;
  }

  // Helper method to convert model DailyTask to database DailyTask
  static DailyTask _convertModelToDbTask(model.DailyTask modelTask,
      {bool needsSync = true}) {
    // Normalize date to date-only format (required by database constraint)
    final dateOnly =
        DateTime(modelTask.date.year, modelTask.date.month, modelTask.date.day);

    return DailyTask(
      userId: modelTask.userId ?? '',
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
      movieSeriesCompleted: modelTask.movieSeriesCompleted,
      movieSeriesName: modelTask.movieSeriesName,
      movieSeriesDuration: modelTask.movieSeriesDuration,
      movieSeriesStartTime: modelTask.movieSeriesStartTime,
      movieSeriesEndTime: modelTask.movieSeriesEndTime,
      notes: modelTask.notes,
      createdAt: modelTask.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(), // Always update the timestamp when converting
      deletedAt: modelTask.deletedAt,
      timezoneOffset: modelTask.timezoneOffset,
      needsSync: needsSync, // Allow control over sync flag
      lastSyncAt: needsSync
          ? null
          : DateTime.now(), // Only set lastSyncAt if not needing sync
    );
  }

  // Helper method to convert database DailyTask to model DailyTask
  static model.DailyTask _convertDbToModelTask(DailyTask dbTask) {
    return model.DailyTask(
      userId: dbTask.userId,
      date: dbTask.date,
      readingBookCompleted: dbTask.readingBookCompleted,
      readingBookPages: dbTask.readingBookPages,
      readingBookTime: dbTask.readingBookTime,
      stretchCompleted: dbTask.stretchCompleted,
      stretchMinutes: dbTask.stretchMinutes,
      stretchType: dbTask.stretchType,
      meditationCompleted: dbTask.meditationCompleted,
      meditationMinutes: dbTask.meditationMinutes,
      readingDocsCompleted: dbTask.readingDocsCompleted,
      readingDocsPages: dbTask.readingDocsPages,
      readingDocsTime: dbTask.readingDocsTime,
      readingDocsNameLink: dbTask.readingDocsNameLink,
      learningTechCompleted: dbTask.learningTechCompleted,
      learningTechName: dbTask.learningTechName,
      learningTechTime: dbTask.learningTechTime,
      learningTechSource: dbTask.learningTechSource,
      learningTechUrl: dbTask.learningTechUrl,
      walkingCompleted: dbTask.walkingCompleted,
      walkingSteps: dbTask.walkingSteps,
      walkingTime: dbTask.walkingTime,
      avoidHabitLabel: dbTask.avoidHabitLabel,
      avoidHabitValue: dbTask.avoidHabitValue,
      avoidSweetsValue: dbTask.avoidSweetsValue,
      workDoneValue: dbTask.workDoneValue,
      movieSeriesCompleted: dbTask.movieSeriesCompleted,
      movieSeriesName: dbTask.movieSeriesName,
      movieSeriesDuration: dbTask.movieSeriesDuration,
      movieSeriesStartTime: dbTask.movieSeriesStartTime,
      movieSeriesEndTime: dbTask.movieSeriesEndTime,
      notes: dbTask.notes,
      createdAt: dbTask.createdAt,
      updatedAt: dbTask.updatedAt,
      deletedAt: dbTask.deletedAt,
      timezoneOffset: dbTask.timezoneOffset ?? 0,
    );
  }
}
