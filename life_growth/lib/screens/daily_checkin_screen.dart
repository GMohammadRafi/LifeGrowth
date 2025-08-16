import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import '../models/daily_task.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';

class DailyCheckinScreen extends StatefulWidget {
  final DailyTask? existingTask;
  final DateTime date;

  const DailyCheckinScreen({
    super.key,
    this.existingTask,
    required this.date,
  });

  @override
  State<DailyCheckinScreen> createState() => _DailyCheckinScreenState();
}

class _DailyCheckinScreenState extends State<DailyCheckinScreen> {
  final _formKey = GlobalKey<FormState>();
  late DailyTask _currentTask;
  bool _isLoading = false;
  bool _hasChanges = false;

  // Form controllers
  final _readingBookPagesController = TextEditingController();
  final _readingBookTimeController = TextEditingController();
  final _stretchMinutesController = TextEditingController();
  final _meditationMinutesController = TextEditingController();
  final _readingDocsPagesController = TextEditingController();
  final _readingDocsTimeController = TextEditingController();
  final _readingDocsNameController = TextEditingController();
  final _learningTechNameController = TextEditingController();
  final _learningTechSourceController = TextEditingController();
  final _learningTechUrlController = TextEditingController();
  final _learningTechTimeController = TextEditingController();
  final _walkingStepsController = TextEditingController();
  final _walkingTimeController = TextEditingController();
  final _avoidHabitLabelController = TextEditingController();
  final _movieSeriesNameController = TextEditingController();
  final _movieSeriesStartTimeController = TextEditingController();
  final _movieSeriesEndTimeController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeTask();
    _setupFormControllers();
  }

  void _initializeTask() {
    if (widget.existingTask != null) {
      _currentTask = widget.existingTask!;
    } else {
      _currentTask = DailyTask.empty(
        date: widget.date,
        timezoneOffset: DateTime.now().timeZoneOffset.inMinutes,
      ).copyWith(userId: AuthService.userId);
    }
  }

  void _setupFormControllers() {
    _readingBookPagesController.text = _currentTask.readingBookPages?.toString() ?? '';
    _readingBookTimeController.text = _currentTask.readingBookTime?.toString() ?? '';
    _stretchMinutesController.text = _currentTask.stretchMinutes?.toString() ?? '';
    _meditationMinutesController.text = _currentTask.meditationMinutes?.toString() ?? '';
    _readingDocsPagesController.text = _currentTask.readingDocsPages?.toString() ?? '';
    _readingDocsTimeController.text = _currentTask.readingDocsTime?.toString() ?? '';
    _readingDocsNameController.text = _currentTask.readingDocsNameLink ?? '';
    _learningTechNameController.text = _currentTask.learningTechName ?? '';
    _learningTechSourceController.text = _currentTask.learningTechSource ?? '';
    _learningTechUrlController.text = _currentTask.learningTechUrl ?? '';
    _learningTechTimeController.text = _currentTask.learningTechTime?.toString() ?? '';
    _walkingStepsController.text = _currentTask.walkingSteps?.toString() ?? '';
    _walkingTimeController.text = _currentTask.walkingTime?.toString() ?? '';
    _avoidHabitLabelController.text = _currentTask.avoidHabitLabel ?? '';
    _movieSeriesNameController.text = _currentTask.movieSeriesName ?? '';
    _movieSeriesStartTimeController.text = _currentTask.movieSeriesStartTime ?? '';
    _movieSeriesEndTimeController.text = _currentTask.movieSeriesEndTime ?? '';
    _notesController.text = _currentTask.notes ?? '';

    // Add listeners to track changes
    final controllers = [
      _readingBookPagesController, _readingBookTimeController, _stretchMinutesController,
      _meditationMinutesController, _readingDocsPagesController, _readingDocsTimeController,
      _readingDocsNameController, _learningTechNameController, _learningTechSourceController,
      _learningTechUrlController, _learningTechTimeController, _walkingStepsController,
      _walkingTimeController, _avoidHabitLabelController, _movieSeriesNameController,
      _movieSeriesStartTimeController, _movieSeriesEndTimeController, _notesController,
    ];

    for (final controller in controllers) {
      controller.addListener(() {
        if (!_hasChanges) {
          setState(() => _hasChanges = true);
        }
      });
    }
  }

  @override
  void dispose() {
    _readingBookPagesController.dispose();
    _readingBookTimeController.dispose();
    _stretchMinutesController.dispose();
    _meditationMinutesController.dispose();
    _readingDocsPagesController.dispose();
    _readingDocsTimeController.dispose();
    _readingDocsNameController.dispose();
    _learningTechNameController.dispose();
    _learningTechSourceController.dispose();
    _learningTechUrlController.dispose();
    _learningTechTimeController.dispose();
    _walkingStepsController.dispose();
    _walkingTimeController.dispose();
    _avoidHabitLabelController.dispose();
    _movieSeriesNameController.dispose();
    _movieSeriesStartTimeController.dispose();
    _movieSeriesEndTimeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateTaskField<T>(T value, DailyTask Function(T) updater) {
    setState(() {
      _currentTask = updater(value);
      _hasChanges = true;
    });
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;
    if (!AuthService.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Build updated task with form data
      final updatedTask = _currentTask.copyWith(
        userId: AuthService.userId,
        readingBookPages: _readingBookPagesController.text.isNotEmpty 
            ? int.tryParse(_readingBookPagesController.text) : null,
        readingBookTime: _readingBookTimeController.text.isNotEmpty 
            ? int.tryParse(_readingBookTimeController.text) : null,
        stretchMinutes: _stretchMinutesController.text.isNotEmpty 
            ? int.tryParse(_stretchMinutesController.text) : null,
        meditationMinutes: _meditationMinutesController.text.isNotEmpty 
            ? int.tryParse(_meditationMinutesController.text) : null,
        readingDocsPages: _readingDocsPagesController.text.isNotEmpty 
            ? int.tryParse(_readingDocsPagesController.text) : null,
        readingDocsTime: _readingDocsTimeController.text.isNotEmpty 
            ? int.tryParse(_readingDocsTimeController.text) : null,
        readingDocsNameLink: _readingDocsNameController.text.isNotEmpty 
            ? _readingDocsNameController.text : null,
        learningTechName: _learningTechNameController.text.isNotEmpty 
            ? _learningTechNameController.text : null,
        learningTechSource: _learningTechSourceController.text.isNotEmpty 
            ? _learningTechSourceController.text : null,
        learningTechUrl: _learningTechUrlController.text.isNotEmpty 
            ? _learningTechUrlController.text : null,
        learningTechTime: _learningTechTimeController.text.isNotEmpty 
            ? int.tryParse(_learningTechTimeController.text) : null,
        walkingSteps: _walkingStepsController.text.isNotEmpty 
            ? int.tryParse(_walkingStepsController.text) : null,
        walkingTime: _walkingTimeController.text.isNotEmpty 
            ? int.tryParse(_walkingTimeController.text) : null,
        avoidHabitLabel: _avoidHabitLabelController.text.isNotEmpty 
            ? _avoidHabitLabelController.text : null,
        movieSeriesName: _movieSeriesNameController.text.isNotEmpty 
            ? _movieSeriesNameController.text : null,
        movieSeriesStartTime: _movieSeriesStartTimeController.text.isNotEmpty 
            ? _movieSeriesStartTimeController.text : null,
        movieSeriesEndTime: _movieSeriesEndTimeController.text.isNotEmpty 
            ? _movieSeriesEndTimeController.text : null,
        movieSeriesDuration: _calculateMovieDuration(),
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      await SupabaseService.upsertDailyTask(updatedTask);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Daily check-in saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate changes were saved
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  int? _calculateMovieDuration() {
    final startTime = _movieSeriesStartTimeController.text;
    final endTime = _movieSeriesEndTimeController.text;
    
    if (startTime.isEmpty || endTime.isEmpty) return null;
    
    try {
      final startParts = startTime.split(':');
      final endParts = endTime.split(':');
      
      if (startParts.length != 2 || endParts.length != 2) return null;
      
      final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
      final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
      
      var duration = endMinutes - startMinutes;
      if (duration < 0) duration += 24 * 60; // Handle overnight durations
      
      return duration;
    } catch (e) {
      return null;
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    
    if (time != null) {
      final formattedTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      controller.text = formattedTime;
      setState(() => _hasChanges = true);
    }
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
    IconData? icon,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    Widget? suffix,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          suffixIcon: suffix,
          isDense: true,
        ),
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        maxLines: maxLines,
      ),
    );
  }

  Widget _buildCheckboxField({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    String? subtitle,
  }) {
    return CheckboxListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      value: value,
      onChanged: (val) => onChanged(val ?? false),
      contentPadding: EdgeInsets.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasChanges) {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Unsaved Changes'),
              content: const Text('You have unsaved changes. Are you sure you want to leave?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Leave'),
                ),
              ],
            ),
          );
          return shouldPop ?? false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Daily Check-in'),
              Text(
                '${widget.date.day}/${widget.date.month}/${widget.date.year}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
              ),
            ],
          ),
          actions: [
            if (_hasChanges)
              TextButton(
                onPressed: _isLoading ? null : _saveTask,
                child: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('SAVE'),
              ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Reading Book Section
              _buildSectionCard(
                title: 'Reading Book',
                icon: Icons.book,
                children: [
                  _buildCheckboxField(
                    title: 'Mark as completed',
                    value: _currentTask.readingBookCompleted,
                    onChanged: (value) => _updateTaskField(
                      value,
                      (val) => _currentTask.copyWith(readingBookCompleted: val),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _readingBookPagesController,
                          label: 'Pages',
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _readingBookTimeController,
                          label: 'Time (minutes)',
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Stretch Section
              _buildSectionCard(
                title: 'Stretch/Exercise',
                icon: Icons.fitness_center,
                children: [
                  _buildCheckboxField(
                    title: 'Mark as completed',
                    value: _currentTask.stretchCompleted,
                    onChanged: (value) => _updateTaskField(
                      value,
                      (val) => _currentTask.copyWith(stretchCompleted: val),
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    value: _currentTask.stretchType,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: ['Yoga', 'Home Workout', 'Gym', 'Other']
                        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) => _updateTaskField(
                      value,
                      (val) => _currentTask.copyWith(stretchType: val),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _stretchMinutesController,
                    label: 'Duration (minutes)',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ],
              ),

              // Meditation Section
              _buildSectionCard(
                title: 'Meditation',
                icon: Icons.self_improvement,
                children: [
                  _buildCheckboxField(
                    title: 'Mark as completed',
                    value: _currentTask.meditationCompleted,
                    onChanged: (value) => _updateTaskField(
                      value,
                      (val) => _currentTask.copyWith(meditationCompleted: val),
                    ),
                  ),
                  _buildTextField(
                    controller: _meditationMinutesController,
                    label: 'Duration (minutes)',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ],
              ),

              // Reading Docs Section
              _buildSectionCard(
                title: 'Reading Documentation',
                icon: Icons.description,
                children: [
                  _buildCheckboxField(
                    title: 'Mark as completed',
                    value: _currentTask.readingDocsCompleted,
                    onChanged: (value) => _updateTaskField(
                      value,
                      (val) => _currentTask.copyWith(readingDocsCompleted: val),
                    ),
                  ),
                  _buildTextField(
                    controller: _readingDocsNameController,
                    label: 'Documentation Name/Link',
                    hint: 'e.g. Flutter documentation, API docs',
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _readingDocsPagesController,
                          label: 'Pages',
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _readingDocsTimeController,
                          label: 'Time (minutes)',
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Learning Technology Section
              _buildSectionCard(
                title: 'Learning New Technology',
                icon: Icons.school,
                children: [
                  _buildCheckboxField(
                    title: 'Mark as completed',
                    value: _currentTask.learningTechCompleted,
                    onChanged: (value) => _updateTaskField(
                      value,
                      (val) => _currentTask.copyWith(learningTechCompleted: val),
                    ),
                  ),
                  _buildTextField(
                    controller: _learningTechNameController,
                    label: 'Technology/Topic',
                    hint: 'e.g. React, Python, Machine Learning',
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _learningTechSourceController,
                    label: 'Source',
                    hint: 'e.g. YouTube, Udemy, Documentation',
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _learningTechUrlController,
                    label: 'URL (optional)',
                    hint: 'Link to course or resource',
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _learningTechTimeController,
                    label: 'Time spent (minutes)',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ],
              ),

              // Walking Section
              _buildSectionCard(
                title: 'Walking',
                icon: Icons.directions_walk,
                children: [
                  _buildCheckboxField(
                    title: 'Mark as completed',
                    value: _currentTask.walkingCompleted,
                    onChanged: (value) => _updateTaskField(
                      value,
                      (val) => _currentTask.copyWith(walkingCompleted: val),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _walkingStepsController,
                          label: 'Steps',
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _walkingTimeController,
                          label: 'Time (minutes)',
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Habit Control Section
              _buildSectionCard(
                title: 'Habit Control',
                icon: Icons.block,
                children: [
                  _buildTextField(
                    controller: _avoidHabitLabelController,
                    label: 'Habit to avoid',
                    hint: 'e.g. Social media, Smoking, etc.',
                  ),
                  const SizedBox(height: 8),
                  _buildCheckboxField(
                    title: 'Successfully avoided habit',
                    value: _currentTask.avoidHabitValue,
                    onChanged: (value) => _updateTaskField(
                      value,
                      (val) => _currentTask.copyWith(avoidHabitValue: val),
                    ),
                  ),
                  _buildCheckboxField(
                    title: 'Avoided sweets',
                    value: _currentTask.avoidSweetsValue,
                    onChanged: (value) => _updateTaskField(
                      value,
                      (val) => _currentTask.copyWith(avoidSweetsValue: val),
                    ),
                  ),
                ],
              ),

              // Work & Entertainment Section
              _buildSectionCard(
                title: 'Work & Entertainment',
                icon: Icons.work,
                children: [
                  _buildCheckboxField(
                    title: 'Productive work done today',
                    value: _currentTask.workDoneValue,
                    onChanged: (value) => _updateTaskField(
                      value,
                      (val) => _currentTask.copyWith(workDoneValue: val),
                    ),
                  ),
                  const Divider(),
                  _buildCheckboxField(
                    title: 'Watched movie/series',
                    value: _currentTask.movieSeriesCompleted,
                    onChanged: (value) => _updateTaskField(
                      value,
                      (val) => _currentTask.copyWith(movieSeriesCompleted: val),
                    ),
                  ),
                  _buildTextField(
                    controller: _movieSeriesNameController,
                    label: 'Movie/Series name',
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _movieSeriesStartTimeController,
                          label: 'Start time',
                          hint: 'HH:MM',
                          suffix: IconButton(
                            icon: const Icon(Icons.access_time),
                            onPressed: () => _selectTime(_movieSeriesStartTimeController),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _movieSeriesEndTimeController,
                          label: 'End time',
                          hint: 'HH:MM',
                          suffix: IconButton(
                            icon: const Icon(Icons.access_time),
                            onPressed: () => _selectTime(_movieSeriesEndTimeController),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Notes Section
              _buildSectionCard(
                title: 'Notes',
                icon: Icons.notes,
                children: [
                  _buildTextField(
                    controller: _notesController,
                    label: 'Additional notes',
                    hint: 'Any additional thoughts or observations...',
                    maxLines: 3,
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
        floatingActionButton: _hasChanges
            ? FloatingActionButton.extended(
                onPressed: _isLoading ? null : _saveTask,
                icon: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: const Text('Save'),
              )
            : null,
      ),
    );
  }
}