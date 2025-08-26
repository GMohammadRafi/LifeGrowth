import 'package:flutter/material.dart';
import '../models/task_type.dart';
import '../services/supabase_service_v2.dart';

class CreateTaskDialog extends StatefulWidget {
  final List<TaskType> taskTypes;
  final VoidCallback onTaskCreated;
  
  const CreateTaskDialog({
    super.key,
    required this.taskTypes,
    required this.onTaskCreated,
  });
  
  @override
  State<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<CreateTaskDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  TaskType? _selectedTaskType;
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Task'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<TaskType>(
            value: _selectedTaskType,
            decoration: const InputDecoration(labelText: 'Task Type'),
            items: widget.taskTypes.map((type) => DropdownMenuItem(
              value: type,
              child: Text(type.name),
            )).toList(),
            onChanged: (value) => setState(() => _selectedTaskType = value),
          ),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Task Name'),
          ),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description (optional)'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _createTask,
          child: const Text('Create'),
        ),
      ],
    );
  }
  
  Future<void> _createTask() async {
    if (_selectedTaskType == null || _nameController.text.isEmpty) return;
    
    await SupabaseServiceV2.createTask(
      taskTypeId: _selectedTaskType!.id,
      name: _nameController.text,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
    );
    
    widget.onTaskCreated();
    Navigator.pop(context);
  }
}