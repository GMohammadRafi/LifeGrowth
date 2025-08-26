import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_type.dart';
import '../models/task.dart';
import '../models/daily_entry.dart';
import '../models/task_entry.dart';

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

    return Task.fromJson(response);
  }

  static Future<void> deleteTask(String taskId) async {
    await _client
        .from('tasks')
        .update({'deleted_at': DateTime.now().toIso8601String()})
        .eq('id', taskId);
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
}