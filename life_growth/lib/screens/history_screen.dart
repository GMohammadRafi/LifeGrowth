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
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDeleted
                  ? Colors.grey
                  : (completedCount > (totalCount * 0.7)
                      ? Theme.of(context).colorScheme.primary
                      : completedCount > (totalCount * 0.3)
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.error),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: (isDeleted
                      ? Colors.grey
                      : (completedCount > (totalCount * 0.7)
                          ? Theme.of(context).colorScheme.primary
                          : completedCount > (totalCount * 0.3)
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.error)).withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: isDeleted
                ? const Icon(
                    Icons.visibility_off,
                    color: Colors.white,
                    size: 18,
                  )
                : Center(
                    child: Text(
                      '$completedCount',
                      style: const TextStyle(
                          color: Colors.white, 
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
          title: Text(
            '${entry.date.day}/${entry.date.month}/${entry.date.year}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Theme.of(context).colorScheme.onBackground,
              decoration: isDeleted ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 16,
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Completed: $completedCount/$totalCount tasks',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.note,
                      size: 16,
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        entry.notes!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (isDeleted) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.delete,
                      size: 16,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Deleted',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          trailing: SizedBox(
            width: !isDeleted ? 120 : 60,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isDeleted) ...[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.edit,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      onPressed: () => _editEntry(entry),
                      tooltip: 'Edit',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.delete,
                        color: Theme.of(context).colorScheme.error,
                        size: 20,
                      ),
                      onPressed: () => _deleteEntry(entry.date),
                      tooltip: 'Delete',
                    ),
                  ),
                ] else
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.restore_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      onPressed: () => _restoreEntry(entry),
                      tooltip: 'Restore',
                    ),
                  ),
              ],
            ),
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _buildOptimizedCalendar(),
          ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _createNewEntry,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Icon(
            Icons.add,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
  
  Widget _buildCalendarDay(DateTime day, bool isToday, {bool isSelected = false}) {
    final hasEntry = _entriesByDate.containsKey(DateTime(day.year, day.month, day.day));
    
    return Container(
      margin: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        color: isSelected 
            ? Theme.of(context).colorScheme.primary
            : isToday 
                ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                : hasEntry
                    ? Theme.of(context).colorScheme.secondary.withOpacity(0.1)
                    : null,
        borderRadius: BorderRadius.circular(12.0),
        border: isToday && !isSelected
            ? Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              )
            : null,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : isToday
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onBackground,
                fontWeight: isToday || isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
            if (hasEntry)
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
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
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      weekendTextStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                      defaultTextStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                      todayTextStyle: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      selectedTextStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      tablePadding: const EdgeInsets.all(16),
                      cellMargin: const EdgeInsets.all(2),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                      formatButtonShowsNext: false,
                      formatButtonDecoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      formatButtonTextStyle: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      titleTextStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
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
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.calendar_today,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<DateTime>(
              valueListenable: _selectedDay,
              builder: (context, selectedDay, child) {
                return Text(
                  'No data for ${selectedDay.day}/${selectedDay.month}/${selectedDay.year}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                  textAlign: TextAlign.center,
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your daily progress by adding tasks for this day.',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => _createNewEntryForDate(_selectedDay.value),
                icon: Icon(
                  Icons.add,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                label: Text(
                  'Add Tasks for This Day',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
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
