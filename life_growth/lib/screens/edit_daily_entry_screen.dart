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
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Text(
                  'All changes saved successfully!',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Failed to save changes: $e',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
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
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        title: Text(
          'Edit ${widget.dailyEntry.date.day}/${widget.dailyEntry.date.month}/${widget.dailyEntry.date.year}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            )
          else
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.save_outlined),
                onPressed: _saveAllChanges,
                tooltip: 'Save Changes',
                color: Colors.white,
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notes section with modern styling
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.note_outlined,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Daily Notes',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: TextFormField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          hintText: 'Add notes for this day...',
                          hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        maxLines: 4,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Tasks section header with modern styling
            Row(
              children: [
                Icon(
                  Icons.task_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Daily Tasks',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${widget.userTasks.length} tasks',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Build task forms with modern containers
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
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.shadow.withOpacity(0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DynamicTaskForm(
                      taskType: taskType,
                      task: task,
                      initialData: initialData,
                      formKey: _taskFormKeys[task.id],
                      onDataChanged: (data, completed) {
                        _updateTaskData(task.id, data, completed);
                      },
                    ),
                  ),
                ),
              );
            }).toList(),
            
            const SizedBox(height: 32),
            
            // Save All Button with modern styling
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveAllChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 16),
                          Text(
                            'Saving Changes...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.save_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Save All Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
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