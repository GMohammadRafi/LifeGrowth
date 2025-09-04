import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../models/daily_entry.dart';
import '../models/task_entry.dart';
import '../models/task.dart';
import '../models/task_type.dart';
import '../services/supabase_service_v2.dart';
import '../services/auth_service.dart';
import '../services/telemetry_service.dart';
import '../providers/undo_provider.dart';
import 'edit_daily_entry_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  final ValueNotifier<List<DailyEntry>> _selectedEntries = ValueNotifier([]);
  final ValueNotifier<DateTime> _selectedDay = ValueNotifier(DateTime.now());
  final ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  final ValueNotifier<bool> _includeDeleted = ValueNotifier(false);

  
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<DateTime, DailyEntry> _entriesByDate = {};
  Map<String, List<TaskEntry>> _taskEntriesByDailyEntry = {};
  List<Task> _userTasks = [];
  List<TaskType> _taskTypes = [];
  Set<String> _loadedMonths = {}; // Track which months have been loaded
  
  // Memoized widgets to prevent unnecessary rebuilds
  Widget? _cachedCalendar;
  DateTime? _lastCalendarRebuild;

  @override
  void initState() {
    super.initState();
    // Track screen view
    TelemetryService().trackScreenView('history_screen');
    _selectedDay.value = DateTime.now();
    _selectedEntries.value = _getEntriesForDay(_selectedDay.value);
    _loadHistoryData();
  }

  @override
  void dispose() {
    _selectedEntries.dispose();
    _selectedDay.dispose();
    _focusedDay.dispose();
    _isLoading.dispose();
    _includeDeleted.dispose();
    super.dispose();
  }

  Future<void> _loadHistoryData() async {
    if (!AuthService.isAuthenticated) return;

    _isLoading.value = true;

    try {
      // Load user's tasks and task types using cached methods
      final tasks = await SupabaseServiceV2.getUserTasksCached(AuthService.userId!);
      final taskTypes = await SupabaseServiceV2.getTaskTypesCached();
      
      _userTasks = tasks;
      _taskTypes = taskTypes;

      // Load data for current month and previous 2 months to show historical data by default
      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month);
      final previousMonth = DateTime(now.year, now.month - 1);
      final twoMonthsAgo = DateTime(now.year, now.month - 2);
      
      // Load multiple months in parallel for better performance
      await Future.wait([
        _loadMonthData(currentMonth),
        _loadMonthData(previousMonth),
        _loadMonthData(twoMonthsAgo),
      ]);

      _isLoading.value = false;

      // Update selected entries to show today's tasks by default
      _selectedEntries.value = _getEntriesForDay(_selectedDay.value);
    } catch (e) {
      _isLoading.value = false;
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

  Future<void> _loadMonthData(DateTime month) async {
    final startDate = DateTime(month.year, month.month, 1);
    final endDate = DateTime(month.year, month.month + 1, 0);
    
    // Check if we already have data for this month
    final monthKey = '${month.year}-${month.month}';
    if (_loadedMonths.contains(monthKey)) {
      return;
    }

    try {
      final batchData = await SupabaseServiceV2.getBatchDailyData(
        userId: AuthService.userId!,
        startDate: startDate,
        endDate: endDate,
      );

      final entriesByDate = batchData['entriesByDate'] as Map<DateTime, DailyEntry>;
      final taskEntriesByDailyEntry = batchData['taskEntriesByDailyEntry'] as Map<String, List<TaskEntry>>;

      _entriesByDate.addAll(entriesByDate);
      _taskEntriesByDailyEntry.addAll(taskEntriesByDailyEntry);
      _loadedMonths.add(monthKey);
    } catch (e) {
      // Handle error silently for now
      if (kDebugMode) {
        print('Error loading month data: $e');
      }
    }
  }

  List<DailyEntry> _getEntriesForDay(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    final entry = _entriesByDate[dateKey];
    if (entry != null) {
      // Filter based on _includeDeleted flag
      if (_includeDeleted.value || entry.deletedAt == null) {
        return [entry];
      }
    }
    return [];
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
      _selectedEntries.value = _getEntriesForDay(_selectedDay.value);

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
      _selectedEntries.value = _getEntriesForDay(_selectedDay.value);

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
    if (!isSameDay(_selectedDay.value, selectedDay)) {
      _selectedDay.value = selectedDay;
      _focusedDay.value = focusedDay;
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
        builder: (context) => EditDailyEntryScreen(
          dailyEntry: entry,
          taskEntries: taskEntries,
          userTasks: _userTasks,
          taskTypes: _taskTypes,
        ),
      ),
    );

    if (result == true) {
      await _loadHistoryData();
      _selectedEntries.value = _getEntriesForDay(_selectedDay.value);
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

  // Add this method after the _getTotalTasksCount() method
  void updateIncludeDeleted(bool includeDeleted) {
    _includeDeleted.value = includeDeleted;
    _selectedEntries.value = _getEntriesForDay(_selectedDay.value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildOptimizedCalendar(),
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<DailyEntry>>(
              valueListenable: _selectedEntries,
              builder: (context, selectedEntries, child) {
                return ValueListenableBuilder<bool>(
                  valueListenable: _isLoading,
                  builder: (context, isLoading, child) {
                    if (isLoading) {
                       return _buildSkeletonLoader();
                     }
                    
                    if (selectedEntries.isEmpty) {
                      return _buildEmptyState();
                    }
                    
                    return ListView.builder(
                      itemCount: selectedEntries.length,
                      itemBuilder: (context, index) {
                        return _buildEntryCard(selectedEntries[index]);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewEntry,
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildCalendarDay(DateTime day, bool isToday, {bool isSelected = false}) {
    
    return Container(
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: isSelected 
            ? Theme.of(context).primaryColor
            : isToday 
                ? Theme.of(context).primaryColor.withOpacity(0.3)
                : null,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: isSelected || isToday 
                ? Colors.white 
                : null,
            fontWeight: isToday ? FontWeight.bold : null,
          ),
        ),
      ),
    );
  }

  Widget _buildOptimizedCalendar() {
    // Only rebuild calendar when focused day changes significantly
    final currentMonth = DateTime(_focusedDay.value.year, _focusedDay.value.month);
    final lastRebuildMonth = _lastCalendarRebuild != null 
        ? DateTime(_lastCalendarRebuild!.year, _lastCalendarRebuild!.month)
        : null;
    
    if (_cachedCalendar == null || lastRebuildMonth != currentMonth) {
      _cachedCalendar = ValueListenableBuilder<DateTime>(
        valueListenable: _focusedDay,
        builder: (context, focusedDay, child) {
          return ValueListenableBuilder<DateTime>(
            valueListenable: _selectedDay,
            builder: (context, selectedDay, child) {
              return TableCalendar<DailyEntry>(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: focusedDay,
                    calendarFormat: _calendarFormat,
                    eventLoader: _getEntriesForDay,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    calendarStyle: const CalendarStyle(
                      outsideDaysVisible: false,
                    ),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        return _buildCalendarDay(day, false);
                      },
                      todayBuilder: (context, day, focusedDay) {
                        return _buildCalendarDay(day, true);
                      },
                      selectedBuilder: (context, day, focusedDay) {
                        return _buildCalendarDay(day, false, isSelected: true);
                      },
                    ),
                    onDaySelected: _onDaySelected,
                    onFormatChanged: (format) {
                      if (_calendarFormat != format && mounted) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      }
                    },
                    onPageChanged: (focusedDay) async {
                      _focusedDay.value = focusedDay;
                      // Load data for the new month when user navigates
                      await _loadMonthData(focusedDay);
                      _selectedEntries.value = _getEntriesForDay(_selectedDay.value);
                    },
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay.value, day);
                    },
                  );
            },
          );
        },
      );
      _lastCalendarRebuild = currentMonth;
    }
    
    return _cachedCalendar!;
  }
  
  Widget _buildSkeletonLoader() {
    return ListView.builder(
      itemCount: 3,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date skeleton
                _buildShimmerContainer(120, 16),
                const SizedBox(height: 12),
                // Task skeletons
                ...List.generate(2, (taskIndex) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      _buildShimmerContainer(20, 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildShimmerContainer(double.infinity, 14),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildShimmerContainer(double width, double height) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[300]!,
            Colors.grey[100]!,
            Colors.grey[300]!,
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<DateTime>(
            valueListenable: _selectedDay,
            builder: (context, selectedDay, child) {
              return Text(
                'No data for ${selectedDay.day}/${selectedDay.month}/${selectedDay.year}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _createNewEntryForDate(_selectedDay.value),
            icon: const Icon(Icons.add),
            label: const Text('Add Tasks for This Day'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _createNewEntry() async {
    await _createNewEntryForDate(DateTime.now());
  }

  Future<void> _createNewEntryForDate(DateTime date) async {
    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 16),
                Text('Creating entry...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Create a new daily entry for the specified date
      final newEntry = await SupabaseServiceV2.createOrUpdateDailyEntry(
        date: date,
        notes: '',
      );

      // Create default task entries for all user tasks
      for (final task in _userTasks) {
        await SupabaseServiceV2.createOrUpdateTaskEntry(
          dailyEntryId: newEntry.id,
          taskId: task.id,
          data: {},
          completed: false,
        );
      }

      // Reload the month data to include the new entry
      final monthKey = '${date.year}-${date.month}';
      _loadedMonths.remove(monthKey); // Force reload of this month
      await _loadMonthData(date);
      
      // Update selected entries if this is the selected day
      if (_selectedDay.value.year == date.year &&
          _selectedDay.value.month == date.month &&
          _selectedDay.value.day == date.day) {
        _selectedEntries.value = _getEntriesForDay(_selectedDay.value);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Entry created for ${date.day}/${date.month}/${date.year}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create entry: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
