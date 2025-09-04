import 'package:flutter/material.dart';
import '../models/daily_entry.dart';
import '../models/task_entry.dart';
import '../models/task.dart';
import '../models/task_type.dart';
import '../services/supabase_service_v2.dart';
import '../widgets/dynamic_task_form.dart';

class EditDailyEntryScreen extends StatefulWidget {
  final DailyEntry dailyEntry;
  final List<TaskEntry> taskEntries;
  final List<Task> userTasks;
  final List<TaskType> taskTypes;

  const EditDailyEntryScreen({
    Key? key,
    required this.dailyEntry,
    required this.taskEntries,
    required this.userTasks,
    required this.taskTypes,
  }) : super(key: key);

  @override
  State<EditDailyEntryScreen> createState() => _EditDailyEntryScreenState();
}

class _EditDailyEntryScreenState extends State<EditDailyEntryScreen> {
  final _notesController = TextEditingController();
  bool _isLoading = false;
  Map<String, TaskEntry> _taskEntriesMap = {};
  Map<String, GlobalKey<FormState>> _taskFormKeys = {};
  Map<String, Map<String, dynamic>> _taskFormData = {};
  Map<String, bool> _taskCompletionStatus = {};

  @override
  void initState() {
    super.initState();
    _notesController.text = widget.dailyEntry.notes ?? '';
    
    // Create a map of task entries by task ID for easy lookup
    for (final taskEntry in widget.taskEntries) {
      _taskEntriesMap[taskEntry.taskId] = taskEntry;
    }
    
    // Initialize form keys and data for each task
    for (final task in widget.userTasks) {
      _taskFormKeys[task.id] = GlobalKey<FormState>();
      final taskEntry = _taskEntriesMap[task.id];
      _taskFormData[task.id] = Map<String, dynamic>.from(taskEntry?.data ?? {});
      _taskCompletionStatus[task.id] = taskEntry?.completed ?? false;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  TaskType? _getTaskType(String taskTypeId) {
    try {
      return widget.taskTypes.firstWhere((type) => type.id == taskTypeId);
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveAllChanges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Validate all task forms
      bool allFormsValid = true;
      for (final formKey in _taskFormKeys.values) {
        if (!formKey.currentState!.validate()) {
          allFormsValid = false;
        }
      }
      
      if (!allFormsValid) {
        throw Exception('Please fix validation errors in the forms');
      }

      // Update daily entry notes
      await SupabaseServiceV2.createOrUpdateDailyEntry(
        date: widget.dailyEntry.date,
        notes: _notesController.text,
      );

      // Update all task entries
      for (final task in widget.userTasks) {
        final taskData = _taskFormData[task.id] ?? {};
        final completed = _taskCompletionStatus[task.id] ?? false;
        
        await SupabaseServiceV2.createOrUpdateTaskEntry(
          dailyEntryId: widget.dailyEntry.id,
          taskId: task.id,
          data: taskData,
          completed: completed,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All changes saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save changes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _updateTaskData(String taskId, Map<String, dynamic> data, bool completed) {
    setState(() {
      _taskFormData[taskId] = data;
      _taskCompletionStatus[taskId] = completed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.dailyEntry.date.day}/${widget.dailyEntry.date.month}/${widget.dailyEntry.date.year}'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveAllChanges,
              tooltip: 'Save',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notes section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        hintText: 'Add notes for this day...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Tasks section
            Text(
              'Tasks',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            
            // Build task forms
            ...widget.userTasks.map((task) {
              final taskType = _getTaskType(task.taskTypeId);
              if (taskType == null) {
                return const SizedBox.shrink();
              }
              
              final taskEntry = _taskEntriesMap[task.id];
              final initialData = Map<String, dynamic>.from(taskEntry?.data ?? {});
              if (taskEntry != null) {
                initialData['completed'] = taskEntry.completed;
              }
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: DynamicTaskForm(
                  taskType: taskType,
                  task: task,
                  initialData: initialData,
                  formKey: _taskFormKeys[task.id],
                  onDataChanged: (data, completed) {
                    _updateTaskData(task.id, data, completed);
                  },
                ),
              );
            }).toList(),
            
            const SizedBox(height: 32),
            
            // Save All Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveAllChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Saving...'),
                        ],
                      )
                    : const Text(
                        'Save All Changes',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}