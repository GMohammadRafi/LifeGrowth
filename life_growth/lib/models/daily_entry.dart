class DailyEntry {
  final String id;
  final String userId;
  final DateTime date;
  final String? notes;
  final int timezoneOffset;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? clientUpdatedAt;
  final DateTime? deletedAt;
  final int schemaVersion;
  
  // Task-related properties
  final bool readingBookCompleted;
  final int? readingBookPages;
  final int? readingBookTime;
  final bool stretchCompleted;
  final String? stretchType;
  final int? stretchMinutes;
  final bool meditationCompleted;
  final int? meditationMinutes;
  final bool readingDocsCompleted;
  final int? readingDocsPages;
  final int? readingDocsTime;
  final bool learningTechCompleted;
  final String? learningTechName;
  final int? learningTechTime;
  final bool walkingCompleted;
  final int? walkingSteps;
  final int? walkingTime;
  final bool avoidHabitValue;
  final String? avoidHabitLabel;
  final bool avoidSweetsValue;
  final bool workDoneValue;
  final bool movieSeriesCompleted;
  final String? movieSeriesName;
  final int? movieSeriesDuration;

  const DailyEntry({
    required this.id,
    required this.userId,
    required this.date,
    this.notes,
    required this.timezoneOffset,
    required this.createdAt,
    required this.updatedAt,
    this.clientUpdatedAt,
    this.deletedAt,
    this.schemaVersion = 2,
    // Task-related properties with defaults
    this.readingBookCompleted = false,
    this.readingBookPages,
    this.readingBookTime,
    this.stretchCompleted = false,
    this.stretchType,
    this.stretchMinutes,
    this.meditationCompleted = false,
    this.meditationMinutes,
    this.readingDocsCompleted = false,
    this.readingDocsPages,
    this.readingDocsTime,
    this.learningTechCompleted = false,
    this.learningTechName,
    this.learningTechTime,
    this.walkingCompleted = false,
    this.walkingSteps,
    this.walkingTime,
    this.avoidHabitValue = false,
    this.avoidHabitLabel,
    this.avoidSweetsValue = false,
    this.workDoneValue = false,
    this.movieSeriesCompleted = false,
    this.movieSeriesName,
    this.movieSeriesDuration,
  });

  factory DailyEntry.fromJson(Map<String, dynamic> json) {
    return DailyEntry(
      id: json['id'],
      userId: json['user_id'],
      date: DateTime.parse(json['date']),
      notes: json['notes'],
      timezoneOffset: json['timezone_offset'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      clientUpdatedAt: json['client_updated_at'] != null ? DateTime.parse(json['client_updated_at']) : null,
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
      schemaVersion: json['schema_version'] ?? 2,
      // Task-related properties from JSON
      readingBookCompleted: json['reading_book_completed'] ?? false,
      readingBookPages: json['reading_book_pages'],
      readingBookTime: json['reading_book_time'],
      stretchCompleted: json['stretch_completed'] ?? false,
      stretchType: json['stretch_type'],
      stretchMinutes: json['stretch_minutes'],
      meditationCompleted: json['meditation_completed'] ?? false,
      meditationMinutes: json['meditation_minutes'],
      readingDocsCompleted: json['reading_docs_completed'] ?? false,
      readingDocsPages: json['reading_docs_pages'],
      readingDocsTime: json['reading_docs_time'],
      learningTechCompleted: json['learning_tech_completed'] ?? false,
      learningTechName: json['learning_tech_name'],
      learningTechTime: json['learning_tech_time'],
      walkingCompleted: json['walking_completed'] ?? false,
      walkingSteps: json['walking_steps'],
      walkingTime: json['walking_time'],
      avoidHabitValue: json['avoid_habit_value'] ?? false,
      avoidHabitLabel: json['avoid_habit_label'],
      avoidSweetsValue: json['avoid_sweets_value'] ?? false,
      workDoneValue: json['work_done_value'] ?? false,
      movieSeriesCompleted: json['movie_series_completed'] ?? false,
      movieSeriesName: json['movie_series_name'],
      movieSeriesDuration: json['movie_series_duration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      if (notes != null) 'notes': notes,
      'timezone_offset': timezoneOffset,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (clientUpdatedAt != null) 'client_updated_at': clientUpdatedAt!.toIso8601String(),
      if (deletedAt != null) 'deleted_at': deletedAt!.toIso8601String(),
      'schema_version': schemaVersion,
      // Task-related properties
      'reading_book_completed': readingBookCompleted,
      if (readingBookPages != null) 'reading_book_pages': readingBookPages,
      if (readingBookTime != null) 'reading_book_time': readingBookTime,
      'stretch_completed': stretchCompleted,
      if (stretchType != null) 'stretch_type': stretchType,
      if (stretchMinutes != null) 'stretch_minutes': stretchMinutes,
      'meditation_completed': meditationCompleted,
      if (meditationMinutes != null) 'meditation_minutes': meditationMinutes,
      'reading_docs_completed': readingDocsCompleted,
      if (readingDocsPages != null) 'reading_docs_pages': readingDocsPages,
      if (readingDocsTime != null) 'reading_docs_time': readingDocsTime,
      'learning_tech_completed': learningTechCompleted,
      if (learningTechName != null) 'learning_tech_name': learningTechName,
      if (learningTechTime != null) 'learning_tech_time': learningTechTime,
      'walking_completed': walkingCompleted,
      if (walkingSteps != null) 'walking_steps': walkingSteps,
      if (walkingTime != null) 'walking_time': walkingTime,
      'avoid_habit_value': avoidHabitValue,
      if (avoidHabitLabel != null) 'avoid_habit_label': avoidHabitLabel,
      'avoid_sweets_value': avoidSweetsValue,
      'work_done_value': workDoneValue,
      'movie_series_completed': movieSeriesCompleted,
      if (movieSeriesName != null) 'movie_series_name': movieSeriesName,
      if (movieSeriesDuration != null) 'movie_series_duration': movieSeriesDuration,
    };
  }

  DailyEntry copyWith({
    String? id,
    String? userId,
    DateTime? date,
    String? notes,
    int? timezoneOffset,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? clientUpdatedAt,
    DateTime? deletedAt,
    int? schemaVersion,
    // Task-related parameters
    bool? readingBookCompleted,
    int? readingBookPages,
    int? readingBookTime,
    bool? stretchCompleted,
    String? stretchType,
    int? stretchMinutes,
    bool? meditationCompleted,
    int? meditationMinutes,
    bool? readingDocsCompleted,
    int? readingDocsPages,
    int? readingDocsTime,
    bool? learningTechCompleted,
    String? learningTechName,
    int? learningTechTime,
    bool? walkingCompleted,
    int? walkingSteps,
    int? walkingTime,
    bool? avoidHabitValue,
    String? avoidHabitLabel,
    bool? avoidSweetsValue,
    bool? workDoneValue,
    bool? movieSeriesCompleted,
    String? movieSeriesName,
    int? movieSeriesDuration,
  }) {
    return DailyEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      timezoneOffset: timezoneOffset ?? this.timezoneOffset,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      clientUpdatedAt: clientUpdatedAt ?? this.clientUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      // Task-related properties
      readingBookCompleted: readingBookCompleted ?? this.readingBookCompleted,
      readingBookPages: readingBookPages ?? this.readingBookPages,
      readingBookTime: readingBookTime ?? this.readingBookTime,
      stretchCompleted: stretchCompleted ?? this.stretchCompleted,
      stretchType: stretchType ?? this.stretchType,
      stretchMinutes: stretchMinutes ?? this.stretchMinutes,
      meditationCompleted: meditationCompleted ?? this.meditationCompleted,
      meditationMinutes: meditationMinutes ?? this.meditationMinutes,
      readingDocsCompleted: readingDocsCompleted ?? this.readingDocsCompleted,
      readingDocsPages: readingDocsPages ?? this.readingDocsPages,
      readingDocsTime: readingDocsTime ?? this.readingDocsTime,
      learningTechCompleted: learningTechCompleted ?? this.learningTechCompleted,
      learningTechName: learningTechName ?? this.learningTechName,
      learningTechTime: learningTechTime ?? this.learningTechTime,
      walkingCompleted: walkingCompleted ?? this.walkingCompleted,
      walkingSteps: walkingSteps ?? this.walkingSteps,
      walkingTime: walkingTime ?? this.walkingTime,
      avoidHabitValue: avoidHabitValue ?? this.avoidHabitValue,
      avoidHabitLabel: avoidHabitLabel ?? this.avoidHabitLabel,
      avoidSweetsValue: avoidSweetsValue ?? this.avoidSweetsValue,
      workDoneValue: workDoneValue ?? this.workDoneValue,
      movieSeriesCompleted: movieSeriesCompleted ?? this.movieSeriesCompleted,
      movieSeriesName: movieSeriesName ?? this.movieSeriesName,
      movieSeriesDuration: movieSeriesDuration ?? this.movieSeriesDuration,
    );
  }

  factory DailyEntry.empty({required DateTime date, int? timezoneOffset}) {
    final now = DateTime.now();
    return DailyEntry(
      id: '', // Will be generated by database
      userId: '', // Will be set by trigger
      date: date,
      timezoneOffset: timezoneOffset ?? now.timeZoneOffset.inMinutes,
      createdAt: now,
      updatedAt: now,
    );
  }
}