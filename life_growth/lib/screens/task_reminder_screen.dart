import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/telemetry_service.dart';
import '../models/daily_task.dart' as model;
import '../services/database_service.dart';
import '../services/auth_service.dart';

class TaskReminderScreen extends StatefulWidget {
  const TaskReminderScreen({super.key});

  @override
  State<TaskReminderScreen> createState() => _TaskReminderScreenState();
}

class _TaskReminderScreenState extends State<TaskReminderScreen> {
  final NotificationService _notificationService = NotificationService();
  List<model.DailyTask> _tasks = [];
  Map<String, DateTime?> _taskReminders = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Track screen view
    TelemetryService().trackScreenView('task_reminder_screen');
    _loadTasksAndReminders();
  }

  Future<void> _loadTasksAndReminders() async {
    try {
      final userId = AuthService.userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      final tasks = await DatabaseService.instance.getAllDailyTasksForUser(userId);
      final reminders = await _notificationService.getPendingReminders();
      
      setState(() {
        _tasks = tasks;
        _taskReminders = {};
        
        // Map task reminders
        for (final reminder in reminders) {
          if (reminder['type'] == 'task') {
            final taskId = reminder['taskId']?.toString();
            final scheduledDate = reminder['scheduledDate'] as DateTime?;
            if (taskId != null && scheduledDate != null) {
              _taskReminders[taskId] = scheduledDate;
            }
          }
        }
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading tasks: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _setTaskReminder(model.DailyTask task) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _taskReminders[task.id ?? ''] ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      final TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          _taskReminders[task.id ?? ''] ?? DateTime.now().add(const Duration(hours: 1)),
        ),
      );

      if (selectedTime != null) {
        final DateTime reminderDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        try {
          await _notificationService.setTaskReminder(
            taskId: task.id ?? '',
            taskTitle: 'Daily Task for ${task.date.day}/${task.date.month}/${task.date.year}',
            reminderTime: reminderDateTime,
          );

          setState(() {
            _taskReminders[task.id ?? ''] = reminderDateTime;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Reminder set for daily task'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to set reminder: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  Future<void> _removeTaskReminder(model.DailyTask task) async {
    try {
      await _notificationService.removeTaskReminder(task.id ?? '');
      
      setState(() {
        _taskReminders.remove(task.id ?? '');
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Reminder removed for daily task'),
                backgroundColor: Colors.orange,
              ),
            );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove reminder: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Reminders'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.task_alt,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No tasks available',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Create some tasks to set reminders',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    final taskId = task.id ?? '';
                    final hasReminder = _taskReminders.containsKey(taskId);
                    final reminderDate = _taskReminders[taskId];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: hasReminder
                              ? Colors.green
                              : Colors.grey.shade300,
                          child: Icon(
                            hasReminder
                                ? Icons.notifications_active
                                : Icons.notifications_off,
                            color: hasReminder ? Colors.white : Colors.grey,
                          ),
                        ),
                        title: Text(
                          'Daily Task - ${task.date.day}/${task.date.month}/${task.date.year}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: hasReminder && reminderDate != null
                            ? Text(
                                'Reminder: ${_formatDateTime(reminderDate)}',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            : const Text(
                                'No reminder set',
                                style: TextStyle(color: Colors.grey),
                              ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'set':
                                _setTaskReminder(task);
                                break;
                              case 'remove':
                                _removeTaskReminder(task);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'set',
                              child: ListTile(
                                leading: Icon(Icons.add_alarm),
                                title: Text('Set Reminder'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            if (hasReminder)
                              const PopupMenuItem(
                                value: 'remove',
                                child: ListTile(
                                  leading: Icon(Icons.alarm_off),
                                  title: Text('Remove Reminder'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final reminderDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateStr;
    if (reminderDate == today) {
      dateStr = 'Today';
    } else if (reminderDate == tomorrow) {
      dateStr = 'Tomorrow';
    } else {
      dateStr = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }

    final timeStr = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$dateStr at $timeStr';
  }
}