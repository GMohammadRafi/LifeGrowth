class DailyTask {
  final String? id;
  final String? userId;
  final DateTime date;
  
  // Reading Book fields
  final int? readingBookPages;
  final int? readingBookTime;
  final bool readingBookCompleted;
  
  // Stretch fields
  final String? stretchType; // 'Yoga' or 'Home Workout'
  final int? stretchMinutes;
  final bool stretchCompleted;
  
  // Meditation fields
  final int? meditationMinutes;
  final bool meditationCompleted;
  
  // Reading Docs fields
  final String? readingDocsNameLink;
  final int? readingDocsPages;
  final int? readingDocsTime;
  final bool readingDocsCompleted;
  
  // Learning Technology fields
  final String? learningTechName;
  final String? learningTechSource;
  final String? learningTechUrl;
  final int? learningTechTime;
  final bool learningTechCompleted;
  
  // Walking fields
  final int? walkingSteps;
  final int? walkingTime;
  final bool walkingCompleted;
  
  // Avoid Habit fields
  final String? avoidHabitLabel;
  final bool avoidHabitValue;
  
  // Avoid Sweets field
  final bool avoidSweetsValue;
  
  // Work Done field
  final bool workDoneValue;
  
  // Movie/Series fields
  final String? movieSeriesName;
  final String? movieSeriesStartTime; // HH:MM format
  final String? movieSeriesEndTime; // HH:MM format
  final int? movieSeriesDuration; // minutes
  final bool movieSeriesCompleted;
  
  // General fields
  final String? notes;
  final int timezoneOffset; // minutes from UTC
  
  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? clientUpdatedAt;
  final DateTime? deletedAt;
  
  // Schema versioning
  final int schemaVersion;
  
  const DailyTask({
    this.id,
    this.userId,
    required this.date,
    this.readingBookPages,
    this.readingBookTime,
    this.readingBookCompleted = false,
    this.stretchType,
    this.stretchMinutes,
    this.stretchCompleted = false,
    this.meditationMinutes,
    this.meditationCompleted = false,
    this.readingDocsNameLink,
    this.readingDocsPages,
    this.readingDocsTime,
    this.readingDocsCompleted = false,
    this.learningTechName,
    this.learningTechSource,
    this.learningTechUrl,
    this.learningTechTime,
    this.learningTechCompleted = false,
    this.walkingSteps,
    this.walkingTime,
    this.walkingCompleted = false,
    this.avoidHabitLabel,
    this.avoidHabitValue = false,
    this.avoidSweetsValue = false,
    this.workDoneValue = false,
    this.movieSeriesName,
    this.movieSeriesStartTime,
    this.movieSeriesEndTime,
    this.movieSeriesDuration,
    this.movieSeriesCompleted = false,
    this.notes,
    required this.timezoneOffset,
    this.createdAt,
    this.updatedAt,
    this.clientUpdatedAt,
    this.deletedAt,
    this.schemaVersion = 1,
  });
  
  // Helper methods to check if tasks are effectively completed
  bool get isReadingBookEffectivelyCompleted => 
      readingBookCompleted || (readingBookPages != null && readingBookPages! > 0) || (readingBookTime != null && readingBookTime! > 0);
  
  bool get isStretchEffectivelyCompleted => 
      stretchCompleted || (stretchMinutes != null && stretchMinutes! > 0);
  
  bool get isMeditationEffectivelyCompleted => 
      meditationCompleted || (meditationMinutes != null && meditationMinutes! > 0);
  
  bool get isReadingDocsEffectivelyCompleted => 
      readingDocsCompleted || (readingDocsPages != null && readingDocsPages! > 0) || (readingDocsTime != null && readingDocsTime! > 0);
  
  bool get isLearningTechEffectivelyCompleted => 
      learningTechCompleted || (learningTechTime != null && learningTechTime! > 0);
  
  bool get isWalkingEffectivelyCompleted => 
      walkingCompleted || (walkingSteps != null && walkingSteps! > 0) || (walkingTime != null && walkingTime! > 0);
  
  bool get isMovieSeriesEffectivelyCompleted => 
      movieSeriesCompleted || (movieSeriesDuration != null && movieSeriesDuration! > 0);
  
  // Get count of completed tasks for overall streak calculation
  int get completedTasksCount {
    int count = 0;
    if (isReadingBookEffectivelyCompleted) count++;
    if (isStretchEffectivelyCompleted) count++;
    if (isMeditationEffectivelyCompleted) count++;
    if (isReadingDocsEffectivelyCompleted) count++;
    if (isLearningTechEffectivelyCompleted) count++;
    if (isWalkingEffectivelyCompleted) count++;
    if (avoidHabitValue) count++;
    if (avoidSweetsValue) count++;
    if (workDoneValue) count++;
    if (isMovieSeriesEffectivelyCompleted) count++;
    return count;
  }
  
  // Check if at least one task is completed (for overall streak)
  bool get hasAnyTaskCompleted => completedTasksCount > 0;
  
  // Copy with method for immutable updates
  DailyTask copyWith({
    String? id,
    String? userId,
    DateTime? date,
    int? readingBookPages,
    int? readingBookTime,
    bool? readingBookCompleted,
    String? stretchType,
    int? stretchMinutes,
    bool? stretchCompleted,
    int? meditationMinutes,
    bool? meditationCompleted,
    String? readingDocsNameLink,
    int? readingDocsPages,
    int? readingDocsTime,
    bool? readingDocsCompleted,
    String? learningTechName,
    String? learningTechSource,
    String? learningTechUrl,
    int? learningTechTime,
    bool? learningTechCompleted,
    int? walkingSteps,
    int? walkingTime,
    bool? walkingCompleted,
    String? avoidHabitLabel,
    bool? avoidHabitValue,
    bool? avoidSweetsValue,
    bool? workDoneValue,
    String? movieSeriesName,
    String? movieSeriesStartTime,
    String? movieSeriesEndTime,
    int? movieSeriesDuration,
    bool? movieSeriesCompleted,
    String? notes,
    int? timezoneOffset,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? clientUpdatedAt,
    DateTime? deletedAt,
    int? schemaVersion,
  }) {
    return DailyTask(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      readingBookPages: readingBookPages ?? this.readingBookPages,
      readingBookTime: readingBookTime ?? this.readingBookTime,
      readingBookCompleted: readingBookCompleted ?? this.readingBookCompleted,
      stretchType: stretchType ?? this.stretchType,
      stretchMinutes: stretchMinutes ?? this.stretchMinutes,
      stretchCompleted: stretchCompleted ?? this.stretchCompleted,
      meditationMinutes: meditationMinutes ?? this.meditationMinutes,
      meditationCompleted: meditationCompleted ?? this.meditationCompleted,
      readingDocsNameLink: readingDocsNameLink ?? this.readingDocsNameLink,
      readingDocsPages: readingDocsPages ?? this.readingDocsPages,
      readingDocsTime: readingDocsTime ?? this.readingDocsTime,
      readingDocsCompleted: readingDocsCompleted ?? this.readingDocsCompleted,
      learningTechName: learningTechName ?? this.learningTechName,
      learningTechSource: learningTechSource ?? this.learningTechSource,
      learningTechUrl: learningTechUrl ?? this.learningTechUrl,
      learningTechTime: learningTechTime ?? this.learningTechTime,
      learningTechCompleted: learningTechCompleted ?? this.learningTechCompleted,
      walkingSteps: walkingSteps ?? this.walkingSteps,
      walkingTime: walkingTime ?? this.walkingTime,
      walkingCompleted: walkingCompleted ?? this.walkingCompleted,
      avoidHabitLabel: avoidHabitLabel ?? this.avoidHabitLabel,
      avoidHabitValue: avoidHabitValue ?? this.avoidHabitValue,
      avoidSweetsValue: avoidSweetsValue ?? this.avoidSweetsValue,
      workDoneValue: workDoneValue ?? this.workDoneValue,
      movieSeriesName: movieSeriesName ?? this.movieSeriesName,
      movieSeriesStartTime: movieSeriesStartTime ?? this.movieSeriesStartTime,
      movieSeriesEndTime: movieSeriesEndTime ?? this.movieSeriesEndTime,
      movieSeriesDuration: movieSeriesDuration ?? this.movieSeriesDuration,
      movieSeriesCompleted: movieSeriesCompleted ?? this.movieSeriesCompleted,
      notes: notes ?? this.notes,
      timezoneOffset: timezoneOffset ?? this.timezoneOffset,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      clientUpdatedAt: clientUpdatedAt ?? this.clientUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      schemaVersion: schemaVersion ?? this.schemaVersion,
    );
  }
  
  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      if (readingBookPages != null) 'reading_book_pages': readingBookPages,
      if (readingBookTime != null) 'reading_book_time': readingBookTime,
      'reading_book_completed': readingBookCompleted,
      if (stretchType != null) 'stretch_type': stretchType,
      if (stretchMinutes != null) 'stretch_minutes': stretchMinutes,
      'stretch_completed': stretchCompleted,
      if (meditationMinutes != null) 'meditation_minutes': meditationMinutes,
      'meditation_completed': meditationCompleted,
      if (readingDocsNameLink != null) 'reading_docs_name_link': readingDocsNameLink,
      if (readingDocsPages != null) 'reading_docs_pages': readingDocsPages,
      if (readingDocsTime != null) 'reading_docs_time': readingDocsTime,
      'reading_docs_completed': readingDocsCompleted,
      if (learningTechName != null) 'learning_tech_name': learningTechName,
      if (learningTechSource != null) 'learning_tech_source': learningTechSource,
      if (learningTechUrl != null) 'learning_tech_url': learningTechUrl,
      if (learningTechTime != null) 'learning_tech_time': learningTechTime,
      'learning_tech_completed': learningTechCompleted,
      if (walkingSteps != null) 'walking_steps': walkingSteps,
      if (walkingTime != null) 'walking_time': walkingTime,
      'walking_completed': walkingCompleted,
      if (avoidHabitLabel != null) 'avoid_habit_label': avoidHabitLabel,
      'avoid_habit_value': avoidHabitValue,
      'avoid_sweets_value': avoidSweetsValue,
      'work_done_value': workDoneValue,
      if (movieSeriesName != null) 'movie_series_name': movieSeriesName,
      if (movieSeriesStartTime != null) 'movie_series_start_time': movieSeriesStartTime,
      if (movieSeriesEndTime != null) 'movie_series_end_time': movieSeriesEndTime,
      if (movieSeriesDuration != null) 'movie_series_duration': movieSeriesDuration,
      'movie_series_completed': movieSeriesCompleted,
      if (notes != null) 'notes': notes,
      'timezone_offset': timezoneOffset,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (clientUpdatedAt != null) 'client_updated_at': clientUpdatedAt!.toIso8601String(),
      if (deletedAt != null) 'deleted_at': deletedAt!.toIso8601String(),
      'schema_version': schemaVersion,
    };
  }
  
  // JSON deserialization
  factory DailyTask.fromJson(Map<String, dynamic> json) {
    return DailyTask(
      id: json['id'],
      userId: json['user_id'],
      date: DateTime.parse(json['date']),
      readingBookPages: json['reading_book_pages'],
      readingBookTime: json['reading_book_time'],
      readingBookCompleted: json['reading_book_completed'] ?? false,
      stretchType: json['stretch_type'],
      stretchMinutes: json['stretch_minutes'],
      stretchCompleted: json['stretch_completed'] ?? false,
      meditationMinutes: json['meditation_minutes'],
      meditationCompleted: json['meditation_completed'] ?? false,
      readingDocsNameLink: json['reading_docs_name_link'],
      readingDocsPages: json['reading_docs_pages'],
      readingDocsTime: json['reading_docs_time'],
      readingDocsCompleted: json['reading_docs_completed'] ?? false,
      learningTechName: json['learning_tech_name'],
      learningTechSource: json['learning_tech_source'],
      learningTechUrl: json['learning_tech_url'],
      learningTechTime: json['learning_tech_time'],
      learningTechCompleted: json['learning_tech_completed'] ?? false,
      walkingSteps: json['walking_steps'],
      walkingTime: json['walking_time'],
      walkingCompleted: json['walking_completed'] ?? false,
      avoidHabitLabel: json['avoid_habit_label'],
      avoidHabitValue: json['avoid_habit_value'] ?? false,
      avoidSweetsValue: json['avoid_sweets_value'] ?? false,
      workDoneValue: json['work_done_value'] ?? false,
      movieSeriesName: json['movie_series_name'],
      movieSeriesStartTime: json['movie_series_start_time'],
      movieSeriesEndTime: json['movie_series_end_time'],
      movieSeriesDuration: json['movie_series_duration'],
      movieSeriesCompleted: json['movie_series_completed'] ?? false,
      notes: json['notes'],
      timezoneOffset: json['timezone_offset'] ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      clientUpdatedAt: json['client_updated_at'] != null ? DateTime.parse(json['client_updated_at']) : null,
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
      schemaVersion: json['schema_version'] ?? 1,
    );
  }
  
  // Create empty task for today
  factory DailyTask.empty({required DateTime date, int? timezoneOffset}) {
    return DailyTask(
      date: date,
      timezoneOffset: timezoneOffset ?? DateTime.now().timeZoneOffset.inMinutes,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyTask &&
        other.id == id &&
        other.userId == userId &&
        other.date == date;
  }
  
  @override
  int get hashCode => Object.hash(id, userId, date);
  
  @override
  String toString() {
    return 'DailyTask(id: $id, userId: $userId, date: $date, completedTasks: $completedTasksCount)';
  }
}