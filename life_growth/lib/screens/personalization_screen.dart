import 'package:flutter/material.dart';
import '../models/personalization_settings.dart';
import '../services/personalization_service.dart';
import '../services/notification_service.dart';
import '../services/telemetry_service.dart';
import '../services/auth_service.dart';
import '../services/supabase_service_v2.dart';
import '../models/task.dart';
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