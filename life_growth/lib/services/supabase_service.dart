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
  static Future<DailyTask?> getDailyTask({
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
            (remoteTask.updatedAt != null && localTask.updatedAt != null &&
             remoteTask.updatedAt!.isAfter(localTask.updatedAt!))) {
          final dbTask = _convertModelToDbTask(remoteTask);
          await DatabaseService.instance.upsertDailyTask(dbTask);
          await DatabaseService.instance.markTaskAsSynced(userId, date);
          return dbTask;
        }
      }
    } catch (e) {
      // Network error, fall back to local data
      print('Network error in getDailyTask: $e');
    }
    
    return localTask;
  }
  
  static Future<List<DailyTask>> getDailyTasks({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    bool includeDeleted = false,
  }) async {
    // First, get from local database
    List<DailyTask> localTasks = await DatabaseService.instance.getAllDailyTasksForUser(
      userId, includeDeleted: includeDeleted);
    
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
      var query = _client
          .from('daily_tasks')
          .select()
          .eq('user_id', userId);
      
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
      final remoteTasks = response.map<model.DailyTask>((json) => model.DailyTask.fromJson(json)).toList();
      
      // Merge remote tasks with local tasks (remote takes precedence if newer)
      for (final remoteTask in remoteTasks) {
        final localTaskIndex = localTasks.indexWhere(
          (t) => t.userId == remoteTask.userId && 
                 t.date.day == remoteTask.date.day &&
                 t.date.month == remoteTask.date.month &&
                 t.date.year == remoteTask.date.year,
        );
        
        final localTask = localTaskIndex >= 0 ? localTasks[localTaskIndex] : null;
        
        if (localTask == null || localTask.updatedAt == null || 
            (remoteTask.updatedAt != null && remoteTask.updatedAt!.isAfter(localTask.updatedAt!))) {
          final dbTask = _convertModelToDbTask(remoteTask);
          await DatabaseService.instance.upsertDailyTask(dbTask);
          await DatabaseService.instance.markTaskAsSynced(userId, remoteTask.date);
        }
      }
      
      // Return updated local tasks
      return await DatabaseService.instance.getAllDailyTasksForUser(
        userId, includeDeleted: includeDeleted).then((tasks) {
        if (startDate != null || endDate != null) {
          return tasks.where((task) {
            if (startDate != null && task.date.isBefore(startDate)) return false;
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
  
  static Future<DailyTask> upsertDailyTask(DailyTask task) async {
    // Always save to local database first
    final localTask = await DatabaseService.instance.upsertDailyTask(task);
    
    // Try to sync with Supabase in background
    _syncTaskToSupabase(localTask).catchError((e) {
      print('Background sync error: $e');
    });
    
    return localTask;
  }
  
  static Future<void> _syncTaskToSupabase(DailyTask task) async {
    try {
      final modelTask = _convertDbToModelTask(task);
      final taskJson = modelTask.toJson();
      taskJson['client_updated_at'] = DateTime.now().toIso8601String();
      
      await _client
          .from('daily_tasks')
          .upsert(taskJson, onConflict: 'user_id,date');
      
      // Mark as synced in local database
      await DatabaseService.instance.markTaskAsSynced(task.userId, task.date);
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
  
  static Future<void> _syncDeleteToSupabase(String userId, DateTime date, bool isDelete) async {
    try {
      await _client
          .from('daily_tasks')
          .update({
            'deleted_at': isDelete ? DateTime.now().toIso8601String() : null,
            'client_updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('date', date.toIso8601String().split('T')[0]);
      
      // Mark as synced in local database
      await DatabaseService.instance.markTaskAsSynced(userId, date);
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
    final localTasks = await DatabaseService.instance.getAllDailyTasksForUser(
      userId, includeDeleted: true);
    
    final cutoffDate = DateTime.now().subtract(Duration(days: daysBack));
    final localDeletedTasks = localTasks.where((task) => 
      task.deletedAt != null && 
      task.deletedAt!.isAfter(cutoffDate)
    ).toList();
    
    // Try to sync with Supabase
    try {
      final response = await _client
          .from('daily_tasks')
          .select()
          .eq('user_id', userId)
          .not('deleted_at', 'is', null)
          .gte('deleted_at', cutoffDate.toIso8601String())
          .order('deleted_at', ascending: false);
      
      final remoteTasks = response.map<DailyTask>((json) => DailyTask.fromJson(json)).toList();
      
      // Merge and update local database
      for (final remoteTask in remoteTasks) {
        await DatabaseService.instance.upsertDailyTask(remoteTask);
        await DatabaseService.instance.markTaskAsSynced(userId, remoteTask.date);
      }
      
      // Return updated local tasks
      final updatedLocalTasks = await DatabaseService.instance.getAllDailyTasksForUser(
        userId, includeDeleted: true);
      return updatedLocalTasks.where((task) => 
        task.deletedAt != null && 
        task.deletedAt!.isAfter(cutoffDate)
      ).toList();
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
  
  static Future<void> _syncPermanentDeleteToSupabase(String userId, DateTime date) async {
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
      final lastSyncTime = DateTime.now().subtract(Duration(days: 30)); // Sync last 30 days
      final remoteTasks = await getTasksModifiedAfter(
        userId: userId, 
        timestamp: lastSyncTime
      );
      
      // Update local database with remote changes
      for (final remoteTask in remoteTasks) {
        final localTask = await DatabaseService.instance.getDailyTask(userId, remoteTask.date);
        if (localTask == null || 
            (remoteTask.updatedAt != null && 
             (localTask.updatedAt == null || remoteTask.updatedAt!.isAfter(localTask.updatedAt!)))) {
          await DatabaseService.instance.upsertDailyTask(remoteTask);
          await DatabaseService.instance.markTaskAsSynced(userId, remoteTask.date);
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
    
    return response.map<DailyTask>((json) => DailyTask.fromJson(json)).toList();
  }
  
  static Future<List<DailyTask>> syncTasks(List<DailyTask> localTasks) async {
    final List<DailyTask> syncedTasks = [];
    
    for (final task in localTasks) {
      try {
        final synced = await upsertDailyTask(task);
        syncedTasks.add(synced);
      } catch (e) {
        // Handle conflict resolution here
        // For now, just rethrow the error
        rethrow;
      }
    }
    
    return syncedTasks;
  }

  // Helper method to convert model DailyTask to database DailyTask
  static DailyTask _convertModelToDbTask(model.DailyTask modelTask) {
    return DailyTask(
      userId: modelTask.userId,
      date: modelTask.date,
      readingBook: modelTask.readingBook,
      stretch: modelTask.stretch,
      meditation: modelTask.meditation,
      exercise: modelTask.exercise,
      healthyEating: modelTask.healthyEating,
      noSmoking: modelTask.noSmoking,
      noDrinking: modelTask.noDrinking,
      skincare: modelTask.skincare,
      createdAt: modelTask.createdAt,
      updatedAt: modelTask.updatedAt,
      deletedAt: modelTask.deletedAt,
      timezoneOffset: modelTask.timezoneOffset,
      needsSync: false,
      lastSyncAt: DateTime.now(),
    );
  }

  // Helper method to convert database DailyTask to model DailyTask
  static model.DailyTask _convertDbToModelTask(DailyTask dbTask) {
    return model.DailyTask(
      userId: dbTask.userId,
      date: dbTask.date,
      readingBook: dbTask.readingBook,
      stretch: dbTask.stretch,
      meditation: dbTask.meditation,
      exercise: dbTask.exercise,
      healthyEating: dbTask.healthyEating,
      noSmoking: dbTask.noSmoking,
      noDrinking: dbTask.noDrinking,
      skincare: dbTask.skincare,
      createdAt: dbTask.createdAt,
      updatedAt: dbTask.updatedAt,
      deletedAt: dbTask.deletedAt,
      timezoneOffset: dbTask.timezoneOffset,
    );
  }
}