import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';
import '../services/supabase_service_v2.dart';
import '../services/background_sync_manager.dart';
import '../services/personalization_service.dart';
import '../services/telemetry_service.dart';
import '../services/notification_service.dart';
import '../models/daily_entry.dart';
import '../models/daily_entry_extensions.dart';
import '../models/task_entry.dart';
import '../models/task.dart';
import '../models/task_type.dart';
import '../models/personalization_settings.dart';
import '../providers/undo_provider.dart';
import 'auth_screen.dart';
import 'daily_checkin_screen.dart';
import 'history_screen.dart';
import 'analytics_screen.dart';
import 'personalization_screen.dart';
import 'accessibility_settings_screen.dart';
import 'task_reminder_screen.dart';
import 'csv_export_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DailyEntry? _todayEntry;
  List<TaskEntry> _todayTaskEntries = [];
  List<Task> _userTasks = [];
  List<TaskType> _taskTypes = [];
  bool _isLoading = true;
  PersonalizationService? _personalizationService;
  PersonalizationSettings? _personalizationSettings;
  bool _isSyncing = false;
  bool _isUndoing = false;
  String? _errorMessage;
  String? _syncStatus;

  // Add the missing _todayTask getter
  DailyEntry? get _todayTask => _todayEntry;

  // Count of completed tasks for today
  int get _completedTasksCount {
    return _todayTaskEntries.where((entry) => entry.completed).length;
  }

  @override
  void initState() {
    super.initState();
    // Track screen view
    TelemetryService().trackScreenView('home_screen');
    _initializePersonalization();
    _loadTodayData();
  }

  Future<void> _initializePersonalization() async {
    try {
      _personalizationService = await PersonalizationService.getInstance();
      _personalizationSettings = await _personalizationService!.loadSettings();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error initializing personalization: $e');
    }
  }

  Future<void> _loadTodayData() async {
    if (!AuthService.isAuthenticated) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User not authenticated';
        });
      }
      return;
    }

    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }

      final today = DateTime.now();
      final userId = AuthService.userId!;

      // Load today's data using enhanced method that ensures default tasks exist
      final dailyData = await SupabaseServiceV2.getDailyDataWithDefaults(
        userId: userId,
        date: today,
      );

      // If no daily entry exists, create one automatically
      DailyEntry? todayEntry = dailyData['dailyEntry'] as DailyEntry?;
      if (todayEntry == null) {
        todayEntry = await SupabaseServiceV2.createOrUpdateDailyEntry(
          date: today,
        );
      }

      if (mounted) {
        setState(() {
          _todayEntry = todayEntry;
          _todayTaskEntries = dailyData['taskEntries'] as List<TaskEntry>;
          _userTasks = dailyData['tasks'] as List<Task>;
          _taskTypes = dailyData['taskTypes'] as List<TaskType>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load today\'s data: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateTaskEntry(TaskEntry updatedEntry) async {
    if (!AuthService.isAuthenticated) return;

    try {
      // Create daily entry if it doesn't exist
      if (_todayEntry == null) {
        _todayEntry = await SupabaseServiceV2.createOrUpdateDailyEntry(
          date: DateTime.now(),
        );
      }

      // Update the task entry
      final savedEntry = await SupabaseServiceV2.createOrUpdateTaskEntry(
        dailyEntryId: _todayEntry!.id,
        taskId: updatedEntry.taskId,
        data: updatedEntry.data,
        completed: updatedEntry.completed,
      );

      if (mounted) {
        setState(() {
          final index = _todayTaskEntries.indexWhere((e) => e.taskId == savedEntry.taskId);
          if (index >= 0) {
            _todayTaskEntries[index] = savedEntry;
          } else {
            _todayTaskEntries.add(savedEntry);
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task updated successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _syncData() async {
    if (!AuthService.isAuthenticated) return;

    if (mounted) {
      setState(() {
        _isSyncing = true;
        _syncStatus = 'Syncing...';
      });
    }

    try {
      // Use background sync manager for immediate sync
      await BackgroundSyncManager().scheduleImmediateSync();

      // Also perform direct sync for immediate feedback
      await SupabaseServiceV2.syncAllPendingChanges(AuthService.userId!);
      await _loadTodayTask(); // Reload to get any updates

      if (mounted) {
        setState(() {
          _syncStatus = 'Sync completed successfully';
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data synced successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _syncStatus = 'Sync failed: $e';
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }

      // Clear sync status after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _syncStatus = null;
          });
        }
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await AuthService.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sign out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Add the missing _loadTodayTask method
  Future<void> _loadTodayTask() async {
    await _loadTodayData();
  }

  // Add the missing _updateTask method
  Future<void> _updateTask(DailyEntry updatedEntry) async {
    try {
      setState(() {
        _todayEntry = updatedEntry;
      });

      // Save to database
      await SupabaseServiceV2.createOrUpdateDailyEntry(
        date: updatedEntry.date,
        notes: updatedEntry.notes,
        timezoneOffset: updatedEntry.timezoneOffset,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to update task: $e';
        });
      }
    }
  }

  Future<void> _performDirectSync() async {
    if (_isSyncing) return;

    setState(() {
      _isSyncing = true;
      _syncStatus = 'Syncing...';
    });

    try {
      await TelemetryService().trackSyncStart();
      await NotificationService().showSyncStartToast();

      await SupabaseService.syncAllPendingChanges(AuthService.userId!);
      await _loadTodayTask(); // Reload to get any updates

      // Track sync success
      await TelemetryService().trackSyncFinish(success: true);
      await NotificationService().showSyncSuccessToast();

      if (kDebugMode) {
        print('Direct sync completed successfully');
      }
    } catch (e) {
      // Handle sync error
      await TelemetryService().trackSyncFinish(success: false, errorMessage: e.toString());
      await NotificationService().showSyncErrorToast(e.toString());

      if (mounted) {
        setState(() {
          _errorMessage = 'Sync failed: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
          _syncStatus = null;
        });
      }
    }
  }

  Widget _buildTaskTile({
    required String title,
    required bool completed,
    required VoidCallback onToggle,
    String? subtitle,
    Widget? trailing,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Semantics(
        label: '$title task',
        hint: completed ? 'Task completed. Tap to mark as incomplete' : 'Task not completed. Tap to mark as complete',
        button: true,
        checked: completed,
        child: ListTile(
          leading: Semantics(
            label: 'Task completion checkbox',
            hint: completed ? 'Mark task as incomplete' : 'Mark task as complete',
            checked: completed,
            child: Checkbox(
              value: completed,
              onChanged: (_) => onToggle(),
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              decoration: completed ? TextDecoration.lineThrough : null,
              color: completed ? Colors.grey : null,
            ),
          ),
          subtitle: subtitle != null ? Text(subtitle) : null,
          trailing: trailing,
          onTap: onToggle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Life Growth'),
            if (_syncStatus != null)
              Text(
                _syncStatus!,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        actions: [
          Consumer<UndoProvider>(
            builder: (context, undoProvider, child) {
              return Semantics(
                label: 'Undo',
                hint: _isUndoing
                    ? 'Undoing action, please wait'
                    : undoProvider.canUndo 
                        ? 'Undo last action: ${undoProvider.getUndoDescription()}'
                        : 'No actions to undo',
                button: true,
                child: IconButton(
                  icon: _isUndoing 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.undo),
                  onPressed: (undoProvider.canUndo && !_isUndoing) ? () async {
                    setState(() {
                      _isUndoing = true;
                    });
                    
                    try {
                      final success = await undoProvider.undoLastAction();
                      if (success) {
                        // Add a small delay to ensure database write is fully committed
                        await Future.delayed(const Duration(milliseconds: 200));
                        await _loadTodayTask();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Action undone')),
                          );
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to undo action'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isUndoing = false;
                        });
                      }
                    }
                  } : null,
                  tooltip: _isUndoing
                      ? 'Undoing action...'
                      : undoProvider.canUndo 
                          ? 'Undo: ${undoProvider.getUndoDescription()}'
                          : 'No actions to undo',
                ),
              );
            },
          ),
          Semantics(
            label: 'Refresh',
            hint: 'Refresh today\'s task data',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadTodayTask,
              tooltip: 'Refresh',
            ),
          ),
          Semantics(
            label: 'Sync Data',
            hint: _isSyncing ? 'Syncing data with server' : 'Sync your data with the server',
            button: true,
            child: IconButton(
              icon: _isSyncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.sync),
              onPressed: _isSyncing ? null : _syncData,
              tooltip: 'Sync Data',
            ),
          ),
          Semantics(
            label: 'Menu',
            hint: 'Open menu with options for history, analytics, settings, and sign out',
            button: true,
            child: PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'history') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const HistoryScreen(),
                  ),
                );
              } else if (value == 'analytics') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AnalyticsScreen(),
                  ),
                );
              } else if (value == 'personalization') {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PersonalizationScreen(),
                  ),
                );
                if (result == true) {
                  await _initializePersonalization();
                }
              } else if (value == 'accessibility') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AccessibilitySettingsScreen(),
                  ),
                );
              } else if (value == 'reminders') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const TaskReminderScreen(),
                  ),
                );
              } else if (value == 'export') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CsvExportScreen(),
                  ),
                );
              } else if (value == 'signout') {
                _signOut();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'history',
                child: Semantics(
                  label: 'History',
                  hint: 'View your task history',
                  button: true,
                  child: const Row(
                    children: [
                      Icon(Icons.history),
                      SizedBox(width: 8),
                      Text('History'),
                    ],
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'analytics',
                child: Semantics(
                  label: 'Analytics',
                  hint: 'View your task analytics and statistics',
                  button: true,
                  child: const Row(
                    children: [
                      Icon(Icons.analytics),
                      SizedBox(width: 8),
                      Text('Analytics'),
                    ],
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'personalization',
                child: Semantics(
                  label: 'Personalization',
                  hint: 'Customize your task preferences and settings',
                  button: true,
                  child: const Row(
                    children: [
                      Icon(Icons.tune),
                      SizedBox(width: 8),
                      Text('Personalization'),
                    ],
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'accessibility',
                child: Semantics(
                  label: 'Accessibility',
                  hint: 'Configure accessibility settings and theme preferences',
                  button: true,
                  child: const Row(
                    children: [
                      Icon(Icons.accessibility),
                      SizedBox(width: 8),
                      Text('Accessibility'),
                    ],
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'reminders',
                child: Semantics(
                  label: 'Task Reminders',
                  hint: 'Manage reminders for your tasks',
                  button: true,
                  child: const Row(
                    children: [
                      Icon(Icons.notifications),
                      SizedBox(width: 8),
                      Text('Task Reminders'),
                    ],
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'export',
                child: Semantics(
                  label: 'Export Data',
                  hint: 'Export your data to CSV files',
                  button: true,
                  child: const Row(
                    children: [
                      Icon(Icons.file_download),
                      SizedBox(width: 8),
                      Text('Export Data'),
                    ],
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'signout',
                child: Semantics(
                  label: 'Sign Out',
                  hint: 'Sign out from your account: ${AuthService.userEmail ?? 'Unknown'}',
                  button: true,
                  child: Row(
                    children: [
                      const Icon(Icons.logout),
                      const SizedBox(width: 8),
                      Text('Sign Out'),
                    ],
                  ),
                ),
              ),
            ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.withOpacity(0.7),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadTodayTask,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadTodayTask,
                  child: ListView(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Today - ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Completed: $_completedTasksCount tasks',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  ),
                            ),
                          ],
                        ),
                      ),

                      // Incomplete Tasks Section
                      if (_getIncompleteTaskWidgets().isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            'Today\'s Tasks',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        ..._getIncompleteTaskWidgets(),
                      ],
                      
                      // Completed Tasks Section
                      if (_getCompletedTaskWidgets().isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Completed Tasks',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ..._getCompletedTaskWidgets(),
                      ],

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
      floatingActionButton: _todayTask == null
          ? null
          : Semantics(
              label: 'Daily Check-in',
              hint: 'Open daily check-in form to track your tasks',
              button: true,
              child: FloatingActionButton.extended(
                onPressed: () async {
                  if (!AuthService.isAuthenticated) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DailyCheckinScreen(
                        existingEntry: _todayTask,
                        existingTaskEntries: _todayTaskEntries,
                        date: DateTime.now(),
                      ),
                    ),
                  ).then((_) {
                    _loadTodayTask();
                  });
                },
                icon: const Icon(Icons.edit),
                label: const Text('Daily Check-in'),
              ),
            ),
    );
  }

  List<Widget> _getIncompleteTaskWidgets() {
    final List<Widget> incompleteWidgets = [];
    
    for (final task in _userTasks) {
      final taskEntry = _todayTaskEntries.firstWhere(
        (entry) => entry.taskId == task.id,
        orElse: () => TaskEntry(
          id: '',
          dailyEntryId: _todayEntry?.id ?? '',
          taskId: task.id,
          data: {},
          completed: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      
      if (!taskEntry.completed) {
        final widget = _buildDynamicTaskTile(task, taskEntry);
        if (widget != null) {
          incompleteWidgets.add(widget);
        }
      }
    }
    
    return incompleteWidgets;
  }

  List<Widget> _getCompletedTaskWidgets() {
    final List<Widget> completedWidgets = [];
    
    for (final task in _userTasks) {
      final taskEntry = _todayTaskEntries.firstWhere(
        (entry) => entry.taskId == task.id,
        orElse: () => TaskEntry(
          id: '',
          dailyEntryId: _todayEntry?.id ?? '',
          taskId: task.id,
          data: {},
          completed: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      
      if (taskEntry.completed) {
        final widget = _buildDynamicTaskTile(task, taskEntry);
        if (widget != null) {
          completedWidgets.add(widget);
        }
      }
    }
    
    return completedWidgets;
  }

  Widget? _buildDynamicTaskTile(Task task, TaskEntry taskEntry) {
    final taskType = _taskTypes.firstWhere(
      (type) => type.id == task.taskTypeId,
      orElse: () => TaskType(
        id: '',
        name: 'unknown',
        description: '',
        schemaDefinition: {},
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    
    String subtitle = '';
    
    // Build subtitle based on task type and data
    switch (taskType.name) {
      case 'reading_book':
        final pages = taskEntry.getIntValue('pages') ?? 0;
        final time = taskEntry.getIntValue('time') ?? 0;
        if (pages > 0 || time > 0) {
          subtitle = '$pages pages, $time min';
        }
        break;
      case 'stretch_exercise':
        final minutes = taskEntry.getIntValue('minutes') ?? 0;
        final type = taskEntry.getStringValue('type') ?? 'Not specified';
        subtitle = '$type${minutes > 0 ? ', $minutes minutes' : ''}';
        break;
      case 'meditation':
        final minutes = taskEntry.getIntValue('minutes') ?? 0;
        if (minutes > 0) {
          subtitle = '$minutes minutes';
        }
        break;
      case 'reading_docs':
        final pages = taskEntry.getIntValue('pages') ?? 0;
        final time = taskEntry.getIntValue('time') ?? 0;
        if (pages > 0 || time > 0) {
          subtitle = '$pages pages, $time min';
        }
        break;
      case 'learning_tech':
        final name = taskEntry.getStringValue('name') ?? 'Not specified';
        final time = taskEntry.getIntValue('time') ?? 0;
        subtitle = '$name${time > 0 ? ', $time min' : ''}';
        break;
      case 'walking':
        final steps = taskEntry.getIntValue('steps') ?? 0;
        final time = taskEntry.getIntValue('time') ?? 0;
        if (steps > 0 || time > 0) {
          subtitle = '$steps steps, $time min';
        }
        break;
      case 'entertainment':
        final name = taskEntry.getStringValue('name') ?? 'Not specified';
        final duration = taskEntry.getIntValue('duration') ?? 0;
        subtitle = '$name${duration > 0 ? ', $duration min' : ''}';
        break;
      case 'habit':
        final notes = taskEntry.getStringValue('notes');
        if (notes != null && notes.isNotEmpty) {
          subtitle = notes;
        }
        break;
    }
    
    return _buildTaskTile(
      title: task.name,
      completed: taskEntry.completed,
      subtitle: subtitle.isNotEmpty ? subtitle : null,
      onToggle: () => _updateTaskEntry(taskEntry.copyWith(
        completed: !taskEntry.completed,
      )),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
