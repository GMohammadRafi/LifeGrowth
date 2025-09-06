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
              // Enhanced Mark as Completed container with distinct visual styling
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _completed 
                      ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                      : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _completed 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    width: _completed ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Transform.scale(
                      scale: 1.2,
                      child: Checkbox(
                        value: _completed,
                        onChanged: (value) {
                          setState(() {
                            _completed = value ?? false;
                          });
                          _notifyDataChanged();
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                        checkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Mark as completed',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: _completed ? FontWeight.w600 : FontWeight.w500,
                          color: _completed 
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (_completed)
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                  ],
                ),
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
    final fieldTitle = _formatFieldName(fieldName);
    final currentValue = _formData[fieldName] as String?;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: DropdownButtonFormField<String>(
          value: enumValues.contains(currentValue) ? currentValue : null,
          decoration: InputDecoration(
            labelText: fieldTitle + (isRequired ? ' *' : ''),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          items: enumValues.map<DropdownMenuItem<String>>((value) {
            return DropdownMenuItem<String>(
              value: value.toString(),
              child: Text(
                value.toString(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _formData[fieldName] = newValue;
              });
              _notifyDataChanged();
            }
          },
          validator: isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
        ),
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