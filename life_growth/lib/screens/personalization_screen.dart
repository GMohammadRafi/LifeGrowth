import 'package:flutter/material.dart';
import '../models/personalization_settings.dart';
import '../services/personalization_service.dart';
import '../services/notification_service.dart';
import '../services/telemetry_service.dart';
import '../services/auth_service.dart';
import '../services/supabase_service_v2.dart';
import '../models/task.dart';
import '../models/task_type.dart';
import '../widgets/create_task_dialog.dart';

class PersonalizationScreen extends StatefulWidget {
  const PersonalizationScreen({super.key});

  @override
  State<PersonalizationScreen> createState() => _PersonalizationScreenState();
}

class _PersonalizationScreenState extends State<PersonalizationScreen> {
  late PersonalizationService _personalizationService;
  late NotificationService _notificationService;
  PersonalizationSettings? _settings;
  bool _isLoading = true;
  bool _dailyReminderEnabled = false;
  TimeOfDay _dailyReminderTime = const TimeOfDay(hour: 20, minute: 0);
  final _avoidHabitLabelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Track screen view
    TelemetryService().trackScreenView('personalization_screen');
    _initializeService();
  }

  Future<void> _initializeService() async {
    _personalizationService = await PersonalizationService.getInstance();
    _notificationService = NotificationService();
    await _loadSettings();
    await _loadReminderSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _personalizationService.loadSettings();
    setState(() {
      _settings = settings;
      _avoidHabitLabelController.text = settings.avoidHabitLabel;
    });
  }

  Future<void> _loadReminderSettings() async {
    final enabled = await _notificationService.isDailyReminderEnabled();
    final time = await _notificationService.getDailyReminderTime();
    setState(() {
      _dailyReminderEnabled = enabled;
      _dailyReminderTime = time;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    if (_settings != null) {
      final success = await _personalizationService.saveSettings(_settings!);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully!')),
        );
      }
    }
  }

  Future<void> _resetToDefaults() async {
    final success = await _personalizationService.resetToDefaults();
    if (success) {
      await _loadSettings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings reset to defaults!')),
        );
      }
    }
  }

  void _reorderTasks(int oldIndex, int newIndex) {
    if (_settings == null) return;
    
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final List<String> newOrder = List.from(_settings!.taskOrder);
      final String item = newOrder.removeAt(oldIndex);
      newOrder.insert(newIndex, item);
      _settings = _settings!.copyWith(taskOrder: newOrder);
    });
  }

  void _toggleTaskVisibility(String taskId) {
    if (_settings == null) return;
    
    setState(() {
      final Set<String> newHiddenTasks = Set.from(_settings!.hiddenTasks);
      if (newHiddenTasks.contains(taskId)) {
        newHiddenTasks.remove(taskId);
      } else {
        newHiddenTasks.add(taskId);
      }
      _settings = _settings!.copyWith(hiddenTasks: newHiddenTasks);
    });
  }

  void _updateAvoidHabitLabel(String newLabel) {
    if (_settings == null) return;
    
    setState(() {
      _settings = _settings!.copyWith(avoidHabitLabel: newLabel);
    });
  }

  void _toggleAvoidSweets() {
    if (_settings == null) return;
    
    setState(() {
      _settings = _settings!.copyWith(showAvoidSweets: !_settings!.showAvoidSweets);
    });
  }

  Future<void> _toggleDailyReminder(bool enabled) async {
    setState(() {
      _dailyReminderEnabled = enabled;
    });
    
    if (enabled) {
      // Check and request permissions first
      final hasPermission = await _notificationService.requestPermissions();
      final notificationsEnabled = await _notificationService.areNotificationsEnabled();
      
      if (!hasPermission || !notificationsEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                !hasPermission 
                    ? 'Notification permission is required for reminders. Please enable in app settings.'
                    : 'Notifications are disabled. Please enable in device settings.',
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () {
                  // This would ideally open app settings, but that requires additional packages
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enable notifications in your device settings > Apps > Life Growth > Notifications'),
                      duration: Duration(seconds: 8),
                    ),
                  );
                },
              ),
            ),
          );
        }
        // Still set the reminder even if permissions are not granted
        // The user might grant them later
      }
    }
    
    await _notificationService.setDailyReminder(
      enabled: enabled,
      time: _dailyReminderTime,
    );
    
    if (enabled && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Daily reminder set for ${_dailyReminderTime.format(context)}. Check debug logs for scheduling details.',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _selectDailyReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _dailyReminderTime,
    );
    
    if (picked != null && picked != _dailyReminderTime) {
      setState(() {
        _dailyReminderTime = picked;
      });
      
      // Update the reminder if it's enabled
      if (_dailyReminderEnabled) {
        await _notificationService.setDailyReminder(
          enabled: true,
          time: picked,
        );
      }
    }
  }

  String _getTaskDisplayName(String taskId) {
    switch (taskId) {
      case 'readingBook':
        return 'Reading Book';
      case 'stretch':
        return 'Stretch';
      case 'meditation':
        return 'Meditation';
      case 'readingDocs':
        return 'Reading Docs';
      case 'learningTech':
        return 'Learning Technology';
      case 'walking':
        return 'Walking';
      case 'avoidHabit':
        return _settings?.avoidHabitLabel ?? 'Avoid X';
      case 'avoidSweets':
        return 'Avoid Sweets';
      case 'workDone':
        return 'Work Done';
      case 'movieSeries':
        return 'Movie/Series';
      default:
        return taskId;
    }
  }

  @override
  void dispose() {
    _avoidHabitLabelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Personalization'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_settings == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Personalization'),
        ),
        body: const Center(
          child: Text('Failed to load settings'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalization'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add after existing sections in build method
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Tasks',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create and manage your personal tasks',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    // List existing user tasks
                    FutureBuilder<List<Task>>(
                      future: _loadUserTasks(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        
                        final tasks = snapshot.data ?? [];
                        
                        return Column(
                          children: [
                            ...tasks.map((task) => ListTile(
                              title: Text(task.name),
                              subtitle: Text(task.description ?? ''),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteTask(task.id),
                              ),
                            )),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _showCreateTaskDialog,
                              icon: const Icon(Icons.add),
                              label: const Text('Create New Task'),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Move these functions inside the class
  Future<List<Task>> _loadUserTasks() async {
    if (!AuthService.isAuthenticated) return [];
    return await SupabaseServiceV2.getUserTasks(AuthService.userId!);
  }

  Future<void> _showCreateTaskDialog() async {
    final taskTypes = await SupabaseServiceV2.getTaskTypes();
    
    showDialog(
      context: context,
      builder: (context) => CreateTaskDialog(
        taskTypes: taskTypes,
        onTaskCreated: () {
          setState(() {}); // Refresh the task list
        },
      ),
    );
  }

  Future<void> _deleteTask(String taskId) async {
    await SupabaseServiceV2.deleteTask(taskId);
    setState(() {}); // Refresh the task list
  }
}