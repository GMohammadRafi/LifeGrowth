import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/task_type.dart';
import '../models/task.dart';
import '../models/daily_entry.dart';
import '../models/task_entry.dart';
import '../models/custom_reminder.dart';

class SupabaseServiceV2 {
  static final SupabaseClient _client = Supabase.instance.client;

  // Task Types
  static Future<List<TaskType>> getTaskTypes() async {
    final response = await _client
        .from('task_types')
        .select()
        .eq('is_active', true)
        .order('name');

    return response.map((json) => TaskType.fromJson(json)).toList();
  }

  static Future<TaskType> createTaskType({
    required String name,
    String? description,
    required Map<String, dynamic> schemaDefinition,
  }) async {
    final response = await _client
        .from('task_types')
        .insert({
          'name': name,
          'description': description,
          'schema_definition': schemaDefinition,
        })
        .select()
        .single();

    return TaskType.fromJson(response);
  }

  // Tasks
  static Future<List<Task>> getUserTasks(String userId) async {
    final response = await _client
        .from('tasks')
        .select()
        .eq('user_id', userId)
        .eq('is_active', true)
        .isFilter('deleted_at', null)
        .order('name');

    return response.map((json) => Task.fromJson(json)).toList();
  }

  static Future<Task> createTask({
    required String taskTypeId,
    required String name,
    String? description,
    Map<String, dynamic>? customSchema,
  }) async {
    final response = await _client
        .from('tasks')
        .insert({
          'task_type_id': taskTypeId,
          'name': name,
          'description': description,
          'custom_schema': customSchema,
        })
        .select()
        .single();

    // Clear cache when tasks are modified
    clearCache();
    
    return Task.fromJson(response);
  }

  static Future<void> deleteTask(String taskId) async {
    await _client
        .from('tasks')
        .update({'deleted_at': DateTime.now().toIso8601String()})
        .eq('id', taskId);
    
    // Clear cache when tasks are modified
    clearCache();
  }

  // Daily Entries
  static Future<DailyEntry?> getDailyEntry({
    required String userId,
    required DateTime date,
  }) async {
    final response = await _client
        .from('daily_entries')
        .select()
        .eq('user_id', userId)
        .eq('date', date.toIso8601String().split('T')[0])
        .isFilter('deleted_at', null)
        .maybeSingle();

    return response != null ? DailyEntry.fromJson(response) : null;
  }

  static Future<DailyEntry> createOrUpdateDailyEntry({
    required DateTime date,
    String? notes,
    int? timezoneOffset,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final existing = await getDailyEntry(userId: userId, date: date);
    
    if (existing != null) {
      // Update existing
      final response = await _client
          .from('daily_entries')
          .update({
            'notes': notes,
            'timezone_offset': timezoneOffset ?? DateTime.now().timeZoneOffset.inMinutes,
            'client_updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', existing.id)
          .select()
          .single();
      
      return DailyEntry.fromJson(response);
    } else {
      // Create new
      final response = await _client
          .from('daily_entries')
          .insert({
            'date': date.toIso8601String().split('T')[0],
            'notes': notes,
            'timezone_offset': timezoneOffset ?? DateTime.now().timeZoneOffset.inMinutes,
            'client_updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();
      
      return DailyEntry.fromJson(response);
    }
  }

  // Task Entries
  static Future<List<TaskEntry>> getTaskEntries(String dailyEntryId) async {
    final response = await _client
        .from('task_entries')
        .select()
        .eq('daily_entry_id', dailyEntryId)
        .isFilter('deleted_at', null)
        .order('created_at');

    return response.map((json) => TaskEntry.fromJson(json)).toList();
  }

  static Future<TaskEntry> createOrUpdateTaskEntry({
    required String dailyEntryId,
    required String taskId,
    required Map<String, dynamic> data,
    bool completed = false,
  }) async {
    // Check if entry already exists
    final existing = await _client
        .from('task_entries')
        .select()
        .eq('daily_entry_id', dailyEntryId)
        .eq('task_id', taskId)
        .isFilter('deleted_at', null)
        .maybeSingle();

    if (existing != null) {
      // Update existing
      final response = await _client
          .from('task_entries')
          .update({
            'data': data,
            'completed': completed,
          })
          .eq('id', existing['id'])
          .select()
          .single();
      
      return TaskEntry.fromJson(response);
    } else {
      // Create new
      final response = await _client
          .from('task_entries')
          .insert({
            'daily_entry_id': dailyEntryId,
            'task_id': taskId,
            'data': data,
            'completed': completed,
          })
          .select()
          .single();
      
      return TaskEntry.fromJson(response);
    }
  }

  static Future<void> deleteTaskEntry(String taskEntryId) async {
    await _client
        .from('task_entries')
        .update({'deleted_at': DateTime.now().toIso8601String()})
        .eq('id', taskEntryId);
  }

  // Additional methods for undo functionality
  static Future<void> restoreDailyEntry(
    DailyEntry dailyEntry,
    List<TaskEntry> taskEntries,
  ) async {
    // Restore the daily entry by clearing deleted_at
    await _client
        .from('daily_entries')
        .update({'deleted_at': null})
        .eq('id', dailyEntry.id);

    // Restore associated task entries
    for (final taskEntry in taskEntries) {
      await _client
          .from('task_entries')
          .update({'deleted_at': null})
          .eq('id', taskEntry.id);
    }
  }

  static Future<void> updateDailyEntry(
    DailyEntry dailyEntry,
    List<TaskEntry> taskEntries,
  ) async {
    // Update the daily entry
    await _client
        .from('daily_entries')
        .update({
          'notes': dailyEntry.notes,
          'timezone_offset': dailyEntry.timezoneOffset,
          'client_updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', dailyEntry.id);

    // Update associated task entries
    for (final taskEntry in taskEntries) {
      await _client
          .from('task_entries')
          .update({
            'data': taskEntry.data,
            'completed': taskEntry.completed,
          })
          .eq('id', taskEntry.id);
    }
  }

  static Future<void> softDeleteDailyEntry(
    String userId,
    DateTime date,
  ) async {
    // Get the daily entry first
    final dailyEntry = await getDailyEntry(userId: userId, date: date);
    if (dailyEntry != null) {
      // Soft delete the daily entry
      await _client
          .from('daily_entries')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', dailyEntry.id);

      // Soft delete associated task entries
      await _client
          .from('task_entries')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('daily_entry_id', dailyEntry.id);
    }
  }

  static Future<void> restoreTaskEntry(TaskEntry taskEntry) async {
    await _client
        .from('task_entries')
        .update({'deleted_at': null})
        .eq('id', taskEntry.id);
  }

  static Future<void> updateTaskEntry(TaskEntry taskEntry) async {
    await _client
        .from('task_entries')
        .update({
          'data': taskEntry.data,
          'completed': taskEntry.completed,
        })
        .eq('id', taskEntry.id);
  }

  // Combined operations
  static Future<Map<String, dynamic>> getDailyData({
    required String userId,
    required DateTime date,
  }) async {
    final dailyEntry = await getDailyEntry(userId: userId, date: date);
    if (dailyEntry == null) {
      return {
        'dailyEntry': null,
        'taskEntries': <TaskEntry>[],
        'tasks': <Task>[],
        'taskTypes': <TaskType>[],
      };
    }

    final taskEntries = await getTaskEntries(dailyEntry.id);
    final tasks = await getUserTasks(userId);
    final taskTypes = await getTaskTypes();

    return {
      'dailyEntry': dailyEntry,
      'taskEntries': taskEntries,
      'tasks': tasks,
      'taskTypes': taskTypes,
    };
  }

  // Batch loading for better performance
  static Future<Map<String, dynamic>> getBatchDailyData({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Load all daily entries in the date range in a single query
    final response = await _client
        .from('daily_entries')
        .select()
        .eq('user_id', userId)
        .gte('date', startDate.toIso8601String().split('T')[0])
        .lte('date', endDate.toIso8601String().split('T')[0])
        .order('date');

    final dailyEntries = response.map((json) => DailyEntry.fromJson(json)).toList();
    final entriesByDate = <DateTime, DailyEntry>{};
    final dailyEntryIds = <String>[];

    for (final entry in dailyEntries) {
      final dateKey = DateTime(entry.date.year, entry.date.month, entry.date.day);
      entriesByDate[dateKey] = entry;
      dailyEntryIds.add(entry.id);
    }

    // Load all task entries for these daily entries in a single query
    final Map<String, List<TaskEntry>> taskEntriesByDailyEntry = {};
    if (dailyEntryIds.isNotEmpty) {
      final taskEntriesResponse = await _client
          .from('task_entries')
          .select()
          .inFilter('daily_entry_id', dailyEntryIds)
          .isFilter('deleted_at', null)
          .order('created_at');

      final allTaskEntries = taskEntriesResponse.map((json) => TaskEntry.fromJson(json)).toList();
      
      // Group task entries by daily entry ID
      for (final taskEntry in allTaskEntries) {
        if (!taskEntriesByDailyEntry.containsKey(taskEntry.dailyEntryId)) {
          taskEntriesByDailyEntry[taskEntry.dailyEntryId] = [];
        }
        taskEntriesByDailyEntry[taskEntry.dailyEntryId]!.add(taskEntry);
      }
    }

    // Load tasks and task types (these can be cached)
    final tasks = await getUserTasks(userId);
    final taskTypes = await getTaskTypes();

    return {
      'entriesByDate': entriesByDate,
      'taskEntriesByDailyEntry': taskEntriesByDailyEntry,
      'tasks': tasks,
      'taskTypes': taskTypes,
    };
  }

  // Helper method to check network connectivity
  static Future<bool> _hasNetworkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // Sync all pending changes for a user
  static Future<void> syncAllPendingChanges(String userId) async {
    try {
      // Check network connectivity first
      if (!await _hasNetworkConnection()) {
        throw Exception('No network connection available');
      }

      // This method would typically sync any offline changes
      // For now, we'll implement a basic version that ensures data consistency
      if (kDebugMode) {
        print('Syncing pending changes for user: $userId');
      }
      
      // Add any specific sync logic here as needed
      // This could include syncing offline data, resolving conflicts, etc.
      
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing pending changes: $e');
      }
      rethrow;
    }
  }

  // Additional methods needed by other parts of the app
  static Future<List<DailyEntry>> getAllDailyEntries(String userId) async {
    final response = await _client
        .from('daily_entries')
        .select()
        .eq('user_id', userId)
        .isFilter('deleted_at', null)
        .order('date', ascending: false);

    return response.map((json) => DailyEntry.fromJson(json)).toList();
  }

  static Future<List<TaskEntry>> getAllTaskEntries(String userId) async {
    final response = await _client
        .from('task_entries')
        .select('*, daily_entries!inner(user_id)')
        .eq('daily_entries.user_id', userId)
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false);

    return response.map((json) => TaskEntry.fromJson(json)).toList();
  }

  static Future<List<Map<String, dynamic>>> getAllDailyCheckins() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _client
        .from('daily_entries')
        .select()
        .eq('user_id', userId)
        .isFilter('deleted_at', null)
        .order('date', ascending: false);

    return response;
  }

  static Future<List<Task>> getAllTasks() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    return await getUserTasks(userId);
  }

  static Future<List<TaskType>> getAllTaskTypes() async {
    return await getTaskTypes();
  }

  static Future<List<Map<String, dynamic>>> getAllHabits() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    // Assuming habits are stored in a habits table
    final response = await _client
        .from('habits')
        .select()
        .eq('user_id', userId)
        .eq('is_active', true)
        .isFilter('deleted_at', null)
        .order('name');

    return response;
  }

  static Future<List<Map<String, dynamic>>> getAllGoals() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    // Assuming goals are stored in a goals table
    final response = await _client
        .from('goals')
        .select()
        .eq('user_id', userId)
        .eq('is_active', true)
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false);

    return response;
  }

  static Future<List<Map<String, dynamic>>> getAllJournalEntries() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    // Assuming journal entries are stored in a journal_entries table
    final response = await _client
        .from('journal_entries')
        .select()
        .eq('user_id', userId)
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false);

    return response;
  }

  // Initialize default tasks for a user based on hardcoded task types
  static Future<List<Task>> initializeDefaultTasks(String userId) async {
    final taskTypes = await getTaskTypes();
    final existingTasks = await getUserTasks(userId);
    
    // Define all default tasks to be created based on current hardcoded tasks
    final defaultTasks = [
      {'taskTypeName': 'reading_book', 'name': 'Reading Book', 'description': 'Track daily reading progress'},
      {'taskTypeName': 'stretch_exercise', 'name': 'Stretch Exercise', 'description': 'Track daily stretching routine'},
      {'taskTypeName': 'meditation', 'name': 'Meditation', 'description': 'Track daily meditation practice'},
      {'taskTypeName': 'reading_docs', 'name': 'Reading Documentation', 'description': 'Track technical documentation reading'},
      {'taskTypeName': 'learning_tech', 'name': 'Learning New Technology', 'description': 'Track technology learning progress'},
      {'taskTypeName': 'walking', 'name': 'Walking', 'description': 'Track daily walking activity'},
      {'taskTypeName': 'habit', 'name': 'Avoid Bad Habit', 'description': 'Track avoiding a specific bad habit'},
      {'taskTypeName': 'habit', 'name': 'Avoid Sweets', 'description': 'Track avoiding sweets and sugary foods'},
      {'taskTypeName': 'habit', 'name': 'Work Done Today', 'description': 'Track daily work completion'},
      {'taskTypeName': 'entertainment', 'name': 'Movie or Series', 'description': 'Track entertainment consumption'},
    ];
    
    final List<Task> createdTasks = [];
    
    for (final defaultTask in defaultTasks) {
      // Find the corresponding task type
      final taskType = taskTypes.firstWhere(
        (type) => type.name == defaultTask['taskTypeName'],
        orElse: () => throw Exception('Task type ${defaultTask['taskTypeName']} not found'),
      );
      
      // Check if user already has a task with this name and type
      final hasExistingTask = existingTasks.any((task) => 
        task.taskTypeId == taskType.id && task.name == defaultTask['name']);
      
      if (!hasExistingTask) {
        try {
          final task = await createTask(
            taskTypeId: taskType.id,
            name: defaultTask['name']!,
            description: defaultTask['description']!,
          );
          createdTasks.add(task);
          
          if (kDebugMode) {
            print('Created default task: ${defaultTask['name']}');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error creating default task ${defaultTask['name']}: $e');
          }
        }
      }
    }
    
    if (kDebugMode) {
      print('Initialized ${createdTasks.length} default tasks for user: $userId');
    }
    
    return createdTasks;
  }
  
  // Enhanced getDailyData method that ensures default tasks exist
  static Future<Map<String, dynamic>> getDailyDataWithDefaults({
    required String userId,
    required DateTime date,
  }) async {
    // Ensure user has default tasks
    await initializeDefaultTasks(userId);
    
    // Get the regular daily data
    return await getDailyData(userId: userId, date: date);
  }

  // Custom Reminders
  static Future<List<CustomReminder>> getCustomReminders() async {
    final response = await _client
        .from('custom_reminders')
        .select()
        .eq('is_active', true)
        .order('reminder_time');

    return response.map((json) => CustomReminder.fromJson(json)).toList();
  }

  static Future<CustomReminder> createCustomReminder(CustomReminder reminder) async {
    final response = await _client
        .from('custom_reminders')
        .insert(reminder.toJson())
        .select()
        .single();

    return CustomReminder.fromJson(response);
  }

  static Future<void> updateCustomReminder(CustomReminder reminder) async {
    await _client
        .from('custom_reminders')
        .update(reminder.toJson())
        .eq('id', reminder.id!);
  }

  static Future<void> deleteCustomReminder(String reminderId) async {
    await _client
        .from('custom_reminders')
        .update({'is_active': false})
        .eq('id', reminderId);
  }

  // Cache for frequently accessed data
  static Map<String, List<Task>>? _userTasksCache;
  static List<TaskType>? _taskTypesCache;
  static DateTime? _cacheTimestamp;
  static const Duration _cacheExpiry = Duration(minutes: 5);

  // Cached getUserTasks
  static Future<List<Task>> getUserTasksCached(String userId) async {
    final now = DateTime.now();
    if (_userTasksCache != null && 
        _userTasksCache!.containsKey(userId) &&
        _cacheTimestamp != null &&
        now.difference(_cacheTimestamp!).compareTo(_cacheExpiry) < 0) {
      return _userTasksCache![userId]!;
    }

    final tasks = await getUserTasks(userId);
    _userTasksCache ??= {};
    _userTasksCache![userId] = tasks;
    _cacheTimestamp = now;
    return tasks;
  }

  // Cached getTaskTypes
  static Future<List<TaskType>> getTaskTypesCached() async {
    final now = DateTime.now();
    if (_taskTypesCache != null &&
        _cacheTimestamp != null &&
        now.difference(_cacheTimestamp!).compareTo(_cacheExpiry) < 0) {
      return _taskTypesCache!;
    }

    final taskTypes = await getTaskTypes();
    _taskTypesCache = taskTypes;
    _cacheTimestamp = now;
    return taskTypes;
  }

  // Clear cache when data changes
  static void clearCache() {
    _userTasksCache = null;
    _taskTypesCache = null;
    _cacheTimestamp = null;
  }
}