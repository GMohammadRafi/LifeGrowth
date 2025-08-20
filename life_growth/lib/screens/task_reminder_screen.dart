import 'package:flutter/material.dart';
import '../models/daily_task.dart' as model;
import '../services/notification_service.dart';
import '../services/telemetry_service.dart';
import '../models/custom_reminder.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TaskReminderScreen extends StatefulWidget {
  const TaskReminderScreen({super.key});

  @override
  State<TaskReminderScreen> createState() => _TaskReminderScreenState();
}

class _TaskReminderScreenState extends State<TaskReminderScreen> with TickerProviderStateMixin {
  final NotificationService _notificationService = NotificationService();
  List<model.DailyTask> _tasks = [];
  List<CustomReminder> _customReminders = [];
  Map<String, DateTime?> _taskReminders = {};
  bool _isLoading = true;
  int _selectedTabIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Track screen view
    TelemetryService().trackScreenView('task_reminder_screen');
    _loadTasksAndReminders();
    _loadCustomReminders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  Future<void> _loadCustomReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final remindersJson = prefs.getStringList('custom_reminders') ?? [];
      
      setState(() {
        _customReminders = remindersJson
            .map((json) => CustomReminder.fromJson(jsonDecode(json)))
            .where((reminder) => reminder.isActive)
            .toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading custom reminders: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveCustomReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final remindersJson = _customReminders
          .map((reminder) => jsonEncode(reminder.toJson()))
          .toList();
      await prefs.setStringList('custom_reminders', remindersJson);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving custom reminders: $e'),
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

  Future<void> _createCustomReminder() async {
    final result = await showDialog<CustomReminder>(
      context: context,
      builder: (context) => _CustomReminderDialog(),
    );

    if (result != null) {
      final newReminder = result.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: AuthService.userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      try {
        await _notificationService.setTaskReminder(
          taskId: newReminder.id!,
          taskTitle: newReminder.title,
          reminderTime: newReminder.reminderTime,
        );

        setState(() {
          _customReminders.add(newReminder);
        });
        await _saveCustomReminders();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Custom reminder created successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create reminder: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _editCustomReminder(CustomReminder reminder) async {
    final result = await showDialog<CustomReminder>(
      context: context,
      builder: (context) => _CustomReminderDialog(reminder: reminder),
    );

    if (result != null) {
      final updatedReminder = result.copyWith(
        id: reminder.id,
        userId: reminder.userId,
        createdAt: reminder.createdAt,
        updatedAt: DateTime.now(),
      );

      try {
        // Remove old notification
        await _notificationService.removeTaskReminder(reminder.id!);
        
        // Set new notification
        await _notificationService.setTaskReminder(
          taskId: updatedReminder.id!,
          taskTitle: updatedReminder.title,
          reminderTime: updatedReminder.reminderTime,
        );

        setState(() {
          final index = _customReminders.indexWhere((r) => r.id == reminder.id);
          if (index != -1) {
            _customReminders[index] = updatedReminder;
          }
        });
        await _saveCustomReminders();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Custom reminder updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update reminder: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteCustomReminder(CustomReminder reminder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Reminder'),
        content: Text('Are you sure you want to delete "${reminder.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _notificationService.removeTaskReminder(reminder.id!);
        
        setState(() {
          _customReminders.removeWhere((r) => r.id == reminder.id);
        });
        await _saveCustomReminders();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Custom reminder deleted'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete reminder: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Daily Tasks', icon: Icon(Icons.task_alt)),
            Tab(text: 'Custom Reminders', icon: Icon(Icons.alarm_add)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Daily Tasks Tab
          _isLoading
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
                                    'Reminder: ${_TaskReminderScreenState._formatDateTime(reminderDate)}',
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
          // Custom Reminders Tab
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: _createCustomReminder,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Custom Reminder'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
              Expanded(
                child: _customReminders.isEmpty
                    ? const Center(
                        child: Text(
                          'No custom reminders found\nTap the button above to create one',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _customReminders.length,
                        itemBuilder: (context, index) {
                          final reminder = _customReminders[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              title: Text(
                                reminder.title,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (reminder.description?.isNotEmpty == true)
                                    Text(reminder.description!),
                                  Text(
                                     'Reminder: ${_TaskReminderScreenState._formatDateTime(reminder.reminderTime)}',
                                     style: const TextStyle(color: Colors.green),
                                   ),
                                  if (reminder.isRecurring)
                                    Text(
                                      'Recurring: ${reminder.recurrencePattern}',
                                      style: const TextStyle(color: Colors.blue),
                                    ),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _editCustomReminder(reminder);
                                  } else if (value == 'delete') {
                                    _deleteCustomReminder(reminder);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatDateTime(DateTime dateTime) {
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

class _CustomReminderDialog extends StatefulWidget {
  final CustomReminder? reminder;

  const _CustomReminderDialog({this.reminder});

  @override
  State<_CustomReminderDialog> createState() => _CustomReminderDialogState();
}

class _CustomReminderDialogState extends State<_CustomReminderDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now().add(const Duration(hours: 1));
  bool _isRecurring = false;
  String _recurrencePattern = 'daily';

  @override
  void initState() {
    super.initState();
    if (widget.reminder != null) {
      _titleController.text = widget.reminder!.title;
      _descriptionController.text = widget.reminder!.description ?? '';
      _selectedDateTime = widget.reminder!.reminderTime;
      _isRecurring = widget.reminder!.isRecurring;
      _recurrencePattern = widget.reminder!.recurrencePattern ?? 'daily';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
     final date = await showDatePicker(
       context: context,
       initialDate: _selectedDateTime,
       firstDate: DateTime.now(),
       lastDate: DateTime.now().add(const Duration(days: 365)),
     );

     if (date != null) {
       final time = await showTimePicker(
         context: context,
         initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
       );

       if (time != null) {
         setState(() {
           _selectedDateTime = DateTime(
             date.year,
             date.month,
             date.day,
             time.hour,
             time.minute,
           );
         });
       }
     }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.reminder == null ? 'Create Custom Reminder' : 'Edit Custom Reminder'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Reminder Time'),
              subtitle: Text(_TaskReminderScreenState._formatDateTime(_selectedDateTime)),
              trailing: const Icon(Icons.access_time),
              onTap: _selectDateTime,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Recurring'),
              value: _isRecurring,
              onChanged: (value) {
                setState(() {
                  _isRecurring = value;
                });
              },
            ),
            if (_isRecurring)
              DropdownButtonFormField<String>(
                value: _recurrencePattern,
                decoration: const InputDecoration(
                  labelText: 'Recurrence Pattern',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'daily', child: Text('Daily')),
                  DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _recurrencePattern = value;
                    });
                  }
                },
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter a title'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            final reminder = CustomReminder(
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
              reminderTime: _selectedDateTime,
              isRecurring: _isRecurring,
              recurrencePattern: _isRecurring ? _recurrencePattern : null,
              isActive: true,
            );

            Navigator.of(context).pop(reminder);
          },
          child: Text(widget.reminder == null ? 'Create' : 'Update'),
        ),
      ],
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