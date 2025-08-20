import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../models/daily_task.dart' as model;
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/supabase_service.dart';
import '../services/telemetry_service.dart';
import '../providers/undo_provider.dart';
import 'daily_checkin_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final ValueNotifier<List<model.DailyTask>> _selectedTasks;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<model.DailyTask>> _tasksByDate = {};
  bool _isLoading = true;
  bool _includeDeleted = false;

  @override
  void initState() {
    super.initState();
    // Track screen view
    TelemetryService().trackScreenView('history_screen');
    _selectedDay = DateTime.now();
    _selectedTasks = ValueNotifier(_getTasksForDayCalendar(_selectedDay!));
    _loadHistoryData();
  }

  @override
  void dispose() {
    _selectedTasks.dispose();
    super.dispose();
  }

  Future<void> _loadHistoryData() async {
    if (!AuthService.isAuthenticated) return;

    setState(() => _isLoading = true);

    try {
      final tasks = await DatabaseService.instance.getAllDailyTasksForUser(
        AuthService.userId!,
        includeDeleted: _includeDeleted,
      );

      // Group tasks by date
      final Map<DateTime, List<model.DailyTask>> tasksByDate = {};
      for (final task in tasks) {
        final dateKey =
            DateTime(task.date.year, task.date.month, task.date.day);
        if (tasksByDate[dateKey] == null) {
          tasksByDate[dateKey] = [];
        }
        tasksByDate[dateKey]!.add(task);
      }

      setState(() {
        _tasksByDate = tasksByDate;
        _isLoading = false;
      });

      // Update selected tasks
      _selectedTasks.value = _getTasksForDayCalendar(_selectedDay!);
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

  List<model.DailyTask> _getTasksForDay(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    return _tasksByDate[dateKey] ?? [];
  }

  List<model.DailyTask> _getTasksForDayCalendar(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    final tasks = _tasksByDate[dateKey] ?? [];
    
    // Filter deleted tasks based on _includeDeleted setting
    if (_includeDeleted) {
      return tasks; // Show all tasks including deleted ones
    } else {
      return tasks.where((task) => task.deletedAt == null).toList(); // Only show non-deleted tasks
    }
  }

  int _getCompletedTasksCount(model.DailyTask task) {
    int count = 0;
    if (task.readingBookCompleted) count++;
    if (task.stretchCompleted) count++;
    if (task.meditationCompleted) count++;
    if (task.readingDocsCompleted) count++;
    if (task.learningTechCompleted) count++;
    if (task.walkingCompleted) count++;
    if (task.avoidHabitValue) count++;
    if (task.avoidSweetsValue) count++;
    if (task.workDoneValue) count++;
    if (task.movieSeriesCompleted) count++;
    return count;
  }

  Future<void> _softDeleteTask(model.DailyTask task) async {
    try {
      // Record the delete action before actually deleting
      final undoProvider = Provider.of<UndoProvider>(context, listen: false);
      undoProvider.recordDelete(task);
      
      // Use SupabaseService for proper sync to Supabase
      await SupabaseService.softDeleteDailyTask(
        userId: AuthService.userId!,
        date: task.date,
      );

      // Update UI immediately
      await _loadHistoryData();
      _selectedTasks.value = _getTasksForDayCalendar(_selectedDay!);

      if (mounted) {
        // Clear any existing snackbars first
        ScaffoldMessenger.of(context).clearSnackBars();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Task deleted'),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () async {
                // Clear the current snackbar
                ScaffoldMessenger.of(context).clearSnackBars();
                
                final success = await undoProvider.undoLastAction();
                if (success) {
                  await _loadHistoryData();
                  _selectedTasks.value = _getTasksForDayCalendar(_selectedDay!);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Task restored'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to undo action'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      // Reload data to ensure UI is consistent
      await _loadHistoryData();
      _selectedTasks.value = _getTasksForDayCalendar(_selectedDay!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete task: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _restoreTask(model.DailyTask task) async {
    try {
      // Use SupabaseService for proper sync to Supabase
      await SupabaseService.restoreDailyTask(
        userId: AuthService.userId!,
        date: task.date,
      );

      // Update UI immediately
      await _loadHistoryData();
      _selectedTasks.value = _getTasksForDayCalendar(_selectedDay!);

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task restored'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to restore task: $e'),
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
      _selectedTasks.value = _getTasksForDayCalendar(selectedDay);
    }
  }

  Widget _buildTaskCard(model.DailyTask task) {
    final isDeleted = task.deletedAt != null;

    return Opacity(
      opacity: isDeleted ? 0.6 : 1.0,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: isDeleted
                ? Colors.grey
                : (_getCompletedTasksCount(task) > 5
                    ? Colors.green
                    : _getCompletedTasksCount(task) > 2
                        ? Colors.orange
                        : Colors.red),
            child: isDeleted
                ? const Icon(
                    Icons.visibility_off,
                    color: Colors.white,
                    size: 18,
                  )
                : Text(
                    '${_getCompletedTasksCount(task)}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
          ),
          title: Text(
            '${task.date.day}/${task.date.month}/${task.date.year}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              decoration: isDeleted ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Completed: ${_getCompletedTasksCount(task)}/10 tasks'),
              if (task.notes != null && task.notes!.isNotEmpty)
                Text(
                  task.notes!,
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
              
              if (!isDeleted)...[
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: isDeleted ? null : () => _editTask(task),
                tooltip: 'Edit',
              ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _confirmDelete(task),
                  tooltip: 'Delete',
                )]
              else
                IconButton(
                  icon: const Icon(Icons.restore_rounded),
                  onPressed: () => _restoreTask(task),
                  tooltip: 'Restore',
                ),
            ],
          ),
          onTap: isDeleted ? null : () => _editTask(task),
        ),
      ),
    );
  }

  Future<void> _editTask(model.DailyTask task) async {
    // Task is already a model DailyTask
    final modelTask = task;
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => DailyCheckinScreen(
          existingTask: modelTask,
          date: task.date,
        ),
      ),
    );

    if (result == true) {
      await _loadHistoryData();
    }
  }

  Future<void> _confirmDelete(model.DailyTask task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text(
          'Are you sure you want to delete the task for ${task.date.day}/${task.date.month}/${task.date.year}?\n\nThis action can be undone.',
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
      await _softDeleteTask(task);
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
              _selectedTasks.value = _getTasksForDayCalendar(_selectedDay!);
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
                // Calendar
                TableCalendar<model.DailyTask>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  eventLoader: _getTasksForDayCalendar,
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
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, tasks) {
                      if (tasks.isNotEmpty) {
                        final task = tasks.first;
                        final hasDeleted = tasks.any((t) => t.deletedAt != null);
                        return Positioned(
                          bottom: 1,
                          right: 1,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: hasDeleted
                                  ? Colors.grey
                                  : (_getCompletedTasksCount(task) > 5
                                      ? Colors.green
                                      : _getCompletedTasksCount(task) > 2
                                          ? Colors.orange
                                          : Colors.red),
                              border: Border.all(
                                color: Colors.white,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: hasDeleted
                                  ? const Icon(
                                      Icons.visibility_off,
                                      color: Colors.white,
                                      size: 10,
                                    )
                                  : Text(
                                      '${_getCompletedTasksCount(task)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                ),
                const Divider(),
                // Selected day tasks
                Expanded(
                  child: ValueListenableBuilder<List<model.DailyTask>>(
                    valueListenable: _selectedTasks,
                    builder: (context, tasks, _) {
                      if (tasks.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_note,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No tasks for ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () => _editTask(
                                  model.DailyTask(
                                    userId: AuthService.userId!,
                                    date: _selectedDay!,
                                    readingBookCompleted: false,
                                    stretchCompleted: false,
                                    meditationCompleted: false,
                                    readingDocsCompleted: false,
                                    learningTechCompleted: false,
                                    walkingCompleted: false,
                                    avoidHabitValue: false,
                                    avoidSweetsValue: false,
                                    workDoneValue: false,
                                    movieSeriesCompleted: false,
                                    createdAt: DateTime.now(),
                                    updatedAt: DateTime.now(),
                                    timezoneOffset:
                                        DateTime.now().timeZoneOffset.inMinutes,
                                  ),
                                ),
                                icon: const Icon(Icons.add),
                                label: const Text('Create Task'),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          return _buildTaskCard(tasks[index]);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
