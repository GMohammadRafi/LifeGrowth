import 'package:flutter/material.dart';
import '../services/csv_export_service.dart';

class CsvExportScreen extends StatefulWidget {
  const CsvExportScreen({super.key});

  @override
  State<CsvExportScreen> createState() => _CsvExportScreenState();
}

class _CsvExportScreenState extends State<CsvExportScreen> {
  final CsvExportService _exportService = CsvExportService();
  bool _isExporting = false;

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
      'title': 'Daily Tasks',
      'subtitle': 'Export all daily task completion data',
      'icon': Icons.task_alt,
      'type': 'daily_tasks',
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
      if (type == 'all') {
        await _exportService.exportAllData();
      } else {
        await _exportService.exportDataType(type);
      }

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
      case 'daily_tasks':
        return 'Daily Tasks';
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