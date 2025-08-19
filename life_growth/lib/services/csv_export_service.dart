import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/daily_task.dart' as daily_task_model;
import 'database_service.dart';
import 'error_service.dart';

class CsvExportService {
  static final CsvExportService _instance = CsvExportService._internal();
  factory CsvExportService() => _instance;
  CsvExportService._internal();

  final DatabaseService _databaseService = DatabaseService.instance;

  /// Export all data to CSV files and share them
  Future<void> exportAllData() async {
    try {
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final exportDir = Directory('${directory.path}/life_growth_export_$timestamp');
      await exportDir.create(recursive: true);

      // Export each data type
      await _exportDailyCheckins(exportDir.path);
      await _exportDailyTasksToFile(exportDir.path);
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
        case 'daily_tasks':
          await _exportDailyTasksToFile(directory.path, fileName);
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
    final checkins = await _databaseService.getAllDailyCheckins();
    final csvFileName = fileName ?? 'daily_checkins.csv';
    
    final headers = [
      'ID', 'Date', 'Mood', 'Energy', 'Stress', 'Notes', 
      'Created At', 'Updated At', 'Needs Sync', 'Last Sync At'
    ];
    
    final rows = checkins.map((checkin) => [
      checkin.id,
      checkin.date.toIso8601String().split('T')[0],
      checkin.mood.toString(),
      checkin.energy.toString(),
      checkin.stress.toString(),
      checkin.notes,
      checkin.createdAt.toIso8601String(),
      checkin.updatedAt.toIso8601String(),
      checkin.needsSync.toString(),
      checkin.lastSyncAt?.toIso8601String() ?? '',
    ]).map((row) => row.map((item) => item.toString()).toList()).toList();
    
    await _writeCsvFile('$dirPath/$csvFileName', headers, rows);
  }

  Future<void> _exportDailyTasksToFile(String dirPath, [String? fileName]) async {
    final tasks = await _databaseService.getAllDailyTasks();
    final csvFileName = fileName ?? 'daily_tasks.csv';
    final csvData = _exportDailyTasks(tasks);
    await _writeCsvFile('$dirPath/$csvFileName', csvData.first, csvData.skip(1).toList());
  }

  List<List<String>> _exportDailyTasks(List<daily_task_model.DailyTask> tasks) {
    final headers = [
      'ID', 'User ID', 'Date', 'Reading Book Pages', 'Reading Book Time', 'Reading Book Completed',
      'Stretch Type', 'Stretch Minutes', 'Stretch Completed', 'Meditation Minutes', 'Meditation Completed',
      'Reading Docs Name/Link', 'Reading Docs Pages', 'Reading Docs Time', 'Reading Docs Completed',
      'Learning Tech Name', 'Learning Tech Source', 'Learning Tech URL', 'Learning Tech Time', 'Learning Tech Completed',
      'Walking Steps', 'Walking Time', 'Walking Completed', 'Avoid Habit Label', 'Avoid Habit Value',
      'Movie Series Name', 'Movie Series Time', 'Movie Series Completed',
      'Created At', 'Updated At'
    ];
    
    final rows = tasks.map((task) {
      return [
        task.id ?? '',
        task.userId ?? '',
        task.date.toIso8601String(),
        task.readingBookPages?.toString() ?? '',
        task.readingBookTime?.toString() ?? '',
        task.readingBookCompleted.toString(),
        task.stretchType ?? '',
        task.stretchMinutes?.toString() ?? '',
        task.stretchCompleted.toString(),
        task.meditationMinutes?.toString() ?? '',
        task.meditationCompleted.toString(),
        task.readingDocsNameLink ?? '',
        task.readingDocsPages?.toString() ?? '',
        task.readingDocsTime?.toString() ?? '',
        task.readingDocsCompleted.toString(),
        task.learningTechName ?? '',
        task.learningTechSource ?? '',
        task.learningTechUrl ?? '',
        task.learningTechTime?.toString() ?? '',
        task.learningTechCompleted.toString(),
        task.walkingSteps?.toString() ?? '',
        task.walkingTime?.toString() ?? '',
        task.walkingCompleted.toString(),
        task.avoidHabitLabel ?? '',
        task.avoidHabitValue.toString(),
        task.movieSeriesName ?? '',
        task.movieSeriesDuration?.toString() ?? '',
        task.movieSeriesCompleted.toString(),
        task.createdAt?.toIso8601String() ?? '',
        task.updatedAt?.toIso8601String() ?? '',
      ];
    }).map((row) => row.map((item) => item.toString()).toList()).toList();
    
    return [headers, ...rows];
  }

  Future<void> _exportHabits(String dirPath, [String? fileName]) async {
    final habits = await _databaseService.getAllHabits();
    final csvFileName = fileName ?? 'habits.csv';
    
    final headers = [
      'ID', 'Name', 'Description', 'Frequency', 'Is Active', 
      'Created At', 'Updated At', 'Needs Sync', 'Last Sync At'
    ];
    
    final rows = habits.map((habit) => [
      habit.id,
      habit.name,
      habit.description,
      habit.frequency.name,
      habit.isActive.toString(),
      habit.createdAt.toIso8601String(),
      habit.updatedAt.toIso8601String(),
      habit.needsSync.toString(),
      habit.lastSyncAt?.toIso8601String() ?? '',
    ]).map((row) => row.map((item) => item.toString()).toList()).toList();
    
    await _writeCsvFile('$dirPath/$csvFileName', headers, rows);
  }

  Future<void> _exportGoals(String dirPath, [String? fileName]) async {
    final goals = await _databaseService.getAllGoals();
    final csvFileName = fileName ?? 'goals.csv';
    
    final headers = [
      'ID', 'Title', 'Description', 'Category', 'Priority', 'Target Date', 
      'Is Completed', 'Completed At', 'Progress', 'Created At', 'Updated At', 
      'Needs Sync', 'Last Sync At'
    ];
    
    final rows = goals.map((goal) => [
      goal.id,
      goal.title,
      goal.description,
      goal.category.name,
      goal.priority.name,
      goal.targetDate.toIso8601String().split('T')[0],
      goal.isCompleted.toString(),
      goal.completedAt?.toIso8601String() ?? '',
      goal.progress.toString(),
      goal.createdAt.toIso8601String(),
      goal.updatedAt.toIso8601String(),
      goal.needsSync.toString(),
      goal.lastSyncAt?.toIso8601String() ?? '',
    ]).map((row) => row.map((item) => item.toString()).toList()).toList();
    
    await _writeCsvFile('$dirPath/$csvFileName', headers, rows);
  }

  Future<void> _exportJournalEntries(String dirPath, [String? fileName]) async {
    final entries = await _databaseService.getAllJournalEntries();
    final csvFileName = fileName ?? 'journal_entries.csv';
    
    final headers = [
      'ID', 'Title', 'Content', 'Mood', 'Tags', 
      'Created At', 'Updated At', 'Needs Sync', 'Last Sync At'
    ];
    
    final rows = entries.map((entry) => [
      entry.id.toString(),
      entry.title,
      entry.content.replaceAll('\n', '\\n'), // Escape newlines for CSV
      entry.mood.toString(),
      entry.tags.join(';'), // Join tags with semicolon
      entry.createdAt.toIso8601String(),
      entry.updatedAt.toIso8601String(),
      entry.needsSync.toString(),
      entry.lastSyncAt?.toIso8601String() ?? '',
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