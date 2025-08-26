import 'package:flutter/material.dart';
import '../services/csv_export_service.dart';
import '../services/telemetry_service.dart';
import '../services/error_service.dart';

class CsvExportScreen extends StatefulWidget {
  const CsvExportScreen({super.key});

  @override
  State<CsvExportScreen> createState() => _CsvExportScreenState();
}

class _CsvExportScreenState extends State<CsvExportScreen> {
  final CsvExportService _exportService = CsvExportService();
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    // Track screen view
    TelemetryService().trackScreenView('csv_export_screen');
  }

  final List<Map<String, dynamic>> _exportOptions = [
    {
      'title': 'All Data',
      'subtitle': 'Export all your Life Growth data',
      'icon': Icons.download,
      'type': 'all',
    },
    {
      'title': 'Daily Check-ins',
      'subtitle': 'Export mood, energy, and stress data',
      'icon': Icons.mood,
      'type': 'daily_checkins',
    },
    {
      'title': 'Daily Entries',
      'subtitle': 'Export daily entry records and notes',
      'icon': Icons.calendar_today,
      'type': 'daily_entries',
    },
    {
      'title': 'Task Entries',
      'subtitle': 'Export task completion data',
      'icon': Icons.task_alt,
      'type': 'task_entries',
    },
    {
      'title': 'Tasks',
      'subtitle': 'Export your custom tasks and configurations',
      'icon': Icons.assignment,
      'type': 'tasks',
    },
    {
      'title': 'Task Types',
      'subtitle': 'Export task type definitions and schemas',
      'icon': Icons.category,
      'type': 'task_types',
    },
    {
      'title': 'Habits',
      'subtitle': 'Export your habit tracking data',
      'icon': Icons.repeat,
      'type': 'habits',
    },
    {
      'title': 'Goals',
      'subtitle': 'Export your goals and progress',
      'icon': Icons.flag,
      'type': 'goals',
    },
    {
      'title': 'Journal Entries',
      'subtitle': 'Export your journal entries and reflections',
      'icon': Icons.book,
      'type': 'journal_entries',
    },
  ];

  Future<void> _exportData(String type) async {
    if (_isExporting) return;

    setState(() {
      _isExporting = true;
    });

    try {
      // Track export action
      TelemetryService().trackEvent('csv_export_started', {
        'export_type': type,
      });

      if (type == 'all') {
        await _exportService.exportAllData();
      } else {
        await _exportService.exportDataType(type);
      }

      // Track successful export
      TelemetryService().trackEvent('csv_export_completed', {
        'export_type': type,
        'success': true,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              type == 'all' 
                  ? 'All data exported successfully!' 
                  : '${_getDataTypeDisplayName(type)} exported successfully!',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Track export failure
      TelemetryService().trackEvent('csv_export_completed', {
        'export_type': type,
        'success': false,
        'error': e.toString(),
      });

      // Report error to error service
      ErrorService().reportException(e, StackTrace.current, {
        'context': 'csv_export_screen_export_data',
        'export_type': type,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  String _getDataTypeDisplayName(String type) {
    switch (type) {
      case 'daily_checkins':
        return 'Daily Check-ins';
      case 'daily_entries':
        return 'Daily Entries';
      case 'task_entries':
        return 'Task Entries';
      case 'tasks':
        return 'Tasks';
      case 'task_types':
        return 'Task Types';
      case 'habits':
        return 'Habits';
      case 'goals':
        return 'Goals';
      case 'journal_entries':
        return 'Journal Entries';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Data'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'About CSV Export',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Export your Life Growth data as CSV files that can be opened in spreadsheet applications like Excel, Google Sheets, or Numbers. This allows you to analyze your data, create custom charts, or backup your information.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Choose what to export:',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _exportOptions.length,
                itemBuilder: (context, index) {
                  final option = _exportOptions[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(
                          option['icon'] as IconData,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      title: Text(
                        option['title'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(option['subtitle'] as String),
                      trailing: _isExporting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              Icons.file_download,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      onTap: _isExporting
                          ? null
                          : () => _exportData(option['type'] as String),
                    ),
                  );
                },
              ),
            ),
            if (_isExporting)
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(width: 16),
                    Text(
                      'Exporting data...',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}