import 'daily_entry.dart';
import 'task_entry.dart';

extension DailyEntryTaskExtensions on DailyEntry {
  // Helper method to get task entries (you'll need to pass this from the screen)
  List<TaskEntry> _getTaskEntries() {
    // This should be passed from the calling context
    // For now, return empty list to avoid compilation errors
    return [];
  }

  // Task completion count
  int get completedTasksCount {
    return _getTaskEntries().where((entry) => entry.completed).length;
  }

  // Reading Book properties
  bool get isReadingBookEffectivelyCompleted {
    final entry = _getTaskEntries().firstWhere(
      (e) => e.getStringValue('type') == 'reading_book',
      orElse: () => TaskEntry(
        id: '',
        dailyEntryId: id,
        taskId: '',
        data: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return entry.completed;
  }

  bool get readingBookCompleted {
    return isReadingBookEffectivelyCompleted;
  }

  int? get readingBookPages {
    final entry = _getTaskEntries().firstWhere(
      (e) => e.getStringValue('type') == 'reading_book',
      orElse: () => TaskEntry(
        id: '',
        dailyEntryId: id,
        taskId: '',
        data: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return entry.getIntValue('pages');
  }

  int? get readingBookTime {
    final entry = _getTaskEntries().firstWhere(
      (e) => e.getStringValue('type') == 'reading_book',
      orElse: () => TaskEntry(
        id: '',
        dailyEntryId: id,
        taskId: '',
        data: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return entry.getIntValue('time');
  }

  // Stretch properties
  bool get isStretchEffectivelyCompleted {
    final entry = _getTaskEntries().firstWhere(
      (e) => e.getStringValue('type') == 'stretch',
      orElse: () => TaskEntry(
        id: '',
        dailyEntryId: id,
        taskId: '',
        data: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return entry.completed;
  }

  bool get stretchCompleted {
    return isStretchEffectivelyCompleted;
  }

  String? get stretchType {
    final entry = _getTaskEntries().firstWhere(
      (e) => e.getStringValue('type') == 'stretch',
      orElse: () => TaskEntry(
        id: '',
        dailyEntryId: id,
        taskId: '',
        data: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return entry.getStringValue('stretch_type');
  }

  int? get stretchMinutes {
    final entry = _getTaskEntries().firstWhere(
      (e) => e.getStringValue('type') == 'stretch',
      orElse: () => TaskEntry(
        id: '',
        dailyEntryId: id,
        taskId: '',
        data: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return entry.getIntValue('minutes');
  }

  // Meditation properties
  bool get isMeditationEffectivelyCompleted {
    final entry = _getTaskEntries().firstWhere(
      (e) => e.getStringValue('type') == 'meditation',
      orElse: () => TaskEntry(
        id: '',
        dailyEntryId: id,
        taskId: '',
        data: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return entry.completed;
  }

  bool get meditationCompleted {
    return isMeditationEffectivelyCompleted;
  }

  int? get meditationMinutes {
    final entry = _getTaskEntries().firstWhere(
      (e) => e.getStringValue('type') == 'meditation',
      orElse: () => TaskEntry(
        id: '',
        dailyEntryId: id,
        taskId: '',
        data: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return entry.getIntValue('minutes');
  }

  // Reading Docs properties
  bool get isReadingDocsEffectivelyCompleted {
    final entry = _getTaskEntries().firstWhere(
      (e) => e.getStringValue('type') == 'reading_docs',
      orElse: () => TaskEntry(
        id: '',
        dailyEntryId: id,
        taskId: '',
        data: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return entry.completed;
  }

  bool get readingDocsCompleted {
    return isReadingDocsEffectivelyCompleted;
  }

  int? get readingDocsPages {
    final entry = _getTaskEntries().firstWhere(
      (e) => e.getStringValue('type') == 'reading_docs',
      orElse: () => TaskEntry(
        id: '',
        dailyEntryId: id,
        taskId: '',
        data: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return entry.getIntValue('pages');
  }

  int? get readingDocsTime {
    final entry = _getTaskEntries().firstWhere(
      (e) => e.getStringValue('type') == 'reading_docs',
      orElse: () => TaskEntry(
        id: '',
        dailyEntryId: id,
        taskId: '',
        data: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return entry.getIntValue('time');
  }

  // Learning Tech properties
  bool get isLearningTechEffectivelyCompleted {
    final entry = _getTaskEntries().firstWhere(
      (e) => e.getStringValue('type') == 'learning_tech',
      orElse: () => TaskEntry(
        id: '',
        dailyEntryId: id,
        taskId: '',
        data: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return entry.completed;
  }

  bool get learningTechCompleted {
    return isLearningTechEffectivelyCompleted;
  }

  String? get learningTechName {
    final entry = _getTaskEntries().firstWhere(
      (e) => e.getStringValue('type') == 'learning_tech',
      orElse: () => TaskEntry(
        id: '',
        dailyEntryId: id,
        taskId: '',
        data: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return entry.getStringValue('name');
  }

  int? get learningTechTime {
    final entry = _getTaskEntries().firstWhere(
      (e) => e.getStringValue('type') == 'learning_tech',
      orElse: () => TaskEntry(
        id: '',
        dailyEntryId: id,
        taskId: '',
        data: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return entry.getIntValue('time');
  }

  // Walking properties
  bool get isWalkingEffectivelyCompleted {
    final entry = _getTaskEntries().firstWhere(
      (e) => e.getStringValue('type') == 'walking',
      orElse: () => TaskEntry(
        id: '',
        dailyEntryId: id,
        taskId: '',
        data: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return entry.completed;
  }

  bool get walkingCompleted {
    return isWalkingEffectivelyCompleted;
  }

  int? get walkingSteps {
    final entry = _getTaskEntries().firstWhere(
      (e) => e.getStringValue('type') == 'walking',
      orElse: () => TaskEntry(
        id: '',
        dailyEntryId: id,
        taskId: '',
        data: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return entry.getIntValue('steps');
  }

  int? get walkingTime {
    final entry = _getTaskEntries().firstWhere(
      (e) => e.getStringValue('type') == 'walking',
      orElse: () => TaskEntry(
        id: '',
        dailyEntryId: id,
        taskId: '',
        data: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return entry.getIntValue('time');
  }

  // Habit properties
  bool get avoidHabitValue {
    final entry = _getTaskEntries().firstWhere(
      (e) => e.getStringValue('type') == 'avoid_habit',
      orElse: () => TaskEntry(
        id: '',
        dailyEntryId: id,
        taskId: '',
        data: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return entry.completed;
  }

  String? get avoidHabitLabel {
    final entry = _getTaskEntries().firstWhere(
      (e) => e.getStringValue('type') == 'avoid_habit',
      orElse: () => TaskEntry(
        id: '',
        dailyEntryId: id,
        taskId: '',
        data: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return entry.getStringValue('label');
  }

  bool get avoidSweetsValue {
    final entry = _getTaskEntries().firstWhere(
      (e) => e.getStringValue('type') == 'avoid_sweets',
      orElse: () => TaskEntry(
        id: '',
        dailyEntryId: id,
        taskId: '',
        data: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return entry.completed;
  }

  bool get workDoneValue {
    final entry = _getTaskEntries().firstWhere(
      (e) => e.getStringValue('type') == 'work_done',
      orElse: () => TaskEntry(
        id: '',
        dailyEntryId: id,
        taskId: '',
        data: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return entry.completed;
  }

  // Movie/Series properties
  bool get isMovieSeriesEffectivelyCompleted {
    final entry = _getTaskEntries().firstWhere(
      (e) => e.getStringValue('type') == 'movie_series',
      orElse: () => TaskEntry(
        id: '',
        dailyEntryId: id,
        taskId: '',
        data: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return entry.completed;
  }

  bool get movieSeriesCompleted {
    return isMovieSeriesEffectivelyCompleted;
  }

  String? get movieSeriesName {
    final entry = _getTaskEntries().firstWhere(
      (e) => e.getStringValue('type') == 'movie_series',
      orElse: () => TaskEntry(
        id: '',
        dailyEntryId: id,
        taskId: '',
        data: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return entry.getStringValue('name');
  }

  int? get movieSeriesDuration {
    final entry = _getTaskEntries().firstWhere(
      (e) => e.getStringValue('type') == 'movie_series',
      orElse: () => TaskEntry(
        id: '',
        dailyEntryId: id,
        taskId: '',
        data: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return entry.getIntValue('duration');
  }
}