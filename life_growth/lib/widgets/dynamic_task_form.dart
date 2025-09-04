import 'package:flutter/material.dart';
import '../models/task_type.dart';
import '../models/task.dart';

class DynamicTaskForm extends StatefulWidget {
  final TaskType taskType;
  final Task task;
  final Map<String, dynamic>? initialData;
  final Function(Map<String, dynamic> data, bool completed)? onDataChanged;
  final GlobalKey<FormState>? formKey;

  const DynamicTaskForm({
    Key? key,
    required this.taskType,
    required this.task,
    this.initialData,
    this.onDataChanged,
    this.formKey,
  }) : super(key: key);

  @override
  State<DynamicTaskForm> createState() => _DynamicTaskFormState();
}

class _DynamicTaskFormState extends State<DynamicTaskForm> {
  late GlobalKey<FormState> _formKey;
  late Map<String, dynamic> _formData;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _formKey = widget.formKey ?? GlobalKey<FormState>();
    _formData = Map<String, dynamic>.from(widget.initialData ?? {});
    _completed = _formData['completed'] ?? false;
  }

  void _notifyDataChanged() {
    if (widget.onDataChanged != null) {
      widget.onDataChanged!(_formData, _completed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.task.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (widget.task.description != null)
                Text(
                  widget.task.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              const SizedBox(height: 16),
              ...widget.taskType.fieldDefinitions.entries.map(
                (entry) => _buildField(entry.key, entry.value),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _completed,
                    onChanged: (value) {
                      setState(() {
                        _completed = value ?? false;
                      });
                      _notifyDataChanged();
                    },
                  ),
                  const Text('Mark as completed'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String fieldName, Map<String, dynamic> fieldDef) {
    final type = fieldDef['type'] as String?;
    final isRequired = widget.taskType.requiredFields.contains(fieldName);
    
    switch (type) {
      case 'integer':
        return _buildIntegerField(fieldName, fieldDef, isRequired);
      case 'number':
        return _buildNumberField(fieldName, fieldDef, isRequired);
      case 'string':
        if (fieldDef['enum'] != null) {
          return _buildEnumField(fieldName, fieldDef, isRequired);
        } else if (fieldDef['format'] == 'time') {
          return _buildTimeField(fieldName, fieldDef, isRequired);
        } else {
          return _buildStringField(fieldName, fieldDef, isRequired);
        }
      case 'boolean':
        return _buildBooleanField(fieldName, fieldDef, isRequired);
      default:
        return _buildStringField(fieldName, fieldDef, isRequired);
    }
  }

  Widget _buildIntegerField(String fieldName, Map<String, dynamic> fieldDef, bool isRequired) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: _formatFieldName(fieldName) + (isRequired ? ' *' : ''),
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        initialValue: _formData[fieldName]?.toString(),
        validator: isRequired ? (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        } : null,
        onChanged: (value) {
          setState(() {
            _formData[fieldName] = int.tryParse(value ?? '') ?? 0;
          });
          _notifyDataChanged();
        },
        onSaved: (value) {
          if (value != null && value.isNotEmpty) {
            _formData[fieldName] = int.tryParse(value) ?? 0;
          }
        },
      ),
    );
  }

  Widget _buildNumberField(String fieldName, Map<String, dynamic> fieldDef, bool isRequired) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: _formatFieldName(fieldName) + (isRequired ? ' *' : ''),
          border: const OutlineInputBorder(),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        initialValue: _formData[fieldName]?.toString(),
        validator: isRequired ? (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        } : null,
        onChanged: (value) {
          setState(() {
            _formData[fieldName] = double.tryParse(value ?? '') ?? 0.0;
          });
          _notifyDataChanged();
        },
        onSaved: (value) {
          if (value != null && value.isNotEmpty) {
            _formData[fieldName] = double.tryParse(value) ?? 0.0;
          }
        },
      ),
    );
  }

  Widget _buildStringField(String fieldName, Map<String, dynamic> fieldDef, bool isRequired) {
    final maxLength = fieldDef['maxLength'] as int?;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: _formatFieldName(fieldName) + (isRequired ? ' *' : ''),
          border: const OutlineInputBorder(),
        ),
        maxLength: maxLength,
        maxLines: maxLength != null && maxLength > 100 ? 3 : 1,
        initialValue: _formData[fieldName]?.toString(),
        validator: isRequired ? (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        } : null,
        onChanged: (value) {
          setState(() {
            _formData[fieldName] = value ?? '';
          });
          _notifyDataChanged();
        },
        onSaved: (value) {
          if (value != null && value.isNotEmpty) {
            _formData[fieldName] = value;
          }
        },
      ),
    );
  }

  Widget _buildEnumField(String fieldName, Map<String, dynamic> fieldDef, bool isRequired) {
    final enumValues = (fieldDef['enum'] as List<dynamic>).cast<String>();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: _formatFieldName(fieldName) + (isRequired ? ' *' : ''),
          border: const OutlineInputBorder(),
        ),
        value: _formData[fieldName] as String?,
        items: enumValues.map((value) => DropdownMenuItem(
          value: value,
          child: Text(value),
        )).toList(),
        validator: isRequired ? (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        } : null,
        onChanged: (value) {
          setState(() {
            if (value != null) {
              _formData[fieldName] = value;
            }
          });
          _notifyDataChanged();
        },
      ),
    );
  }

  Widget _buildTimeField(String fieldName, Map<String, dynamic> fieldDef, bool isRequired) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: _formatFieldName(fieldName) + (isRequired ? ' *' : ''),
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: const Icon(Icons.access_time),
            onPressed: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (time != null) {
                final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                setState(() {
                  _formData[fieldName] = timeString;
                });
                _notifyDataChanged();
              }
            },
          ),
        ),
        readOnly: true,
        controller: TextEditingController(text: _formData[fieldName]?.toString()),
        validator: isRequired ? (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        } : null,
      ),
    );
  }

  Widget _buildBooleanField(String fieldName, Map<String, dynamic> fieldDef, bool isRequired) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: CheckboxListTile(
        title: Text(_formatFieldName(fieldName) + (isRequired ? ' *' : '')),
        value: _formData[fieldName] as bool? ?? false,
        onChanged: (value) {
          setState(() {
            _formData[fieldName] = value ?? false;
          });
          _notifyDataChanged();
        },
      ),
    );
  }

  String _formatFieldName(String fieldName) {
    return fieldName
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }


}