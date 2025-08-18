import 'package:flutter/material.dart';
import '../models/personalization_settings.dart';
import '../services/personalization_service.dart';

class PersonalizationScreen extends StatefulWidget {
  const PersonalizationScreen({super.key});

  @override
  State<PersonalizationScreen> createState() => _PersonalizationScreenState();
}

class _PersonalizationScreenState extends State<PersonalizationScreen> {
  late PersonalizationService _personalizationService;
  PersonalizationSettings? _settings;
  bool _isLoading = true;
  final _avoidHabitLabelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    _personalizationService = await PersonalizationService.getInstance();
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _personalizationService.loadSettings();
    setState(() {
      _settings = settings;
      _avoidHabitLabelController.text = settings.avoidHabitLabel;
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
          ],
        ),
      ),
    );
  }
}