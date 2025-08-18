import 'package:flutter/material.dart';
import '../models/personalization_settings.dart';
import '../services/personalization_service.dart';
import '../services/notification_service.dart';

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
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: 'Save Settings',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'reset') {
                _resetToDefaults();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reset',
                child: Text('Reset to Defaults'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Order Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Task Order',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Drag and drop to reorder tasks',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _settings!.taskOrder.length,
                      onReorder: _reorderTasks,
                      itemBuilder: (context, index) {
                        final taskId = _settings!.taskOrder[index];
                        final isHidden = _settings!.hiddenTasks.contains(taskId);
                        final isAvoidSweetsHidden = taskId == 'avoidSweets' && !_settings!.showAvoidSweets;
                        
                        return Card(
                          key: ValueKey(taskId),
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          child: ListTile(
                            leading: const Icon(Icons.drag_handle),
                            title: Text(
                              _getTaskDisplayName(taskId),
                              style: TextStyle(
                                decoration: (isHidden || isAvoidSweetsHidden) 
                                    ? TextDecoration.lineThrough 
                                    : null,
                                color: (isHidden || isAvoidSweetsHidden) 
                                    ? Colors.grey 
                                    : null,
                              ),
                            ),
                            trailing: taskId != 'avoidSweets' 
                                ? IconButton(
                                    icon: Icon(
                                      isHidden ? Icons.visibility_off : Icons.visibility,
                                      color: isHidden ? Colors.grey : Colors.green,
                                    ),
                                    onPressed: () => _toggleTaskVisibility(taskId),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Avoid Habit Label Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Avoid Habit Label',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Customize the label for your avoid habit task',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _avoidHabitLabelController,
                      decoration: const InputDecoration(
                        labelText: 'Avoid Habit Label',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., Avoid Smoking, Avoid Social Media',
                      ),
                      onChanged: _updateAvoidHabitLabel,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Avoid Sweets Toggle Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Avoid Sweets Task',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Show or hide the Avoid Sweets task',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Show Avoid Sweets Task'),
                      subtitle: Text(
                        _settings!.showAvoidSweets 
                            ? 'Avoid Sweets task is visible'
                            : 'Avoid Sweets task is hidden',
                      ),
                      value: _settings!.showAvoidSweets,
                      onChanged: (_) => _toggleAvoidSweets(),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Reminder Settings Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reminder Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Configure daily reminders for your check-ins',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Daily Reminder'),
                      subtitle: Text(
                        _dailyReminderEnabled
                            ? 'Reminder enabled at ${_dailyReminderTime.format(context)}'
                            : 'No daily reminder set',
                      ),
                      value: _dailyReminderEnabled,
                      onChanged: _toggleDailyReminder,
                    ),
                    if (_dailyReminderEnabled) ...[                      
                      const SizedBox(height: 8),
                      ListTile(
                        leading: const Icon(Icons.access_time),
                        title: const Text('Reminder Time'),
                        subtitle: Text(_dailyReminderTime.format(context)),
                        trailing: const Icon(Icons.edit),
                        onTap: _selectDailyReminderTime,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}