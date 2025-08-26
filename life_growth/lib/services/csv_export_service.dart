import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/daily_entry.dart';
import '../models/task_entry.dart';
import '../models/task.dart';
import '../models/task_type.dart';
import 'supabase_service_v2.dart';
import 'auth_service.dart'; // Add this import
import 'error_service.dart';

class CsvExportService {
  static final CsvExportService _instance = CsvExportService._internal();
  factory CsvExportService() => _instance;
  CsvExportService._internal();

  // Remove the instance variable since we'll use static methods
  // final SupabaseServiceV2 _supabaseService = SupabaseServiceV2();

  /// Export all data to CSV files and share them
  Future<void> exportAllData() async {
    try {
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final exportDir = Directory('${directory.path}/life_growth_export_$timestamp');
      await exportDir.create(recursive: true);

      // Export each data type
      await _exportDailyCheckins(exportDir.path);
      await _exportDailyEntries(exportDir.path);
      await _exportTaskEntries(exportDir.path);
      await _exportTasks(exportDir.path);
      await _exportTaskTypes(exportDir.path);
      await _exportHabits(exportDir.path);
      await _exportGoals(exportDir.path);
      await _exportJournalEntries(exportDir.path);

      // Create a zip-like sharing experience by sharing the directory
      final files = await exportDir.list().map((file) => XFile(file.path)).toList();
      
      if (files.isNotEmpty) {
        await Share.shareXFiles(
          files,
          text: 'Life Growth Data Export - ${DateTime.now().toIso8601String().split('T')[0]}',
          subject: 'Life Growth Data Export',
        );
      }
    } catch (e) {
      // Report error to error service
      ErrorService().reportException(e, StackTrace.current, {
        'context': 'csv_export_service_export_all_data',
      });
      throw Exception('Failed to export data: $e');
    }
  }

  /// Export specific data type
  Future<void> exportDataType(String dataType) async {
    try {
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${dataType}_export_$timestamp.csv';
      final filePath = '${directory.path}/$fileName';

      switch (dataType.toLowerCase()) {
        case 'daily_checkins':
          await _exportDailyCheckins(directory.path, fileName);
          break;
        case 'daily_entries':
          await _exportDailyEntries(directory.path, fileName);
          break;
        case 'task_entries':
          await _exportTaskEntries(directory.path, fileName);
          break;
        case 'tasks':
          await _exportTasks(directory.path, fileName);
          break;
        case 'task_types':
          await _exportTaskTypes(directory.path, fileName);
          break;
        case 'habits':
          await _exportHabits(directory.path, fileName);
          break;
        case 'goals':
          await _exportGoals(directory.path, fileName);
          break;
        case 'journal_entries':
          await _exportJournalEntries(directory.path, fileName);
          break;
        default:
          throw Exception('Unknown data type: $dataType');
      }

      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Life Growth $dataType Export - ${DateTime.now().toIso8601String().split('T')[0]}',
        subject: 'Life Growth $dataType Export',
      );
    } catch (e) {
      // Report error to error service
      ErrorService().reportException(e, StackTrace.current, {
        'context': 'csv_export_service_export_data_type',
        'data_type': dataType,
      });
      throw Exception('Failed to export $dataType: $e');
    }
  }

  Future<void> _exportDailyCheckins(String dirPath, [String? fileName]) async {
    final checkins = await SupabaseServiceV2.getAllDailyCheckins();
    final csvFileName = fileName ?? 'daily_checkins.csv';
    
    final headers = [
      'ID', 'Date', 'User ID', 'Notes', 
      'Created At', 'Updated At'
    ];
    
    final rows = checkins.map((checkin) => [
      checkin['id'],
      checkin['date'],
      checkin['user_id'],
      checkin['notes'] ?? '',
      checkin['created_at'],
      checkin['updated_at'],
    ]).map((row) => row.map((item) => item.toString()).toList()).toList();
    
    await _writeCsvFile('$dirPath/$csvFileName', headers, rows);
  }

  Future<void> _exportDailyEntries(String dirPath, [String? fileName]) async {
    final userId = AuthService.userId; // Replace SupabaseServiceV2._client.auth.currentUser?.id
    if (userId == null) throw Exception('User not authenticated');
    
    final entries = await SupabaseServiceV2.getAllDailyEntries(userId);
    final csvFileName = fileName ?? 'daily_entries.csv';
    
    final headers = [
      'ID', 'User ID', 'Date', 'Notes', 'Created At', 'Updated At'
    ];
    
    final rows = entries.map((entry) => [
      entry.id,
      entry.userId,
      entry.date.toIso8601String().split('T')[0],
      entry.notes ?? '',
      entry.createdAt.toIso8601String(),
      entry.updatedAt.toIso8601String(),
    ]).map((row) => row.map((item) => item.toString()).toList()).toList();
    
    await _writeCsvFile('$dirPath/$csvFileName', headers, rows);
  }

  Future<void> _exportTaskEntries(String dirPath, [String? fileName]) async {
    final userId = AuthService.userId; // Replace SupabaseServiceV2._client.auth.currentUser?.id
    if (userId == null) throw Exception('User not authenticated');
    
    final entries = await SupabaseServiceV2.getAllTaskEntries(userId);
    final csvFileName = fileName ?? 'task_entries.csv';
    
    final headers = [
      'ID', 'Daily Entry ID', 'Task ID', 'Completed', 'Data (JSON)', 
      'Created At', 'Updated At'
    ];
    
    final rows = entries.map((entry) => [
      entry.id,
      entry.dailyEntryId,
      entry.taskId,
      entry.completed.toString(),
      entry.data?.toString() ?? '',
      entry.createdAt.toIso8601String(),
      entry.updatedAt.toIso8601String(),
    ]).map((row) => row.map((item) => item.toString()).toList()).toList();
    
    await _writeCsvFile('$dirPath/$csvFileName', headers, rows);
  }

  Future<void> _exportTasks(String dirPath, [String? fileName]) async {
    final tasks = await SupabaseServiceV2.getAllTasks();
    final csvFileName = fileName ?? 'tasks.csv';
    
    final headers = [
      'ID', 'User ID', 'Task Type ID', 'Name', 'Description', 
      'Custom Schema (JSON)', 'Is Active', 'Created At', 'Updated At'
    ];
    
    final rows = tasks.map((task) => [
      task.id,
      task.userId,
      task.taskTypeId,
      task.name,
      task.description ?? '',
      task.customSchema?.toString() ?? '',
      task.isActive.toString(),
      task.createdAt.toIso8601String(),
      task.updatedAt.toIso8601String(),
    ]).map((row) => row.map((item) => item.toString()).toList()).toList();
    
    await _writeCsvFile('$dirPath/$csvFileName', headers, rows);
  }

  Future<void> _exportTaskTypes(String dirPath, [String? fileName]) async {
    final taskTypes = await SupabaseServiceV2.getAllTaskTypes();
    final csvFileName = fileName ?? 'task_types.csv';
    
    final headers = [
      'ID', 'Name', 'Description', 'Schema Definition (JSON)', 
      'Is Active', 'Created At', 'Updated At'
    ];
    
    final rows = taskTypes.map((taskType) => [
      taskType.id,
      taskType.name,
      taskType.description ?? '',
      taskType.schemaDefinition?.toString() ?? '',
      taskType.isActive.toString(),
      taskType.createdAt.toIso8601String(),
      taskType.updatedAt.toIso8601String(),
    ]).map((row) => row.map((item) => item.toString()).toList()).toList();
    
    await _writeCsvFile('$dirPath/$csvFileName', headers, rows);
  }

  Future<void> _exportHabits(String dirPath, [String? fileName]) async {
    final habits = await SupabaseServiceV2.getAllHabits();
    final csvFileName = fileName ?? 'habits.csv';
    
    final headers = [
      'ID', 'Name', 'Description', 'Frequency', 'Is Active', 
      'Created At', 'Updated At'
    ];
    
    final rows = habits.map((habit) => [
      habit['id'],
      habit['name'],
      habit['description'] ?? '',
      habit['frequency'] ?? '',
      habit['is_active'].toString(),
      habit['created_at'],
      habit['updated_at'],
    ]).map((row) => row.map((item) => item.toString()).toList()).toList();
    
    await _writeCsvFile('$dirPath/$csvFileName', headers, rows);
  }

  Future<void> _exportGoals(String dirPath, [String? fileName]) async {
    final goals = await SupabaseServiceV2.getAllGoals();
    final csvFileName = fileName ?? 'goals.csv';
    
    final headers = [
      'ID', 'Title', 'Description', 'Category', 'Priority', 'Target Date', 
      'Is Completed', 'Completed At', 'Progress', 'Created At', 'Updated At'
    ];
    
    final rows = goals.map((goal) => [
      goal['id'],
      goal['title'] ?? '',
      goal['description'] ?? '',
      goal['category'] ?? '',
      goal['priority'] ?? '',
      goal['target_date'] ?? '',
      goal['is_completed'].toString(),
      goal['completed_at'] ?? '',
      goal['progress']?.toString() ?? '0',
      goal['created_at'],
      goal['updated_at'],
    ]).map((row) => row.map((item) => item.toString()).toList()).toList();
    
    await _writeCsvFile('$dirPath/$csvFileName', headers, rows);
  }

  Future<void> _exportJournalEntries(String dirPath, [String? fileName]) async {
    final entries = await SupabaseServiceV2.getAllJournalEntries();
    final csvFileName = fileName ?? 'journal_entries.csv';
    
    final headers = [
      'ID', 'Title', 'Content', 'Mood', 'Tags', 
      'Created At', 'Updated At'
    ];
    
    final rows = entries.map((entry) => [
      entry['id'].toString(),
      entry['title'] ?? '',
      (entry['content'] ?? '').toString().replaceAll('\n', '\\n'), // Escape newlines for CSV
      entry['mood']?.toString() ?? '',
      entry['tags']?.toString() ?? '',
      entry['created_at'],
      entry['updated_at'],
    ]).map((row) => row.map((item) => item.toString()).toList()).toList();
    
    await _writeCsvFile('$dirPath/$csvFileName', headers, rows);
  }

  Future<void> _writeCsvFile(String filePath, List<String> headers, List<List<String>> rows) async {
    final file = File(filePath);
    final csvData = [headers, ...rows];
    final csvString = const ListToCsvConverter().convert(csvData);
    await file.writeAsString(csvString);
  }
}