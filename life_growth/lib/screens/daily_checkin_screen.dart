import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/daily_entry.dart';
import '../models/task_entry.dart';
import '../models/task.dart';
import '../models/task_type.dart';
import '../models/personalization_settings.dart';
import '../services/auth_service.dart';
import '../services/supabase_service_v2.dart';
import '../services/personalization_service.dart';
import '../services/telemetry_service.dart';
import '../services/error_service.dart';
import '../services/notification_service.dart';
import 'personalization_screen.dart';

class DailyCheckinScreen extends StatefulWidget {
  final DailyEntry? existingEntry;
  final List<TaskEntry>? existingTaskEntries;
  final DateTime date;

  const DailyCheckinScreen({
    super.key,
    this.existingEntry,
    this.existingTaskEntries,
    required this.date,
  });

  @override
  State<DailyCheckinScreen> createState() => _DailyCheckinScreenState();
}

class _DailyCheckinScreenState extends State<DailyCheckinScreen> {
  final _formKey = GlobalKey<FormState>();
  late DailyEntry _currentEntry;
  List<TaskEntry> _taskEntries = [];
  List<Task> _userTasks = [];
  List<TaskType> _taskTypes = [];
  bool _isLoading = false;
  bool _hasChanges = false;
  
  // Personalization
  late PersonalizationService _personalizationService;
  PersonalizationSettings _personalizationSettings = PersonalizationSettings.defaultSettings;

  // Form controllers - now dynamic based on tasks
  final Map<String, TextEditingController> _controllers = {};
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
    _initializePersonalization();
    
    // Track screen view for telemetry
    try {
      TelemetryService().trackScreenView('daily_checkin_screen');
    } catch (e) {
      ErrorService().reportError(e, StackTrace.current, context: 'daily_checkin_screen_view');
    }
  }
  
  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load daily data (entry, task entries, tasks, task types)
      final dailyData = await SupabaseServiceV2.getDailyData(widget.date);
      
      _currentEntry = widget.existingEntry ?? dailyData['dailyEntry'] ?? DailyEntry.empty(
        date: widget.date,
        timezoneOffset: DateTime.now().timeZoneOffset.inMinutes,
      ).copyWith(userId: AuthService.userId);
      
      _taskEntries = widget.existingTaskEntries ?? dailyData['taskEntries'] ?? [];
      _userTasks = dailyData['tasks'] ?? [];
      _taskTypes = dailyData['taskTypes'] ?? [];
      
      _setupFormControllers();
    } catch (e) {
      ErrorService().reportError(e, StackTrace.current, context: 'daily_checkin_data_load');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _initializePersonalization() async {
    _personalizationService = await PersonalizationService.getInstance();
    _personalizationSettings = await _personalizationService.loadSettings();
    
    if (mounted) {
      setState(() {});
    }
  }
  
  void _setupFormControllers() {
    // Setup controllers for each task based on their schema
    for (final task in _userTasks) {
      final taskType = _taskTypes.firstWhere((type) => type.id == task.taskTypeId);
      final existingEntry = _taskEntries.where((entry) => entry.taskId == task.id).firstOrNull;
      
      // Create controllers for each field in the task type schema
      final fieldDefinitions = taskType.fieldDefinitions;
      for (final fieldName in fieldDefinitions.keys) {
        final controllerKey = '${task.id}_$fieldName';
        _controllers[controllerKey] = TextEditingController();
        
        // Set initial value from existing entry
        if (existingEntry != null) {
          final value = existingEntry.getDataValue(fieldName);
          if (value != null) {
            _controllers[controllerKey]!.text = value.toString();
          }
        }
        
        // Add change listener
        _controllers[controllerKey]!.addListener(() {
          if (!_hasChanges) {
            setState(() => _hasChanges = true);
          }
        });
      }
    }
    
    // Setup notes controller
    _notesController.text = _currentEntry.notes ?? '';
    _notesController.addListener(() {
      if (!_hasChanges) {
        setState(() => _hasChanges = true);
      }
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _notesController.dispose();
    super.dispose();
  }

  void _updateTaskEntry(String taskId, String fieldName, dynamic value) {
    final existingEntryIndex = _taskEntries.indexWhere((entry) => entry.taskId == taskId);
    
    if (existingEntryIndex >= 0) {
      // Update existing entry
      final existingEntry = _taskEntries[existingEntryIndex];
      final updatedData = Map<String, dynamic>.from(existingEntry.data);
      updatedData[fieldName] = value;
      
      _taskEntries[existingEntryIndex] = existingEntry.copyWith(
        data: updatedData,
        updatedAt: DateTime.now(),
      );
    } else {
      // Create new entry
      final newEntry = TaskEntry(
        id: '', // Will be generated by database
        dailyEntryId: _currentEntry.id,
        taskId: taskId,
        data: {fieldName: value},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _taskEntries.add(newEntry);
    }
    
    setState(() => _hasChanges = true);
  }
  
  void _toggleTaskCompletion(String taskId, bool completed) {
    final existingEntryIndex = _taskEntries.indexWhere((entry) => entry.taskId == taskId);
    
    if (existingEntryIndex >= 0) {
      _taskEntries[existingEntryIndex] = _taskEntries[existingEntryIndex].copyWith(
        completed: completed,
        updatedAt: DateTime.now(),
      );
    } else {
      final newEntry = TaskEntry(
        id: '',
        dailyEntryId: _currentEntry.id,
        taskId: taskId,
        data: {},
        completed: completed,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _taskEntries.add(newEntry);
    }
    
    // Track task completion for telemetry
    try {
      final task = _userTasks.firstWhere((t) => t.id == taskId);
      TelemetryService().trackTaskToggle(
        taskId: task.name.toLowerCase().replaceAll(' ', '_'),
        isCompleted: completed,
        category: 'daily_task',
      );
    } catch (e) {
      ErrorService().reportError(e, StackTrace.current, context: 'task_completion_tracking');
    }
    
    setState(() => _hasChanges = true);
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;
    if (!AuthService.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('User not authenticated'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Update daily entry with notes
      final updatedEntry = _currentEntry.copyWith(
        userId: AuthService.userId,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        updatedAt: DateTime.now(),
      );
      
      // Save daily entry
      final savedEntry = await SupabaseServiceV2.createOrUpdateDailyEntry(updatedEntry);
      
      // Update task entries with form data and save them
      for (final task in _userTasks) {
        final taskType = _taskTypes.firstWhere((type) => type.id == task.taskTypeId);
        final existingEntryIndex = _taskEntries.indexWhere((entry) => entry.taskId == task.id);
        
        // Collect data from form controllers
        final taskData = <String, dynamic>{};
        final fieldDefinitions = taskType.fieldDefinitions;
        
        for (final fieldName in fieldDefinitions.keys) {
          final controllerKey = '${task.id}_$fieldName';
          final controller = _controllers[controllerKey];
          if (controller != null && controller.text.isNotEmpty) {
            // Parse value based on field type
            final fieldDef = fieldDefinitions[fieldName] as Map<String, dynamic>;
            final fieldType = fieldDef['type'] as String?;
            
            switch (fieldType) {
              case 'integer':
                taskData[fieldName] = int.tryParse(controller.text);
                break;
              case 'number':
                taskData[fieldName] = double.tryParse(controller.text);
                break;
              case 'boolean':
                taskData[fieldName] = controller.text.toLowerCase() == 'true';
                break;
              default:
                taskData[fieldName] = controller.text;
            }
          }
        }
        
        if (existingEntryIndex >= 0) {
          // Update existing entry
          final existingEntry = _taskEntries[existingEntryIndex];
          final updatedTaskEntry = existingEntry.copyWith(
            dailyEntryId: savedEntry.id,
            data: taskData,
            updatedAt: DateTime.now(),
          );
          await SupabaseServiceV2.createOrUpdateTaskEntry(updatedTaskEntry);
        } else if (taskData.isNotEmpty) {
          // Create new entry only if there's data
          final newTaskEntry = TaskEntry(
            id: '',
            dailyEntryId: savedEntry.id,
            taskId: task.id,
            data: taskData,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await SupabaseServiceV2.createOrUpdateTaskEntry(newTaskEntry);
        }
      }
      
      // Track task detail edit for telemetry
      try {
        final completedTasksCount = _taskEntries.where((entry) => entry.completed).length;
        TelemetryService().trackTaskDetailEdit(
          taskDate: updatedEntry.date,
          completedTasksCount: completedTasksCount,
          hasNotes: updatedEntry.notes?.isNotEmpty ?? false,
        );
        
        // Show success toast
        NotificationService().showSuccessToast('Daily check-in saved successfully!');
      } catch (e) {
        ErrorService().reportError(e, StackTrace.current, context: 'task_detail_edit_tracking');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Daily check-in saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      ErrorService().reportError(e, StackTrace.current, context: 'daily_checkin_save');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving daily check-in: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Check-in - ${widget.date.toString().split(' ')[0]}'),
        actions: [
          if (_hasChanges)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveData,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Build dynamic task forms based on user's tasks
            ..._buildTaskForms(),
            
            const SizedBox(height: 20),
            
            // Notes section
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Add any notes for today...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 20),
            
            // Save button
            ElevatedButton(
              onPressed: _hasChanges ? _saveData : null,
              child: const Text('Save Daily Check-in'),
            ),
          ],
        ),
      ),
    );
  }
  
  List<Widget> _buildTaskForms() {
    final widgets = <Widget>[];
    
    for (final task in _userTasks) {
      final taskType = _taskTypes.firstWhere((type) => type.id == task.taskTypeId);
      final existingEntry = _taskEntries.where((entry) => entry.taskId == task.id).firstOrNull;
      
      widgets.add(
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task title with completion checkbox
                Row(
                  children: [
                    Checkbox(
                      value: existingEntry?.completed ?? false,
                      onChanged: (value) => _toggleTaskCompletion(task.id, value ?? false),
                    ),
                    Expanded(
                      child: Text(
                        task.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                
                if (task.description != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      task.description!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                
                // Dynamic form fields based on task type schema
                ..._buildTaskFields(task, taskType),
              ],
            ),
          ),
        ),
      );
      
      widgets.add(const SizedBox(height: 16));
    }
    
    return widgets;
  }
  
  List<Widget> _buildTaskFields(Task task, TaskType taskType) {
    final widgets = <Widget>[];
    final fieldDefinitions = taskType.fieldDefinitions;
    
    for (final entry in fieldDefinitions.entries) {
      final fieldName = entry.key;
      final fieldDef = entry.value as Map<String, dynamic>;
      final fieldType = fieldDef['type'] as String?;
      final fieldTitle = fieldDef['title'] as String? ?? fieldName;
      final isRequired = taskType.requiredFields.contains(fieldName);
      
      final controllerKey = '${task.id}_$fieldName';
      final controller = _controllers[controllerKey];
      
      if (controller != null) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: fieldTitle + (isRequired ? ' *' : ''),
                border: const OutlineInputBorder(),
              ),
              keyboardType: _getKeyboardType(fieldType),
              validator: isRequired ? (value) {
                if (value == null || value.isEmpty) {
                  return 'This field is required';
                }
                return null;
              } : null,
              onChanged: (value) => _updateTaskEntry(task.id, fieldName, value),
            ),
          ),
        );
      }
    }
    
    return widgets;
  }
  
  TextInputType _getKeyboardType(String? fieldType) {
    switch (fieldType) {
      case 'integer':
      case 'number':
        return TextInputType.number;
      case 'email':
        return TextInputType.emailAddress;
      case 'url':
        return TextInputType.url;
      default:
        return TextInputType.text;
    }
  }
}