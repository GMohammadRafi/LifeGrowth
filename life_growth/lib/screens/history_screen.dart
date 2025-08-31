import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../models/daily_entry.dart';
import '../models/task_entry.dart';
import '../models/task.dart';
import '../models/task_type.dart';
import '../services/auth_service.dart';
import '../services/supabase_service_v2.dart';
import '../services/telemetry_service.dart';
import '../providers/undo_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final ValueNotifier<List<DailyEntry>> _selectedEntries;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, DailyEntry> _entriesByDate = {};
  Map<String, List<TaskEntry>> _taskEntriesByDailyEntry = {};
  List<Task> _userTasks = [];
  List<TaskType> _taskTypes = [];
  bool _isLoading = true;
  bool _includeDeleted = false;

  @override
  void initState() {
    super.initState();
    // Track screen view
    TelemetryService().trackScreenView('history_screen');
    _selectedDay = DateTime.now();
    _selectedEntries = ValueNotifier(_getEntriesForDay(_selectedDay!));
    _loadHistoryData();
  }

  @override
  void dispose() {
    _selectedEntries.dispose();
    super.dispose();
  }

  Future<void> _loadHistoryData() async {
    if (!AuthService.isAuthenticated) return;

    setState(() => _isLoading = true);

    try {
      // Load user's tasks and task types first
      final tasks = await SupabaseServiceV2.getUserTasks(AuthService.userId!); // Fixed: replaced _auth.currentUser!.uid
      final taskTypes = await SupabaseServiceV2.getTaskTypes();
      
      _userTasks = tasks;
      _taskTypes = taskTypes;

      // Load daily entries for the current month (or a reasonable range)
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month - 3, 1); // 3 months back
      final endDate = DateTime(now.year, now.month + 1, 0); // End of current month
      
      final Map<DateTime, DailyEntry> entriesByDate = {};
      final Map<String, List<TaskEntry>> taskEntriesByDailyEntry = {};
      
      // Load entries for each day in the range
      for (DateTime date = startDate; date.isBefore(endDate); date = date.add(const Duration(days: 1))) {
        try {
          final dailyData = await SupabaseServiceV2.getDailyData(
            userId: AuthService.userId!, // Fixed: replaced _auth.currentUser!.uid
            date: date,
          );
          final dailyEntry = dailyData['dailyEntry'] as DailyEntry?;
          final taskEntries = dailyData['taskEntries'] as List<TaskEntry>? ?? [];
          
          if (dailyEntry != null) {
            final dateKey = DateTime(date.year, date.month, date.day);
            entriesByDate[dateKey] = dailyEntry;
            taskEntriesByDailyEntry[dailyEntry.id] = taskEntries;
          }
        } catch (e) {
          // Skip days with no data or errors
          continue;
        }
      }

      setState(() {
        _entriesByDate = entriesByDate;
        _taskEntriesByDailyEntry = taskEntriesByDailyEntry;
        _isLoading = false;
      });

      // Update selected entries
      _selectedEntries.value = _getEntriesForDay(_selectedDay!);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load history: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<DailyEntry> _getEntriesForDay(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    final entry = _entriesByDate[dateKey];
    return entry != null ? [entry] : [];
  }

  int _getCompletedTasksCount(DailyEntry entry) {
    final taskEntries = _taskEntriesByDailyEntry[entry.id] ?? [];
    return taskEntries.where((taskEntry) => taskEntry.completed).length;
  }

  int _getTotalTasksCount() {
    return _userTasks.length;
  }

  Future<void> _softDeleteEntry(DailyEntry entry) async {
    try {
      // Record the delete action before actually deleting
      final undoProvider = Provider.of<UndoProvider>(context, listen: false);
      // Note: UndoProvider will need to be updated to work with v2 models
      
      // For now, we'll implement a simple delete without undo functionality
      // This would need to be implemented in SupabaseServiceV2
      // await SupabaseServiceV2.softDeleteDailyEntry(entry.id);
      
      // Update UI immediately
      await _loadHistoryData();
      _selectedEntries.value = _getEntriesForDay(_selectedDay!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entry deleted'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete entry: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _restoreEntry(DailyEntry entry) async {
    try {
      // This would need to be implemented in SupabaseServiceV2
      // await SupabaseServiceV2.restoreDailyEntry(entry.id);
      
      // Update UI immediately
      await _loadHistoryData();
      _selectedEntries.value = _getEntriesForDay(_selectedDay!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entry restored'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to restore entry: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _selectedEntries.value = _getEntriesForDay(selectedDay);
    }
  }

  Widget _buildEntryCard(DailyEntry entry) {
    final isDeleted = entry.deletedAt != null;
    final completedCount = _getCompletedTasksCount(entry);
    final totalCount = _getTotalTasksCount();
    final taskEntries = _taskEntriesByDailyEntry[entry.id] ?? [];

    return Opacity(
      opacity: isDeleted ? 0.6 : 1.0,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: isDeleted
                ? Colors.grey
                : (completedCount > (totalCount * 0.7)
                    ? Colors.green
                    : completedCount > (totalCount * 0.3)
                        ? Colors.orange
                        : Colors.red),
            child: isDeleted
                ? const Icon(
                    Icons.visibility_off,
                    color: Colors.white,
                    size: 18,
                  )
                : Text(
                    '$completedCount',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
          ),
          title: Text(
            '${entry.date.day}/${entry.date.month}/${entry.date.year}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              decoration: isDeleted ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Completed: $completedCount/$totalCount tasks'),
              if (entry.notes != null && entry.notes!.isNotEmpty)
                Text(
                  entry.notes!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              if (isDeleted)
                const Text(
                  'Deleted',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isDeleted) ...[ // Fixed: added three dots for spread operator
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editEntry(entry),
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteEntry(entry.date),
                ),
              ] else
                IconButton(
                  icon: const Icon(Icons.restore_rounded),
                  onPressed: () => _restoreEntry(entry),
                  tooltip: 'Restore',
                ),
            ],
          ),
          onTap: isDeleted ? null : () => _editEntry(entry),
        ),
      ),
    );
  }

  Future<void> _editEntry(DailyEntry entry) async {
    final taskEntries = _taskEntriesByDailyEntry[entry.id] ?? [];
    
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _editEntry(entry),
          tooltip: 'Edit',
        ),
      ),
    );

    if (result == true) {
      await _loadHistoryData();
    }
  }

  Future<void> _confirmDelete(DailyEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text(
          'Are you sure you want to delete the entry for ${entry.date.day}/${entry.date.month}/${entry.date.year}?\n\nThis action can be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _softDeleteEntry(entry);
    }
  }

  // Add this new method
  Future<void> _deleteEntry(DateTime date) async {
    final dateKey = DateTime(date.year, date.month, date.day);
    final entry = _entriesByDate[dateKey];
    if (entry != null) {
      await _confirmDelete(entry);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon:
                Icon(_includeDeleted ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                _includeDeleted = !_includeDeleted;
              });
              _loadHistoryData();
              _selectedEntries.value = _getEntriesForDay(_selectedDay!);
            },
            tooltip: _includeDeleted ? 'Hide deleted' : 'Show deleted',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistoryData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Add a refresh button and toggle at the top
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(_includeDeleted ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _includeDeleted = !_includeDeleted;
                          });
                          _loadHistoryData();
                          _selectedEntries.value = _getEntriesForDay(_selectedDay!);
                        },
                        tooltip: _includeDeleted ? 'Hide deleted' : 'Show deleted',
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _loadHistoryData,
                        tooltip: 'Refresh',
                      ),
                    ],
                  ),
                ),
                // Calendar
                Expanded(
                  child: TableCalendar<DailyEntry>(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    eventLoader: _getEntriesForDay,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    calendarStyle: const CalendarStyle(
                      outsideDaysVisible: false,
                      weekendTextStyle: TextStyle(color: Colors.red),
                      holidayTextStyle: TextStyle(color: Colors.red),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                      formatButtonShowsNext: false,
                      formatButtonDecoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      ),
                      formatButtonTextStyle: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onDaySelected: _onDaySelected,
                    onFormatChanged: (format) {
                      if (_calendarFormat != format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      }
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                  ),
                ),
                // Selected day entries
                const SizedBox(height: 8.0),
                Expanded(
                  child: ValueListenableBuilder<List<DailyEntry>>(
                    valueListenable: _selectedEntries,
                    builder: (context, value, _) {
                      return ListView.builder(
                        itemCount: value.length,
                        itemBuilder: (context, index) {
                          return _buildEntryCard(value[index]);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            );
  }
  
  Future<void> _createNewEntry() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _createNewEntry(),
          tooltip: 'Create New Entry',
        ),
      ),
    );

    if (result == true) {
      await _loadHistoryData();
    }
  }
}
