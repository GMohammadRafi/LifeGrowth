// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $DailyTasksTable extends DailyTasks
    with TableInfo<$DailyTasksTable, DailyTask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _readingBookCompletedMeta =
      const VerificationMeta('readingBookCompleted');
  @override
  late final GeneratedColumn<bool> readingBookCompleted = GeneratedColumn<bool>(
      'reading_book_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("reading_book_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _readingBookPagesMeta =
      const VerificationMeta('readingBookPages');
  @override
  late final GeneratedColumn<int> readingBookPages = GeneratedColumn<int>(
      'reading_book_pages', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _readingBookTimeMeta =
      const VerificationMeta('readingBookTime');
  @override
  late final GeneratedColumn<int> readingBookTime = GeneratedColumn<int>(
      'reading_book_time', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _stretchCompletedMeta =
      const VerificationMeta('stretchCompleted');
  @override
  late final GeneratedColumn<bool> stretchCompleted = GeneratedColumn<bool>(
      'stretch_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("stretch_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _stretchMinutesMeta =
      const VerificationMeta('stretchMinutes');
  @override
  late final GeneratedColumn<int> stretchMinutes = GeneratedColumn<int>(
      'stretch_minutes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _stretchTypeMeta =
      const VerificationMeta('stretchType');
  @override
  late final GeneratedColumn<String> stretchType = GeneratedColumn<String>(
      'stretch_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _meditationCompletedMeta =
      const VerificationMeta('meditationCompleted');
  @override
  late final GeneratedColumn<bool> meditationCompleted = GeneratedColumn<bool>(
      'meditation_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("meditation_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _meditationMinutesMeta =
      const VerificationMeta('meditationMinutes');
  @override
  late final GeneratedColumn<int> meditationMinutes = GeneratedColumn<int>(
      'meditation_minutes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _readingDocsCompletedMeta =
      const VerificationMeta('readingDocsCompleted');
  @override
  late final GeneratedColumn<bool> readingDocsCompleted = GeneratedColumn<bool>(
      'reading_docs_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("reading_docs_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _readingDocsPagesMeta =
      const VerificationMeta('readingDocsPages');
  @override
  late final GeneratedColumn<int> readingDocsPages = GeneratedColumn<int>(
      'reading_docs_pages', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _readingDocsTimeMeta =
      const VerificationMeta('readingDocsTime');
  @override
  late final GeneratedColumn<int> readingDocsTime = GeneratedColumn<int>(
      'reading_docs_time', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _readingDocsNameLinkMeta =
      const VerificationMeta('readingDocsNameLink');
  @override
  late final GeneratedColumn<String> readingDocsNameLink =
      GeneratedColumn<String>('reading_docs_name_link', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _learningTechCompletedMeta =
      const VerificationMeta('learningTechCompleted');
  @override
  late final GeneratedColumn<bool> learningTechCompleted =
      GeneratedColumn<bool>('learning_tech_completed', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("learning_tech_completed" IN (0, 1))'),
          defaultValue: const Constant(false));
  static const VerificationMeta _learningTechNameMeta =
      const VerificationMeta('learningTechName');
  @override
  late final GeneratedColumn<String> learningTechName = GeneratedColumn<String>(
      'learning_tech_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _learningTechTimeMeta =
      const VerificationMeta('learningTechTime');
  @override
  late final GeneratedColumn<int> learningTechTime = GeneratedColumn<int>(
      'learning_tech_time', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _learningTechSourceMeta =
      const VerificationMeta('learningTechSource');
  @override
  late final GeneratedColumn<String> learningTechSource =
      GeneratedColumn<String>('learning_tech_source', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _learningTechUrlMeta =
      const VerificationMeta('learningTechUrl');
  @override
  late final GeneratedColumn<String> learningTechUrl = GeneratedColumn<String>(
      'learning_tech_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _walkingCompletedMeta =
      const VerificationMeta('walkingCompleted');
  @override
  late final GeneratedColumn<bool> walkingCompleted = GeneratedColumn<bool>(
      'walking_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("walking_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _walkingStepsMeta =
      const VerificationMeta('walkingSteps');
  @override
  late final GeneratedColumn<int> walkingSteps = GeneratedColumn<int>(
      'walking_steps', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _walkingTimeMeta =
      const VerificationMeta('walkingTime');
  @override
  late final GeneratedColumn<int> walkingTime = GeneratedColumn<int>(
      'walking_time', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _avoidHabitLabelMeta =
      const VerificationMeta('avoidHabitLabel');
  @override
  late final GeneratedColumn<String> avoidHabitLabel = GeneratedColumn<String>(
      'avoid_habit_label', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _avoidHabitValueMeta =
      const VerificationMeta('avoidHabitValue');
  @override
  late final GeneratedColumn<bool> avoidHabitValue = GeneratedColumn<bool>(
      'avoid_habit_value', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("avoid_habit_value" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _avoidSweetsValueMeta =
      const VerificationMeta('avoidSweetsValue');
  @override
  late final GeneratedColumn<bool> avoidSweetsValue = GeneratedColumn<bool>(
      'avoid_sweets_value', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("avoid_sweets_value" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _workDoneValueMeta =
      const VerificationMeta('workDoneValue');
  @override
  late final GeneratedColumn<bool> workDoneValue = GeneratedColumn<bool>(
      'work_done_value', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("work_done_value" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _movieSeriesCompletedMeta =
      const VerificationMeta('movieSeriesCompleted');
  @override
  late final GeneratedColumn<bool> movieSeriesCompleted = GeneratedColumn<bool>(
      'movie_series_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("movie_series_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _movieSeriesNameMeta =
      const VerificationMeta('movieSeriesName');
  @override
  late final GeneratedColumn<String> movieSeriesName = GeneratedColumn<String>(
      'movie_series_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _movieSeriesDurationMeta =
      const VerificationMeta('movieSeriesDuration');
  @override
  late final GeneratedColumn<int> movieSeriesDuration = GeneratedColumn<int>(
      'movie_series_duration', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _movieSeriesStartTimeMeta =
      const VerificationMeta('movieSeriesStartTime');
  @override
  late final GeneratedColumn<String> movieSeriesStartTime =
      GeneratedColumn<String>('movie_series_start_time', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _movieSeriesEndTimeMeta =
      const VerificationMeta('movieSeriesEndTime');
  @override
  late final GeneratedColumn<String> movieSeriesEndTime =
      GeneratedColumn<String>('movie_series_end_time', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _timezoneOffsetMeta =
      const VerificationMeta('timezoneOffset');
  @override
  late final GeneratedColumn<int> timezoneOffset = GeneratedColumn<int>(
      'timezone_offset', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _needsSyncMeta =
      const VerificationMeta('needsSync');
  @override
  late final GeneratedColumn<bool> needsSync = GeneratedColumn<bool>(
      'needs_sync', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("needs_sync" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _lastSyncAtMeta =
      const VerificationMeta('lastSyncAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncAt = GeneratedColumn<DateTime>(
      'last_sync_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        userId,
        date,
        readingBookCompleted,
        readingBookPages,
        readingBookTime,
        stretchCompleted,
        stretchMinutes,
        stretchType,
        meditationCompleted,
        meditationMinutes,
        readingDocsCompleted,
        readingDocsPages,
        readingDocsTime,
        readingDocsNameLink,
        learningTechCompleted,
        learningTechName,
        learningTechTime,
        learningTechSource,
        learningTechUrl,
        walkingCompleted,
        walkingSteps,
        walkingTime,
        avoidHabitLabel,
        avoidHabitValue,
        avoidSweetsValue,
        workDoneValue,
        movieSeriesCompleted,
        movieSeriesName,
        movieSeriesDuration,
        movieSeriesStartTime,
        movieSeriesEndTime,
        notes,
        createdAt,
        updatedAt,
        deletedAt,
        timezoneOffset,
        needsSync,
        lastSyncAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_tasks';
  @override
  VerificationContext validateIntegrity(Insertable<DailyTask> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('reading_book_completed')) {
      context.handle(
          _readingBookCompletedMeta,
          readingBookCompleted.isAcceptableOrUnknown(
              data['reading_book_completed']!, _readingBookCompletedMeta));
    }
    if (data.containsKey('reading_book_pages')) {
      context.handle(
          _readingBookPagesMeta,
          readingBookPages.isAcceptableOrUnknown(
              data['reading_book_pages']!, _readingBookPagesMeta));
    }
    if (data.containsKey('reading_book_time')) {
      context.handle(
          _readingBookTimeMeta,
          readingBookTime.isAcceptableOrUnknown(
              data['reading_book_time']!, _readingBookTimeMeta));
    }
    if (data.containsKey('stretch_completed')) {
      context.handle(
          _stretchCompletedMeta,
          stretchCompleted.isAcceptableOrUnknown(
              data['stretch_completed']!, _stretchCompletedMeta));
    }
    if (data.containsKey('stretch_minutes')) {
      context.handle(
          _stretchMinutesMeta,
          stretchMinutes.isAcceptableOrUnknown(
              data['stretch_minutes']!, _stretchMinutesMeta));
    }
    if (data.containsKey('stretch_type')) {
      context.handle(
          _stretchTypeMeta,
          stretchType.isAcceptableOrUnknown(
              data['stretch_type']!, _stretchTypeMeta));
    }
    if (data.containsKey('meditation_completed')) {
      context.handle(
          _meditationCompletedMeta,
          meditationCompleted.isAcceptableOrUnknown(
              data['meditation_completed']!, _meditationCompletedMeta));
    }
    if (data.containsKey('meditation_minutes')) {
      context.handle(
          _meditationMinutesMeta,
          meditationMinutes.isAcceptableOrUnknown(
              data['meditation_minutes']!, _meditationMinutesMeta));
    }
    if (data.containsKey('reading_docs_completed')) {
      context.handle(
          _readingDocsCompletedMeta,
          readingDocsCompleted.isAcceptableOrUnknown(
              data['reading_docs_completed']!, _readingDocsCompletedMeta));
    }
    if (data.containsKey('reading_docs_pages')) {
      context.handle(
          _readingDocsPagesMeta,
          readingDocsPages.isAcceptableOrUnknown(
              data['reading_docs_pages']!, _readingDocsPagesMeta));
    }
    if (data.containsKey('reading_docs_time')) {
      context.handle(
          _readingDocsTimeMeta,
          readingDocsTime.isAcceptableOrUnknown(
              data['reading_docs_time']!, _readingDocsTimeMeta));
    }
    if (data.containsKey('reading_docs_name_link')) {
      context.handle(
          _readingDocsNameLinkMeta,
          readingDocsNameLink.isAcceptableOrUnknown(
              data['reading_docs_name_link']!, _readingDocsNameLinkMeta));
    }
    if (data.containsKey('learning_tech_completed')) {
      context.handle(
          _learningTechCompletedMeta,
          learningTechCompleted.isAcceptableOrUnknown(
              data['learning_tech_completed']!, _learningTechCompletedMeta));
    }
    if (data.containsKey('learning_tech_name')) {
      context.handle(
          _learningTechNameMeta,
          learningTechName.isAcceptableOrUnknown(
              data['learning_tech_name']!, _learningTechNameMeta));
    }
    if (data.containsKey('learning_tech_time')) {
      context.handle(
          _learningTechTimeMeta,
          learningTechTime.isAcceptableOrUnknown(
              data['learning_tech_time']!, _learningTechTimeMeta));
    }
    if (data.containsKey('learning_tech_source')) {
      context.handle(
          _learningTechSourceMeta,
          learningTechSource.isAcceptableOrUnknown(
              data['learning_tech_source']!, _learningTechSourceMeta));
    }
    if (data.containsKey('learning_tech_url')) {
      context.handle(
          _learningTechUrlMeta,
          learningTechUrl.isAcceptableOrUnknown(
              data['learning_tech_url']!, _learningTechUrlMeta));
    }
    if (data.containsKey('walking_completed')) {
      context.handle(
          _walkingCompletedMeta,
          walkingCompleted.isAcceptableOrUnknown(
              data['walking_completed']!, _walkingCompletedMeta));
    }
    if (data.containsKey('walking_steps')) {
      context.handle(
          _walkingStepsMeta,
          walkingSteps.isAcceptableOrUnknown(
              data['walking_steps']!, _walkingStepsMeta));
    }
    if (data.containsKey('walking_time')) {
      context.handle(
          _walkingTimeMeta,
          walkingTime.isAcceptableOrUnknown(
              data['walking_time']!, _walkingTimeMeta));
    }
    if (data.containsKey('avoid_habit_label')) {
      context.handle(
          _avoidHabitLabelMeta,
          avoidHabitLabel.isAcceptableOrUnknown(
              data['avoid_habit_label']!, _avoidHabitLabelMeta));
    }
    if (data.containsKey('avoid_habit_value')) {
      context.handle(
          _avoidHabitValueMeta,
          avoidHabitValue.isAcceptableOrUnknown(
              data['avoid_habit_value']!, _avoidHabitValueMeta));
    }
    if (data.containsKey('avoid_sweets_value')) {
      context.handle(
          _avoidSweetsValueMeta,
          avoidSweetsValue.isAcceptableOrUnknown(
              data['avoid_sweets_value']!, _avoidSweetsValueMeta));
    }
    if (data.containsKey('work_done_value')) {
      context.handle(
          _workDoneValueMeta,
          workDoneValue.isAcceptableOrUnknown(
              data['work_done_value']!, _workDoneValueMeta));
    }
    if (data.containsKey('movie_series_completed')) {
      context.handle(
          _movieSeriesCompletedMeta,
          movieSeriesCompleted.isAcceptableOrUnknown(
              data['movie_series_completed']!, _movieSeriesCompletedMeta));
    }
    if (data.containsKey('movie_series_name')) {
      context.handle(
          _movieSeriesNameMeta,
          movieSeriesName.isAcceptableOrUnknown(
              data['movie_series_name']!, _movieSeriesNameMeta));
    }
    if (data.containsKey('movie_series_duration')) {
      context.handle(
          _movieSeriesDurationMeta,
          movieSeriesDuration.isAcceptableOrUnknown(
              data['movie_series_duration']!, _movieSeriesDurationMeta));
    }
    if (data.containsKey('movie_series_start_time')) {
      context.handle(
          _movieSeriesStartTimeMeta,
          movieSeriesStartTime.isAcceptableOrUnknown(
              data['movie_series_start_time']!, _movieSeriesStartTimeMeta));
    }
    if (data.containsKey('movie_series_end_time')) {
      context.handle(
          _movieSeriesEndTimeMeta,
          movieSeriesEndTime.isAcceptableOrUnknown(
              data['movie_series_end_time']!, _movieSeriesEndTimeMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('timezone_offset')) {
      context.handle(
          _timezoneOffsetMeta,
          timezoneOffset.isAcceptableOrUnknown(
              data['timezone_offset']!, _timezoneOffsetMeta));
    }
    if (data.containsKey('needs_sync')) {
      context.handle(_needsSyncMeta,
          needsSync.isAcceptableOrUnknown(data['needs_sync']!, _needsSyncMeta));
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
          _lastSyncAtMeta,
          lastSyncAt.isAcceptableOrUnknown(
              data['last_sync_at']!, _lastSyncAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, date};
  @override
  DailyTask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyTask(
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      readingBookCompleted: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}reading_book_completed'])!,
      readingBookPages: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reading_book_pages']),
      readingBookTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reading_book_time']),
      stretchCompleted: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}stretch_completed'])!,
      stretchMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stretch_minutes']),
      stretchType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}stretch_type']),
      meditationCompleted: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}meditation_completed'])!,
      meditationMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}meditation_minutes']),
      readingDocsCompleted: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}reading_docs_completed'])!,
      readingDocsPages: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reading_docs_pages']),
      readingDocsTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reading_docs_time']),
      readingDocsNameLink: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}reading_docs_name_link']),
      learningTechCompleted: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}learning_tech_completed'])!,
      learningTechName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}learning_tech_name']),
      learningTechTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}learning_tech_time']),
      learningTechSource: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}learning_tech_source']),
      learningTechUrl: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}learning_tech_url']),
      walkingCompleted: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}walking_completed'])!,
      walkingSteps: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}walking_steps']),
      walkingTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}walking_time']),
      avoidHabitLabel: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}avoid_habit_label']),
      avoidHabitValue: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}avoid_habit_value'])!,
      avoidSweetsValue: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}avoid_sweets_value'])!,
      workDoneValue: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}work_done_value'])!,
      movieSeriesCompleted: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}movie_series_completed'])!,
      movieSeriesName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}movie_series_name']),
      movieSeriesDuration: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}movie_series_duration']),
      movieSeriesStartTime: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}movie_series_start_time']),
      movieSeriesEndTime: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}movie_series_end_time']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      timezoneOffset: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}timezone_offset']),
      needsSync: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}needs_sync'])!,
      lastSyncAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_sync_at']),
    );
  }

  @override
  $DailyTasksTable createAlias(String alias) {
    return $DailyTasksTable(attachedDatabase, alias);
  }
}

class DailyTask extends DataClass implements Insertable<DailyTask> {
  final String userId;
  final DateTime date;
  final bool readingBookCompleted;
  final int? readingBookPages;
  final int? readingBookTime;
  final bool stretchCompleted;
  final int? stretchMinutes;
  final String? stretchType;
  final bool meditationCompleted;
  final int? meditationMinutes;
  final bool readingDocsCompleted;
  final int? readingDocsPages;
  final int? readingDocsTime;
  final String? readingDocsNameLink;
  final bool learningTechCompleted;
  final String? learningTechName;
  final int? learningTechTime;
  final String? learningTechSource;
  final String? learningTechUrl;
  final bool walkingCompleted;
  final int? walkingSteps;
  final int? walkingTime;
  final String? avoidHabitLabel;
  final bool avoidHabitValue;
  final bool avoidSweetsValue;
  final bool workDoneValue;
  final bool movieSeriesCompleted;
  final String? movieSeriesName;
  final int? movieSeriesDuration;
  final String? movieSeriesStartTime;
  final String? movieSeriesEndTime;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int? timezoneOffset;
  final bool needsSync;
  final DateTime? lastSyncAt;
  const DailyTask(
      {required this.userId,
      required this.date,
      required this.readingBookCompleted,
      this.readingBookPages,
      this.readingBookTime,
      required this.stretchCompleted,
      this.stretchMinutes,
      this.stretchType,
      required this.meditationCompleted,
      this.meditationMinutes,
      required this.readingDocsCompleted,
      this.readingDocsPages,
      this.readingDocsTime,
      this.readingDocsNameLink,
      required this.learningTechCompleted,
      this.learningTechName,
      this.learningTechTime,
      this.learningTechSource,
      this.learningTechUrl,
      required this.walkingCompleted,
      this.walkingSteps,
      this.walkingTime,
      this.avoidHabitLabel,
      required this.avoidHabitValue,
      required this.avoidSweetsValue,
      required this.workDoneValue,
      required this.movieSeriesCompleted,
      this.movieSeriesName,
      this.movieSeriesDuration,
      this.movieSeriesStartTime,
      this.movieSeriesEndTime,
      this.notes,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      this.timezoneOffset,
      required this.needsSync,
      this.lastSyncAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['date'] = Variable<DateTime>(date);
    map['reading_book_completed'] = Variable<bool>(readingBookCompleted);
    if (!nullToAbsent || readingBookPages != null) {
      map['reading_book_pages'] = Variable<int>(readingBookPages);
    }
    if (!nullToAbsent || readingBookTime != null) {
      map['reading_book_time'] = Variable<int>(readingBookTime);
    }
    map['stretch_completed'] = Variable<bool>(stretchCompleted);
    if (!nullToAbsent || stretchMinutes != null) {
      map['stretch_minutes'] = Variable<int>(stretchMinutes);
    }
    if (!nullToAbsent || stretchType != null) {
      map['stretch_type'] = Variable<String>(stretchType);
    }
    map['meditation_completed'] = Variable<bool>(meditationCompleted);
    if (!nullToAbsent || meditationMinutes != null) {
      map['meditation_minutes'] = Variable<int>(meditationMinutes);
    }
    map['reading_docs_completed'] = Variable<bool>(readingDocsCompleted);
    if (!nullToAbsent || readingDocsPages != null) {
      map['reading_docs_pages'] = Variable<int>(readingDocsPages);
    }
    if (!nullToAbsent || readingDocsTime != null) {
      map['reading_docs_time'] = Variable<int>(readingDocsTime);
    }
    if (!nullToAbsent || readingDocsNameLink != null) {
      map['reading_docs_name_link'] = Variable<String>(readingDocsNameLink);
    }
    map['learning_tech_completed'] = Variable<bool>(learningTechCompleted);
    if (!nullToAbsent || learningTechName != null) {
      map['learning_tech_name'] = Variable<String>(learningTechName);
    }
    if (!nullToAbsent || learningTechTime != null) {
      map['learning_tech_time'] = Variable<int>(learningTechTime);
    }
    if (!nullToAbsent || learningTechSource != null) {
      map['learning_tech_source'] = Variable<String>(learningTechSource);
    }
    if (!nullToAbsent || learningTechUrl != null) {
      map['learning_tech_url'] = Variable<String>(learningTechUrl);
    }
    map['walking_completed'] = Variable<bool>(walkingCompleted);
    if (!nullToAbsent || walkingSteps != null) {
      map['walking_steps'] = Variable<int>(walkingSteps);
    }
    if (!nullToAbsent || walkingTime != null) {
      map['walking_time'] = Variable<int>(walkingTime);
    }
    if (!nullToAbsent || avoidHabitLabel != null) {
      map['avoid_habit_label'] = Variable<String>(avoidHabitLabel);
    }
    map['avoid_habit_value'] = Variable<bool>(avoidHabitValue);
    map['avoid_sweets_value'] = Variable<bool>(avoidSweetsValue);
    map['work_done_value'] = Variable<bool>(workDoneValue);
    map['movie_series_completed'] = Variable<bool>(movieSeriesCompleted);
    if (!nullToAbsent || movieSeriesName != null) {
      map['movie_series_name'] = Variable<String>(movieSeriesName);
    }
    if (!nullToAbsent || movieSeriesDuration != null) {
      map['movie_series_duration'] = Variable<int>(movieSeriesDuration);
    }
    if (!nullToAbsent || movieSeriesStartTime != null) {
      map['movie_series_start_time'] = Variable<String>(movieSeriesStartTime);
    }
    if (!nullToAbsent || movieSeriesEndTime != null) {
      map['movie_series_end_time'] = Variable<String>(movieSeriesEndTime);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || timezoneOffset != null) {
      map['timezone_offset'] = Variable<int>(timezoneOffset);
    }
    map['needs_sync'] = Variable<bool>(needsSync);
    if (!nullToAbsent || lastSyncAt != null) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt);
    }
    return map;
  }

  DailyTasksCompanion toCompanion(bool nullToAbsent) {
    return DailyTasksCompanion(
      userId: Value(userId),
      date: Value(date),
      readingBookCompleted: Value(readingBookCompleted),
      readingBookPages: readingBookPages == null && nullToAbsent
          ? const Value.absent()
          : Value(readingBookPages),
      readingBookTime: readingBookTime == null && nullToAbsent
          ? const Value.absent()
          : Value(readingBookTime),
      stretchCompleted: Value(stretchCompleted),
      stretchMinutes: stretchMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(stretchMinutes),
      stretchType: stretchType == null && nullToAbsent
          ? const Value.absent()
          : Value(stretchType),
      meditationCompleted: Value(meditationCompleted),
      meditationMinutes: meditationMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(meditationMinutes),
      readingDocsCompleted: Value(readingDocsCompleted),
      readingDocsPages: readingDocsPages == null && nullToAbsent
          ? const Value.absent()
          : Value(readingDocsPages),
      readingDocsTime: readingDocsTime == null && nullToAbsent
          ? const Value.absent()
          : Value(readingDocsTime),
      readingDocsNameLink: readingDocsNameLink == null && nullToAbsent
          ? const Value.absent()
          : Value(readingDocsNameLink),
      learningTechCompleted: Value(learningTechCompleted),
      learningTechName: learningTechName == null && nullToAbsent
          ? const Value.absent()
          : Value(learningTechName),
      learningTechTime: learningTechTime == null && nullToAbsent
          ? const Value.absent()
          : Value(learningTechTime),
      learningTechSource: learningTechSource == null && nullToAbsent
          ? const Value.absent()
          : Value(learningTechSource),
      learningTechUrl: learningTechUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(learningTechUrl),
      walkingCompleted: Value(walkingCompleted),
      walkingSteps: walkingSteps == null && nullToAbsent
          ? const Value.absent()
          : Value(walkingSteps),
      walkingTime: walkingTime == null && nullToAbsent
          ? const Value.absent()
          : Value(walkingTime),
      avoidHabitLabel: avoidHabitLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(avoidHabitLabel),
      avoidHabitValue: Value(avoidHabitValue),
      avoidSweetsValue: Value(avoidSweetsValue),
      workDoneValue: Value(workDoneValue),
      movieSeriesCompleted: Value(movieSeriesCompleted),
      movieSeriesName: movieSeriesName == null && nullToAbsent
          ? const Value.absent()
          : Value(movieSeriesName),
      movieSeriesDuration: movieSeriesDuration == null && nullToAbsent
          ? const Value.absent()
          : Value(movieSeriesDuration),
      movieSeriesStartTime: movieSeriesStartTime == null && nullToAbsent
          ? const Value.absent()
          : Value(movieSeriesStartTime),
      movieSeriesEndTime: movieSeriesEndTime == null && nullToAbsent
          ? const Value.absent()
          : Value(movieSeriesEndTime),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      timezoneOffset: timezoneOffset == null && nullToAbsent
          ? const Value.absent()
          : Value(timezoneOffset),
      needsSync: Value(needsSync),
      lastSyncAt: lastSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAt),
    );
  }

  factory DailyTask.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyTask(
      userId: serializer.fromJson<String>(json['userId']),
      date: serializer.fromJson<DateTime>(json['date']),
      readingBookCompleted:
          serializer.fromJson<bool>(json['readingBookCompleted']),
      readingBookPages: serializer.fromJson<int?>(json['readingBookPages']),
      readingBookTime: serializer.fromJson<int?>(json['readingBookTime']),
      stretchCompleted: serializer.fromJson<bool>(json['stretchCompleted']),
      stretchMinutes: serializer.fromJson<int?>(json['stretchMinutes']),
      stretchType: serializer.fromJson<String?>(json['stretchType']),
      meditationCompleted:
          serializer.fromJson<bool>(json['meditationCompleted']),
      meditationMinutes: serializer.fromJson<int?>(json['meditationMinutes']),
      readingDocsCompleted:
          serializer.fromJson<bool>(json['readingDocsCompleted']),
      readingDocsPages: serializer.fromJson<int?>(json['readingDocsPages']),
      readingDocsTime: serializer.fromJson<int?>(json['readingDocsTime']),
      readingDocsNameLink:
          serializer.fromJson<String?>(json['readingDocsNameLink']),
      learningTechCompleted:
          serializer.fromJson<bool>(json['learningTechCompleted']),
      learningTechName: serializer.fromJson<String?>(json['learningTechName']),
      learningTechTime: serializer.fromJson<int?>(json['learningTechTime']),
      learningTechSource:
          serializer.fromJson<String?>(json['learningTechSource']),
      learningTechUrl: serializer.fromJson<String?>(json['learningTechUrl']),
      walkingCompleted: serializer.fromJson<bool>(json['walkingCompleted']),
      walkingSteps: serializer.fromJson<int?>(json['walkingSteps']),
      walkingTime: serializer.fromJson<int?>(json['walkingTime']),
      avoidHabitLabel: serializer.fromJson<String?>(json['avoidHabitLabel']),
      avoidHabitValue: serializer.fromJson<bool>(json['avoidHabitValue']),
      avoidSweetsValue: serializer.fromJson<bool>(json['avoidSweetsValue']),
      workDoneValue: serializer.fromJson<bool>(json['workDoneValue']),
      movieSeriesCompleted:
          serializer.fromJson<bool>(json['movieSeriesCompleted']),
      movieSeriesName: serializer.fromJson<String?>(json['movieSeriesName']),
      movieSeriesDuration:
          serializer.fromJson<int?>(json['movieSeriesDuration']),
      movieSeriesStartTime:
          serializer.fromJson<String?>(json['movieSeriesStartTime']),
      movieSeriesEndTime:
          serializer.fromJson<String?>(json['movieSeriesEndTime']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      timezoneOffset: serializer.fromJson<int?>(json['timezoneOffset']),
      needsSync: serializer.fromJson<bool>(json['needsSync']),
      lastSyncAt: serializer.fromJson<DateTime?>(json['lastSyncAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'date': serializer.toJson<DateTime>(date),
      'readingBookCompleted': serializer.toJson<bool>(readingBookCompleted),
      'readingBookPages': serializer.toJson<int?>(readingBookPages),
      'readingBookTime': serializer.toJson<int?>(readingBookTime),
      'stretchCompleted': serializer.toJson<bool>(stretchCompleted),
      'stretchMinutes': serializer.toJson<int?>(stretchMinutes),
      'stretchType': serializer.toJson<String?>(stretchType),
      'meditationCompleted': serializer.toJson<bool>(meditationCompleted),
      'meditationMinutes': serializer.toJson<int?>(meditationMinutes),
      'readingDocsCompleted': serializer.toJson<bool>(readingDocsCompleted),
      'readingDocsPages': serializer.toJson<int?>(readingDocsPages),
      'readingDocsTime': serializer.toJson<int?>(readingDocsTime),
      'readingDocsNameLink': serializer.toJson<String?>(readingDocsNameLink),
      'learningTechCompleted': serializer.toJson<bool>(learningTechCompleted),
      'learningTechName': serializer.toJson<String?>(learningTechName),
      'learningTechTime': serializer.toJson<int?>(learningTechTime),
      'learningTechSource': serializer.toJson<String?>(learningTechSource),
      'learningTechUrl': serializer.toJson<String?>(learningTechUrl),
      'walkingCompleted': serializer.toJson<bool>(walkingCompleted),
      'walkingSteps': serializer.toJson<int?>(walkingSteps),
      'walkingTime': serializer.toJson<int?>(walkingTime),
      'avoidHabitLabel': serializer.toJson<String?>(avoidHabitLabel),
      'avoidHabitValue': serializer.toJson<bool>(avoidHabitValue),
      'avoidSweetsValue': serializer.toJson<bool>(avoidSweetsValue),
      'workDoneValue': serializer.toJson<bool>(workDoneValue),
      'movieSeriesCompleted': serializer.toJson<bool>(movieSeriesCompleted),
      'movieSeriesName': serializer.toJson<String?>(movieSeriesName),
      'movieSeriesDuration': serializer.toJson<int?>(movieSeriesDuration),
      'movieSeriesStartTime': serializer.toJson<String?>(movieSeriesStartTime),
      'movieSeriesEndTime': serializer.toJson<String?>(movieSeriesEndTime),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'timezoneOffset': serializer.toJson<int?>(timezoneOffset),
      'needsSync': serializer.toJson<bool>(needsSync),
      'lastSyncAt': serializer.toJson<DateTime?>(lastSyncAt),
    };
  }

  DailyTask copyWith(
          {String? userId,
          DateTime? date,
          bool? readingBookCompleted,
          Value<int?> readingBookPages = const Value.absent(),
          Value<int?> readingBookTime = const Value.absent(),
          bool? stretchCompleted,
          Value<int?> stretchMinutes = const Value.absent(),
          Value<String?> stretchType = const Value.absent(),
          bool? meditationCompleted,
          Value<int?> meditationMinutes = const Value.absent(),
          bool? readingDocsCompleted,
          Value<int?> readingDocsPages = const Value.absent(),
          Value<int?> readingDocsTime = const Value.absent(),
          Value<String?> readingDocsNameLink = const Value.absent(),
          bool? learningTechCompleted,
          Value<String?> learningTechName = const Value.absent(),
          Value<int?> learningTechTime = const Value.absent(),
          Value<String?> learningTechSource = const Value.absent(),
          Value<String?> learningTechUrl = const Value.absent(),
          bool? walkingCompleted,
          Value<int?> walkingSteps = const Value.absent(),
          Value<int?> walkingTime = const Value.absent(),
          Value<String?> avoidHabitLabel = const Value.absent(),
          bool? avoidHabitValue,
          bool? avoidSweetsValue,
          bool? workDoneValue,
          bool? movieSeriesCompleted,
          Value<String?> movieSeriesName = const Value.absent(),
          Value<int?> movieSeriesDuration = const Value.absent(),
          Value<String?> movieSeriesStartTime = const Value.absent(),
          Value<String?> movieSeriesEndTime = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<int?> timezoneOffset = const Value.absent(),
          bool? needsSync,
          Value<DateTime?> lastSyncAt = const Value.absent()}) =>
      DailyTask(
        userId: userId ?? this.userId,
        date: date ?? this.date,
        readingBookCompleted: readingBookCompleted ?? this.readingBookCompleted,
        readingBookPages: readingBookPages.present
            ? readingBookPages.value
            : this.readingBookPages,
        readingBookTime: readingBookTime.present
            ? readingBookTime.value
            : this.readingBookTime,
        stretchCompleted: stretchCompleted ?? this.stretchCompleted,
        stretchMinutes:
            stretchMinutes.present ? stretchMinutes.value : this.stretchMinutes,
        stretchType: stretchType.present ? stretchType.value : this.stretchType,
        meditationCompleted: meditationCompleted ?? this.meditationCompleted,
        meditationMinutes: meditationMinutes.present
            ? meditationMinutes.value
            : this.meditationMinutes,
        readingDocsCompleted: readingDocsCompleted ?? this.readingDocsCompleted,
        readingDocsPages: readingDocsPages.present
            ? readingDocsPages.value
            : this.readingDocsPages,
        readingDocsTime: readingDocsTime.present
            ? readingDocsTime.value
            : this.readingDocsTime,
        readingDocsNameLink: readingDocsNameLink.present
            ? readingDocsNameLink.value
            : this.readingDocsNameLink,
        learningTechCompleted:
            learningTechCompleted ?? this.learningTechCompleted,
        learningTechName: learningTechName.present
            ? learningTechName.value
            : this.learningTechName,
        learningTechTime: learningTechTime.present
            ? learningTechTime.value
            : this.learningTechTime,
        learningTechSource: learningTechSource.present
            ? learningTechSource.value
            : this.learningTechSource,
        learningTechUrl: learningTechUrl.present
            ? learningTechUrl.value
            : this.learningTechUrl,
        walkingCompleted: walkingCompleted ?? this.walkingCompleted,
        walkingSteps:
            walkingSteps.present ? walkingSteps.value : this.walkingSteps,
        walkingTime: walkingTime.present ? walkingTime.value : this.walkingTime,
        avoidHabitLabel: avoidHabitLabel.present
            ? avoidHabitLabel.value
            : this.avoidHabitLabel,
        avoidHabitValue: avoidHabitValue ?? this.avoidHabitValue,
        avoidSweetsValue: avoidSweetsValue ?? this.avoidSweetsValue,
        workDoneValue: workDoneValue ?? this.workDoneValue,
        movieSeriesCompleted: movieSeriesCompleted ?? this.movieSeriesCompleted,
        movieSeriesName: movieSeriesName.present
            ? movieSeriesName.value
            : this.movieSeriesName,
        movieSeriesDuration: movieSeriesDuration.present
            ? movieSeriesDuration.value
            : this.movieSeriesDuration,
        movieSeriesStartTime: movieSeriesStartTime.present
            ? movieSeriesStartTime.value
            : this.movieSeriesStartTime,
        movieSeriesEndTime: movieSeriesEndTime.present
            ? movieSeriesEndTime.value
            : this.movieSeriesEndTime,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        timezoneOffset:
            timezoneOffset.present ? timezoneOffset.value : this.timezoneOffset,
        needsSync: needsSync ?? this.needsSync,
        lastSyncAt: lastSyncAt.present ? lastSyncAt.value : this.lastSyncAt,
      );
  DailyTask copyWithCompanion(DailyTasksCompanion data) {
    return DailyTask(
      userId: data.userId.present ? data.userId.value : this.userId,
      date: data.date.present ? data.date.value : this.date,
      readingBookCompleted: data.readingBookCompleted.present
          ? data.readingBookCompleted.value
          : this.readingBookCompleted,
      readingBookPages: data.readingBookPages.present
          ? data.readingBookPages.value
          : this.readingBookPages,
      readingBookTime: data.readingBookTime.present
          ? data.readingBookTime.value
          : this.readingBookTime,
      stretchCompleted: data.stretchCompleted.present
          ? data.stretchCompleted.value
          : this.stretchCompleted,
      stretchMinutes: data.stretchMinutes.present
          ? data.stretchMinutes.value
          : this.stretchMinutes,
      stretchType:
          data.stretchType.present ? data.stretchType.value : this.stretchType,
      meditationCompleted: data.meditationCompleted.present
          ? data.meditationCompleted.value
          : this.meditationCompleted,
      meditationMinutes: data.meditationMinutes.present
          ? data.meditationMinutes.value
          : this.meditationMinutes,
      readingDocsCompleted: data.readingDocsCompleted.present
          ? data.readingDocsCompleted.value
          : this.readingDocsCompleted,
      readingDocsPages: data.readingDocsPages.present
          ? data.readingDocsPages.value
          : this.readingDocsPages,
      readingDocsTime: data.readingDocsTime.present
          ? data.readingDocsTime.value
          : this.readingDocsTime,
      readingDocsNameLink: data.readingDocsNameLink.present
          ? data.readingDocsNameLink.value
          : this.readingDocsNameLink,
      learningTechCompleted: data.learningTechCompleted.present
          ? data.learningTechCompleted.value
          : this.learningTechCompleted,
      learningTechName: data.learningTechName.present
          ? data.learningTechName.value
          : this.learningTechName,
      learningTechTime: data.learningTechTime.present
          ? data.learningTechTime.value
          : this.learningTechTime,
      learningTechSource: data.learningTechSource.present
          ? data.learningTechSource.value
          : this.learningTechSource,
      learningTechUrl: data.learningTechUrl.present
          ? data.learningTechUrl.value
          : this.learningTechUrl,
      walkingCompleted: data.walkingCompleted.present
          ? data.walkingCompleted.value
          : this.walkingCompleted,
      walkingSteps: data.walkingSteps.present
          ? data.walkingSteps.value
          : this.walkingSteps,
      walkingTime:
          data.walkingTime.present ? data.walkingTime.value : this.walkingTime,
      avoidHabitLabel: data.avoidHabitLabel.present
          ? data.avoidHabitLabel.value
          : this.avoidHabitLabel,
      avoidHabitValue: data.avoidHabitValue.present
          ? data.avoidHabitValue.value
          : this.avoidHabitValue,
      avoidSweetsValue: data.avoidSweetsValue.present
          ? data.avoidSweetsValue.value
          : this.avoidSweetsValue,
      workDoneValue: data.workDoneValue.present
          ? data.workDoneValue.value
          : this.workDoneValue,
      movieSeriesCompleted: data.movieSeriesCompleted.present
          ? data.movieSeriesCompleted.value
          : this.movieSeriesCompleted,
      movieSeriesName: data.movieSeriesName.present
          ? data.movieSeriesName.value
          : this.movieSeriesName,
      movieSeriesDuration: data.movieSeriesDuration.present
          ? data.movieSeriesDuration.value
          : this.movieSeriesDuration,
      movieSeriesStartTime: data.movieSeriesStartTime.present
          ? data.movieSeriesStartTime.value
          : this.movieSeriesStartTime,
      movieSeriesEndTime: data.movieSeriesEndTime.present
          ? data.movieSeriesEndTime.value
          : this.movieSeriesEndTime,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      timezoneOffset: data.timezoneOffset.present
          ? data.timezoneOffset.value
          : this.timezoneOffset,
      needsSync: data.needsSync.present ? data.needsSync.value : this.needsSync,
      lastSyncAt:
          data.lastSyncAt.present ? data.lastSyncAt.value : this.lastSyncAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyTask(')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('readingBookCompleted: $readingBookCompleted, ')
          ..write('readingBookPages: $readingBookPages, ')
          ..write('readingBookTime: $readingBookTime, ')
          ..write('stretchCompleted: $stretchCompleted, ')
          ..write('stretchMinutes: $stretchMinutes, ')
          ..write('stretchType: $stretchType, ')
          ..write('meditationCompleted: $meditationCompleted, ')
          ..write('meditationMinutes: $meditationMinutes, ')
          ..write('readingDocsCompleted: $readingDocsCompleted, ')
          ..write('readingDocsPages: $readingDocsPages, ')
          ..write('readingDocsTime: $readingDocsTime, ')
          ..write('readingDocsNameLink: $readingDocsNameLink, ')
          ..write('learningTechCompleted: $learningTechCompleted, ')
          ..write('learningTechName: $learningTechName, ')
          ..write('learningTechTime: $learningTechTime, ')
          ..write('learningTechSource: $learningTechSource, ')
          ..write('learningTechUrl: $learningTechUrl, ')
          ..write('walkingCompleted: $walkingCompleted, ')
          ..write('walkingSteps: $walkingSteps, ')
          ..write('walkingTime: $walkingTime, ')
          ..write('avoidHabitLabel: $avoidHabitLabel, ')
          ..write('avoidHabitValue: $avoidHabitValue, ')
          ..write('avoidSweetsValue: $avoidSweetsValue, ')
          ..write('workDoneValue: $workDoneValue, ')
          ..write('movieSeriesCompleted: $movieSeriesCompleted, ')
          ..write('movieSeriesName: $movieSeriesName, ')
          ..write('movieSeriesDuration: $movieSeriesDuration, ')
          ..write('movieSeriesStartTime: $movieSeriesStartTime, ')
          ..write('movieSeriesEndTime: $movieSeriesEndTime, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('timezoneOffset: $timezoneOffset, ')
          ..write('needsSync: $needsSync, ')
          ..write('lastSyncAt: $lastSyncAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        userId,
        date,
        readingBookCompleted,
        readingBookPages,
        readingBookTime,
        stretchCompleted,
        stretchMinutes,
        stretchType,
        meditationCompleted,
        meditationMinutes,
        readingDocsCompleted,
        readingDocsPages,
        readingDocsTime,
        readingDocsNameLink,
        learningTechCompleted,
        learningTechName,
        learningTechTime,
        learningTechSource,
        learningTechUrl,
        walkingCompleted,
        walkingSteps,
        walkingTime,
        avoidHabitLabel,
        avoidHabitValue,
        avoidSweetsValue,
        workDoneValue,
        movieSeriesCompleted,
        movieSeriesName,
        movieSeriesDuration,
        movieSeriesStartTime,
        movieSeriesEndTime,
        notes,
        createdAt,
        updatedAt,
        deletedAt,
        timezoneOffset,
        needsSync,
        lastSyncAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyTask &&
          other.userId == this.userId &&
          other.date == this.date &&
          other.readingBookCompleted == this.readingBookCompleted &&
          other.readingBookPages == this.readingBookPages &&
          other.readingBookTime == this.readingBookTime &&
          other.stretchCompleted == this.stretchCompleted &&
          other.stretchMinutes == this.stretchMinutes &&
          other.stretchType == this.stretchType &&
          other.meditationCompleted == this.meditationCompleted &&
          other.meditationMinutes == this.meditationMinutes &&
          other.readingDocsCompleted == this.readingDocsCompleted &&
          other.readingDocsPages == this.readingDocsPages &&
          other.readingDocsTime == this.readingDocsTime &&
          other.readingDocsNameLink == this.readingDocsNameLink &&
          other.learningTechCompleted == this.learningTechCompleted &&
          other.learningTechName == this.learningTechName &&
          other.learningTechTime == this.learningTechTime &&
          other.learningTechSource == this.learningTechSource &&
          other.learningTechUrl == this.learningTechUrl &&
          other.walkingCompleted == this.walkingCompleted &&
          other.walkingSteps == this.walkingSteps &&
          other.walkingTime == this.walkingTime &&
          other.avoidHabitLabel == this.avoidHabitLabel &&
          other.avoidHabitValue == this.avoidHabitValue &&
          other.avoidSweetsValue == this.avoidSweetsValue &&
          other.workDoneValue == this.workDoneValue &&
          other.movieSeriesCompleted == this.movieSeriesCompleted &&
          other.movieSeriesName == this.movieSeriesName &&
          other.movieSeriesDuration == this.movieSeriesDuration &&
          other.movieSeriesStartTime == this.movieSeriesStartTime &&
          other.movieSeriesEndTime == this.movieSeriesEndTime &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.timezoneOffset == this.timezoneOffset &&
          other.needsSync == this.needsSync &&
          other.lastSyncAt == this.lastSyncAt);
}

class DailyTasksCompanion extends UpdateCompanion<DailyTask> {
  final Value<String> userId;
  final Value<DateTime> date;
  final Value<bool> readingBookCompleted;
  final Value<int?> readingBookPages;
  final Value<int?> readingBookTime;
  final Value<bool> stretchCompleted;
  final Value<int?> stretchMinutes;
  final Value<String?> stretchType;
  final Value<bool> meditationCompleted;
  final Value<int?> meditationMinutes;
  final Value<bool> readingDocsCompleted;
  final Value<int?> readingDocsPages;
  final Value<int?> readingDocsTime;
  final Value<String?> readingDocsNameLink;
  final Value<bool> learningTechCompleted;
  final Value<String?> learningTechName;
  final Value<int?> learningTechTime;
  final Value<String?> learningTechSource;
  final Value<String?> learningTechUrl;
  final Value<bool> walkingCompleted;
  final Value<int?> walkingSteps;
  final Value<int?> walkingTime;
  final Value<String?> avoidHabitLabel;
  final Value<bool> avoidHabitValue;
  final Value<bool> avoidSweetsValue;
  final Value<bool> workDoneValue;
  final Value<bool> movieSeriesCompleted;
  final Value<String?> movieSeriesName;
  final Value<int?> movieSeriesDuration;
  final Value<String?> movieSeriesStartTime;
  final Value<String?> movieSeriesEndTime;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int?> timezoneOffset;
  final Value<bool> needsSync;
  final Value<DateTime?> lastSyncAt;
  final Value<int> rowid;
  const DailyTasksCompanion({
    this.userId = const Value.absent(),
    this.date = const Value.absent(),
    this.readingBookCompleted = const Value.absent(),
    this.readingBookPages = const Value.absent(),
    this.readingBookTime = const Value.absent(),
    this.stretchCompleted = const Value.absent(),
    this.stretchMinutes = const Value.absent(),
    this.stretchType = const Value.absent(),
    this.meditationCompleted = const Value.absent(),
    this.meditationMinutes = const Value.absent(),
    this.readingDocsCompleted = const Value.absent(),
    this.readingDocsPages = const Value.absent(),
    this.readingDocsTime = const Value.absent(),
    this.readingDocsNameLink = const Value.absent(),
    this.learningTechCompleted = const Value.absent(),
    this.learningTechName = const Value.absent(),
    this.learningTechTime = const Value.absent(),
    this.learningTechSource = const Value.absent(),
    this.learningTechUrl = const Value.absent(),
    this.walkingCompleted = const Value.absent(),
    this.walkingSteps = const Value.absent(),
    this.walkingTime = const Value.absent(),
    this.avoidHabitLabel = const Value.absent(),
    this.avoidHabitValue = const Value.absent(),
    this.avoidSweetsValue = const Value.absent(),
    this.workDoneValue = const Value.absent(),
    this.movieSeriesCompleted = const Value.absent(),
    this.movieSeriesName = const Value.absent(),
    this.movieSeriesDuration = const Value.absent(),
    this.movieSeriesStartTime = const Value.absent(),
    this.movieSeriesEndTime = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.timezoneOffset = const Value.absent(),
    this.needsSync = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyTasksCompanion.insert({
    required String userId,
    required DateTime date,
    this.readingBookCompleted = const Value.absent(),
    this.readingBookPages = const Value.absent(),
    this.readingBookTime = const Value.absent(),
    this.stretchCompleted = const Value.absent(),
    this.stretchMinutes = const Value.absent(),
    this.stretchType = const Value.absent(),
    this.meditationCompleted = const Value.absent(),
    this.meditationMinutes = const Value.absent(),
    this.readingDocsCompleted = const Value.absent(),
    this.readingDocsPages = const Value.absent(),
    this.readingDocsTime = const Value.absent(),
    this.readingDocsNameLink = const Value.absent(),
    this.learningTechCompleted = const Value.absent(),
    this.learningTechName = const Value.absent(),
    this.learningTechTime = const Value.absent(),
    this.learningTechSource = const Value.absent(),
    this.learningTechUrl = const Value.absent(),
    this.walkingCompleted = const Value.absent(),
    this.walkingSteps = const Value.absent(),
    this.walkingTime = const Value.absent(),
    this.avoidHabitLabel = const Value.absent(),
    this.avoidHabitValue = const Value.absent(),
    this.avoidSweetsValue = const Value.absent(),
    this.workDoneValue = const Value.absent(),
    this.movieSeriesCompleted = const Value.absent(),
    this.movieSeriesName = const Value.absent(),
    this.movieSeriesDuration = const Value.absent(),
    this.movieSeriesStartTime = const Value.absent(),
    this.movieSeriesEndTime = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.timezoneOffset = const Value.absent(),
    this.needsSync = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : userId = Value(userId),
        date = Value(date);
  static Insertable<DailyTask> custom({
    Expression<String>? userId,
    Expression<DateTime>? date,
    Expression<bool>? readingBookCompleted,
    Expression<int>? readingBookPages,
    Expression<int>? readingBookTime,
    Expression<bool>? stretchCompleted,
    Expression<int>? stretchMinutes,
    Expression<String>? stretchType,
    Expression<bool>? meditationCompleted,
    Expression<int>? meditationMinutes,
    Expression<bool>? readingDocsCompleted,
    Expression<int>? readingDocsPages,
    Expression<int>? readingDocsTime,
    Expression<String>? readingDocsNameLink,
    Expression<bool>? learningTechCompleted,
    Expression<String>? learningTechName,
    Expression<int>? learningTechTime,
    Expression<String>? learningTechSource,
    Expression<String>? learningTechUrl,
    Expression<bool>? walkingCompleted,
    Expression<int>? walkingSteps,
    Expression<int>? walkingTime,
    Expression<String>? avoidHabitLabel,
    Expression<bool>? avoidHabitValue,
    Expression<bool>? avoidSweetsValue,
    Expression<bool>? workDoneValue,
    Expression<bool>? movieSeriesCompleted,
    Expression<String>? movieSeriesName,
    Expression<int>? movieSeriesDuration,
    Expression<String>? movieSeriesStartTime,
    Expression<String>? movieSeriesEndTime,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? timezoneOffset,
    Expression<bool>? needsSync,
    Expression<DateTime>? lastSyncAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (date != null) 'date': date,
      if (readingBookCompleted != null)
        'reading_book_completed': readingBookCompleted,
      if (readingBookPages != null) 'reading_book_pages': readingBookPages,
      if (readingBookTime != null) 'reading_book_time': readingBookTime,
      if (stretchCompleted != null) 'stretch_completed': stretchCompleted,
      if (stretchMinutes != null) 'stretch_minutes': stretchMinutes,
      if (stretchType != null) 'stretch_type': stretchType,
      if (meditationCompleted != null)
        'meditation_completed': meditationCompleted,
      if (meditationMinutes != null) 'meditation_minutes': meditationMinutes,
      if (readingDocsCompleted != null)
        'reading_docs_completed': readingDocsCompleted,
      if (readingDocsPages != null) 'reading_docs_pages': readingDocsPages,
      if (readingDocsTime != null) 'reading_docs_time': readingDocsTime,
      if (readingDocsNameLink != null)
        'reading_docs_name_link': readingDocsNameLink,
      if (learningTechCompleted != null)
        'learning_tech_completed': learningTechCompleted,
      if (learningTechName != null) 'learning_tech_name': learningTechName,
      if (learningTechTime != null) 'learning_tech_time': learningTechTime,
      if (learningTechSource != null)
        'learning_tech_source': learningTechSource,
      if (learningTechUrl != null) 'learning_tech_url': learningTechUrl,
      if (walkingCompleted != null) 'walking_completed': walkingCompleted,
      if (walkingSteps != null) 'walking_steps': walkingSteps,
      if (walkingTime != null) 'walking_time': walkingTime,
      if (avoidHabitLabel != null) 'avoid_habit_label': avoidHabitLabel,
      if (avoidHabitValue != null) 'avoid_habit_value': avoidHabitValue,
      if (avoidSweetsValue != null) 'avoid_sweets_value': avoidSweetsValue,
      if (workDoneValue != null) 'work_done_value': workDoneValue,
      if (movieSeriesCompleted != null)
        'movie_series_completed': movieSeriesCompleted,
      if (movieSeriesName != null) 'movie_series_name': movieSeriesName,
      if (movieSeriesDuration != null)
        'movie_series_duration': movieSeriesDuration,
      if (movieSeriesStartTime != null)
        'movie_series_start_time': movieSeriesStartTime,
      if (movieSeriesEndTime != null)
        'movie_series_end_time': movieSeriesEndTime,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (timezoneOffset != null) 'timezone_offset': timezoneOffset,
      if (needsSync != null) 'needs_sync': needsSync,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyTasksCompanion copyWith(
      {Value<String>? userId,
      Value<DateTime>? date,
      Value<bool>? readingBookCompleted,
      Value<int?>? readingBookPages,
      Value<int?>? readingBookTime,
      Value<bool>? stretchCompleted,
      Value<int?>? stretchMinutes,
      Value<String?>? stretchType,
      Value<bool>? meditationCompleted,
      Value<int?>? meditationMinutes,
      Value<bool>? readingDocsCompleted,
      Value<int?>? readingDocsPages,
      Value<int?>? readingDocsTime,
      Value<String?>? readingDocsNameLink,
      Value<bool>? learningTechCompleted,
      Value<String?>? learningTechName,
      Value<int?>? learningTechTime,
      Value<String?>? learningTechSource,
      Value<String?>? learningTechUrl,
      Value<bool>? walkingCompleted,
      Value<int?>? walkingSteps,
      Value<int?>? walkingTime,
      Value<String?>? avoidHabitLabel,
      Value<bool>? avoidHabitValue,
      Value<bool>? avoidSweetsValue,
      Value<bool>? workDoneValue,
      Value<bool>? movieSeriesCompleted,
      Value<String?>? movieSeriesName,
      Value<int?>? movieSeriesDuration,
      Value<String?>? movieSeriesStartTime,
      Value<String?>? movieSeriesEndTime,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int?>? timezoneOffset,
      Value<bool>? needsSync,
      Value<DateTime?>? lastSyncAt,
      Value<int>? rowid}) {
    return DailyTasksCompanion(
      userId: userId ?? this.userId,
      date: date ?? this.date,
      readingBookCompleted: readingBookCompleted ?? this.readingBookCompleted,
      readingBookPages: readingBookPages ?? this.readingBookPages,
      readingBookTime: readingBookTime ?? this.readingBookTime,
      stretchCompleted: stretchCompleted ?? this.stretchCompleted,
      stretchMinutes: stretchMinutes ?? this.stretchMinutes,
      stretchType: stretchType ?? this.stretchType,
      meditationCompleted: meditationCompleted ?? this.meditationCompleted,
      meditationMinutes: meditationMinutes ?? this.meditationMinutes,
      readingDocsCompleted: readingDocsCompleted ?? this.readingDocsCompleted,
      readingDocsPages: readingDocsPages ?? this.readingDocsPages,
      readingDocsTime: readingDocsTime ?? this.readingDocsTime,
      readingDocsNameLink: readingDocsNameLink ?? this.readingDocsNameLink,
      learningTechCompleted:
          learningTechCompleted ?? this.learningTechCompleted,
      learningTechName: learningTechName ?? this.learningTechName,
      learningTechTime: learningTechTime ?? this.learningTechTime,
      learningTechSource: learningTechSource ?? this.learningTechSource,
      learningTechUrl: learningTechUrl ?? this.learningTechUrl,
      walkingCompleted: walkingCompleted ?? this.walkingCompleted,
      walkingSteps: walkingSteps ?? this.walkingSteps,
      walkingTime: walkingTime ?? this.walkingTime,
      avoidHabitLabel: avoidHabitLabel ?? this.avoidHabitLabel,
      avoidHabitValue: avoidHabitValue ?? this.avoidHabitValue,
      avoidSweetsValue: avoidSweetsValue ?? this.avoidSweetsValue,
      workDoneValue: workDoneValue ?? this.workDoneValue,
      movieSeriesCompleted: movieSeriesCompleted ?? this.movieSeriesCompleted,
      movieSeriesName: movieSeriesName ?? this.movieSeriesName,
      movieSeriesDuration: movieSeriesDuration ?? this.movieSeriesDuration,
      movieSeriesStartTime: movieSeriesStartTime ?? this.movieSeriesStartTime,
      movieSeriesEndTime: movieSeriesEndTime ?? this.movieSeriesEndTime,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      timezoneOffset: timezoneOffset ?? this.timezoneOffset,
      needsSync: needsSync ?? this.needsSync,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (readingBookCompleted.present) {
      map['reading_book_completed'] =
          Variable<bool>(readingBookCompleted.value);
    }
    if (readingBookPages.present) {
      map['reading_book_pages'] = Variable<int>(readingBookPages.value);
    }
    if (readingBookTime.present) {
      map['reading_book_time'] = Variable<int>(readingBookTime.value);
    }
    if (stretchCompleted.present) {
      map['stretch_completed'] = Variable<bool>(stretchCompleted.value);
    }
    if (stretchMinutes.present) {
      map['stretch_minutes'] = Variable<int>(stretchMinutes.value);
    }
    if (stretchType.present) {
      map['stretch_type'] = Variable<String>(stretchType.value);
    }
    if (meditationCompleted.present) {
      map['meditation_completed'] = Variable<bool>(meditationCompleted.value);
    }
    if (meditationMinutes.present) {
      map['meditation_minutes'] = Variable<int>(meditationMinutes.value);
    }
    if (readingDocsCompleted.present) {
      map['reading_docs_completed'] =
          Variable<bool>(readingDocsCompleted.value);
    }
    if (readingDocsPages.present) {
      map['reading_docs_pages'] = Variable<int>(readingDocsPages.value);
    }
    if (readingDocsTime.present) {
      map['reading_docs_time'] = Variable<int>(readingDocsTime.value);
    }
    if (readingDocsNameLink.present) {
      map['reading_docs_name_link'] =
          Variable<String>(readingDocsNameLink.value);
    }
    if (learningTechCompleted.present) {
      map['learning_tech_completed'] =
          Variable<bool>(learningTechCompleted.value);
    }
    if (learningTechName.present) {
      map['learning_tech_name'] = Variable<String>(learningTechName.value);
    }
    if (learningTechTime.present) {
      map['learning_tech_time'] = Variable<int>(learningTechTime.value);
    }
    if (learningTechSource.present) {
      map['learning_tech_source'] = Variable<String>(learningTechSource.value);
    }
    if (learningTechUrl.present) {
      map['learning_tech_url'] = Variable<String>(learningTechUrl.value);
    }
    if (walkingCompleted.present) {
      map['walking_completed'] = Variable<bool>(walkingCompleted.value);
    }
    if (walkingSteps.present) {
      map['walking_steps'] = Variable<int>(walkingSteps.value);
    }
    if (walkingTime.present) {
      map['walking_time'] = Variable<int>(walkingTime.value);
    }
    if (avoidHabitLabel.present) {
      map['avoid_habit_label'] = Variable<String>(avoidHabitLabel.value);
    }
    if (avoidHabitValue.present) {
      map['avoid_habit_value'] = Variable<bool>(avoidHabitValue.value);
    }
    if (avoidSweetsValue.present) {
      map['avoid_sweets_value'] = Variable<bool>(avoidSweetsValue.value);
    }
    if (workDoneValue.present) {
      map['work_done_value'] = Variable<bool>(workDoneValue.value);
    }
    if (movieSeriesCompleted.present) {
      map['movie_series_completed'] =
          Variable<bool>(movieSeriesCompleted.value);
    }
    if (movieSeriesName.present) {
      map['movie_series_name'] = Variable<String>(movieSeriesName.value);
    }
    if (movieSeriesDuration.present) {
      map['movie_series_duration'] = Variable<int>(movieSeriesDuration.value);
    }
    if (movieSeriesStartTime.present) {
      map['movie_series_start_time'] =
          Variable<String>(movieSeriesStartTime.value);
    }
    if (movieSeriesEndTime.present) {
      map['movie_series_end_time'] = Variable<String>(movieSeriesEndTime.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (timezoneOffset.present) {
      map['timezone_offset'] = Variable<int>(timezoneOffset.value);
    }
    if (needsSync.present) {
      map['needs_sync'] = Variable<bool>(needsSync.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyTasksCompanion(')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('readingBookCompleted: $readingBookCompleted, ')
          ..write('readingBookPages: $readingBookPages, ')
          ..write('readingBookTime: $readingBookTime, ')
          ..write('stretchCompleted: $stretchCompleted, ')
          ..write('stretchMinutes: $stretchMinutes, ')
          ..write('stretchType: $stretchType, ')
          ..write('meditationCompleted: $meditationCompleted, ')
          ..write('meditationMinutes: $meditationMinutes, ')
          ..write('readingDocsCompleted: $readingDocsCompleted, ')
          ..write('readingDocsPages: $readingDocsPages, ')
          ..write('readingDocsTime: $readingDocsTime, ')
          ..write('readingDocsNameLink: $readingDocsNameLink, ')
          ..write('learningTechCompleted: $learningTechCompleted, ')
          ..write('learningTechName: $learningTechName, ')
          ..write('learningTechTime: $learningTechTime, ')
          ..write('learningTechSource: $learningTechSource, ')
          ..write('learningTechUrl: $learningTechUrl, ')
          ..write('walkingCompleted: $walkingCompleted, ')
          ..write('walkingSteps: $walkingSteps, ')
          ..write('walkingTime: $walkingTime, ')
          ..write('avoidHabitLabel: $avoidHabitLabel, ')
          ..write('avoidHabitValue: $avoidHabitValue, ')
          ..write('avoidSweetsValue: $avoidSweetsValue, ')
          ..write('workDoneValue: $workDoneValue, ')
          ..write('movieSeriesCompleted: $movieSeriesCompleted, ')
          ..write('movieSeriesName: $movieSeriesName, ')
          ..write('movieSeriesDuration: $movieSeriesDuration, ')
          ..write('movieSeriesStartTime: $movieSeriesStartTime, ')
          ..write('movieSeriesEndTime: $movieSeriesEndTime, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('timezoneOffset: $timezoneOffset, ')
          ..write('needsSync: $needsSync, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DailyTasksTable dailyTasks = $DailyTasksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [dailyTasks];
}

typedef $$DailyTasksTableCreateCompanionBuilder = DailyTasksCompanion Function({
  required String userId,
  required DateTime date,
  Value<bool> readingBookCompleted,
  Value<int?> readingBookPages,
  Value<int?> readingBookTime,
  Value<bool> stretchCompleted,
  Value<int?> stretchMinutes,
  Value<String?> stretchType,
  Value<bool> meditationCompleted,
  Value<int?> meditationMinutes,
  Value<bool> readingDocsCompleted,
  Value<int?> readingDocsPages,
  Value<int?> readingDocsTime,
  Value<String?> readingDocsNameLink,
  Value<bool> learningTechCompleted,
  Value<String?> learningTechName,
  Value<int?> learningTechTime,
  Value<String?> learningTechSource,
  Value<String?> learningTechUrl,
  Value<bool> walkingCompleted,
  Value<int?> walkingSteps,
  Value<int?> walkingTime,
  Value<String?> avoidHabitLabel,
  Value<bool> avoidHabitValue,
  Value<bool> avoidSweetsValue,
  Value<bool> workDoneValue,
  Value<bool> movieSeriesCompleted,
  Value<String?> movieSeriesName,
  Value<int?> movieSeriesDuration,
  Value<String?> movieSeriesStartTime,
  Value<String?> movieSeriesEndTime,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int?> timezoneOffset,
  Value<bool> needsSync,
  Value<DateTime?> lastSyncAt,
  Value<int> rowid,
});
typedef $$DailyTasksTableUpdateCompanionBuilder = DailyTasksCompanion Function({
  Value<String> userId,
  Value<DateTime> date,
  Value<bool> readingBookCompleted,
  Value<int?> readingBookPages,
  Value<int?> readingBookTime,
  Value<bool> stretchCompleted,
  Value<int?> stretchMinutes,
  Value<String?> stretchType,
  Value<bool> meditationCompleted,
  Value<int?> meditationMinutes,
  Value<bool> readingDocsCompleted,
  Value<int?> readingDocsPages,
  Value<int?> readingDocsTime,
  Value<String?> readingDocsNameLink,
  Value<bool> learningTechCompleted,
  Value<String?> learningTechName,
  Value<int?> learningTechTime,
  Value<String?> learningTechSource,
  Value<String?> learningTechUrl,
  Value<bool> walkingCompleted,
  Value<int?> walkingSteps,
  Value<int?> walkingTime,
  Value<String?> avoidHabitLabel,
  Value<bool> avoidHabitValue,
  Value<bool> avoidSweetsValue,
  Value<bool> workDoneValue,
  Value<bool> movieSeriesCompleted,
  Value<String?> movieSeriesName,
  Value<int?> movieSeriesDuration,
  Value<String?> movieSeriesStartTime,
  Value<String?> movieSeriesEndTime,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int?> timezoneOffset,
  Value<bool> needsSync,
  Value<DateTime?> lastSyncAt,
  Value<int> rowid,
});

class $$DailyTasksTableFilterComposer
    extends Composer<_$AppDatabase, $DailyTasksTable> {
  $$DailyTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get readingBookCompleted => $composableBuilder(
      column: $table.readingBookCompleted,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get readingBookPages => $composableBuilder(
      column: $table.readingBookPages,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get readingBookTime => $composableBuilder(
      column: $table.readingBookTime,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get stretchCompleted => $composableBuilder(
      column: $table.stretchCompleted,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stretchMinutes => $composableBuilder(
      column: $table.stretchMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stretchType => $composableBuilder(
      column: $table.stretchType, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get meditationCompleted => $composableBuilder(
      column: $table.meditationCompleted,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get meditationMinutes => $composableBuilder(
      column: $table.meditationMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get readingDocsCompleted => $composableBuilder(
      column: $table.readingDocsCompleted,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get readingDocsPages => $composableBuilder(
      column: $table.readingDocsPages,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get readingDocsTime => $composableBuilder(
      column: $table.readingDocsTime,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get readingDocsNameLink => $composableBuilder(
      column: $table.readingDocsNameLink,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get learningTechCompleted => $composableBuilder(
      column: $table.learningTechCompleted,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get learningTechName => $composableBuilder(
      column: $table.learningTechName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get learningTechTime => $composableBuilder(
      column: $table.learningTechTime,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get learningTechSource => $composableBuilder(
      column: $table.learningTechSource,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get learningTechUrl => $composableBuilder(
      column: $table.learningTechUrl,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get walkingCompleted => $composableBuilder(
      column: $table.walkingCompleted,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get walkingSteps => $composableBuilder(
      column: $table.walkingSteps, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get walkingTime => $composableBuilder(
      column: $table.walkingTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avoidHabitLabel => $composableBuilder(
      column: $table.avoidHabitLabel,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get avoidHabitValue => $composableBuilder(
      column: $table.avoidHabitValue,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get avoidSweetsValue => $composableBuilder(
      column: $table.avoidSweetsValue,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get workDoneValue => $composableBuilder(
      column: $table.workDoneValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get movieSeriesCompleted => $composableBuilder(
      column: $table.movieSeriesCompleted,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get movieSeriesName => $composableBuilder(
      column: $table.movieSeriesName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get movieSeriesDuration => $composableBuilder(
      column: $table.movieSeriesDuration,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get movieSeriesStartTime => $composableBuilder(
      column: $table.movieSeriesStartTime,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get movieSeriesEndTime => $composableBuilder(
      column: $table.movieSeriesEndTime,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timezoneOffset => $composableBuilder(
      column: $table.timezoneOffset,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get needsSync => $composableBuilder(
      column: $table.needsSync, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncAt => $composableBuilder(
      column: $table.lastSyncAt, builder: (column) => ColumnFilters(column));
}

class $$DailyTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyTasksTable> {
  $$DailyTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get readingBookCompleted => $composableBuilder(
      column: $table.readingBookCompleted,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get readingBookPages => $composableBuilder(
      column: $table.readingBookPages,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get readingBookTime => $composableBuilder(
      column: $table.readingBookTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get stretchCompleted => $composableBuilder(
      column: $table.stretchCompleted,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stretchMinutes => $composableBuilder(
      column: $table.stretchMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stretchType => $composableBuilder(
      column: $table.stretchType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get meditationCompleted => $composableBuilder(
      column: $table.meditationCompleted,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get meditationMinutes => $composableBuilder(
      column: $table.meditationMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get readingDocsCompleted => $composableBuilder(
      column: $table.readingDocsCompleted,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get readingDocsPages => $composableBuilder(
      column: $table.readingDocsPages,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get readingDocsTime => $composableBuilder(
      column: $table.readingDocsTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get readingDocsNameLink => $composableBuilder(
      column: $table.readingDocsNameLink,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get learningTechCompleted => $composableBuilder(
      column: $table.learningTechCompleted,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get learningTechName => $composableBuilder(
      column: $table.learningTechName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get learningTechTime => $composableBuilder(
      column: $table.learningTechTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get learningTechSource => $composableBuilder(
      column: $table.learningTechSource,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get learningTechUrl => $composableBuilder(
      column: $table.learningTechUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get walkingCompleted => $composableBuilder(
      column: $table.walkingCompleted,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get walkingSteps => $composableBuilder(
      column: $table.walkingSteps,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get walkingTime => $composableBuilder(
      column: $table.walkingTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avoidHabitLabel => $composableBuilder(
      column: $table.avoidHabitLabel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get avoidHabitValue => $composableBuilder(
      column: $table.avoidHabitValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get avoidSweetsValue => $composableBuilder(
      column: $table.avoidSweetsValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get workDoneValue => $composableBuilder(
      column: $table.workDoneValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get movieSeriesCompleted => $composableBuilder(
      column: $table.movieSeriesCompleted,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get movieSeriesName => $composableBuilder(
      column: $table.movieSeriesName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get movieSeriesDuration => $composableBuilder(
      column: $table.movieSeriesDuration,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get movieSeriesStartTime => $composableBuilder(
      column: $table.movieSeriesStartTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get movieSeriesEndTime => $composableBuilder(
      column: $table.movieSeriesEndTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timezoneOffset => $composableBuilder(
      column: $table.timezoneOffset,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get needsSync => $composableBuilder(
      column: $table.needsSync, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncAt => $composableBuilder(
      column: $table.lastSyncAt, builder: (column) => ColumnOrderings(column));
}

class $$DailyTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyTasksTable> {
  $$DailyTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<bool> get readingBookCompleted => $composableBuilder(
      column: $table.readingBookCompleted, builder: (column) => column);

  GeneratedColumn<int> get readingBookPages => $composableBuilder(
      column: $table.readingBookPages, builder: (column) => column);

  GeneratedColumn<int> get readingBookTime => $composableBuilder(
      column: $table.readingBookTime, builder: (column) => column);

  GeneratedColumn<bool> get stretchCompleted => $composableBuilder(
      column: $table.stretchCompleted, builder: (column) => column);

  GeneratedColumn<int> get stretchMinutes => $composableBuilder(
      column: $table.stretchMinutes, builder: (column) => column);

  GeneratedColumn<String> get stretchType => $composableBuilder(
      column: $table.stretchType, builder: (column) => column);

  GeneratedColumn<bool> get meditationCompleted => $composableBuilder(
      column: $table.meditationCompleted, builder: (column) => column);

  GeneratedColumn<int> get meditationMinutes => $composableBuilder(
      column: $table.meditationMinutes, builder: (column) => column);

  GeneratedColumn<bool> get readingDocsCompleted => $composableBuilder(
      column: $table.readingDocsCompleted, builder: (column) => column);

  GeneratedColumn<int> get readingDocsPages => $composableBuilder(
      column: $table.readingDocsPages, builder: (column) => column);

  GeneratedColumn<int> get readingDocsTime => $composableBuilder(
      column: $table.readingDocsTime, builder: (column) => column);

  GeneratedColumn<String> get readingDocsNameLink => $composableBuilder(
      column: $table.readingDocsNameLink, builder: (column) => column);

  GeneratedColumn<bool> get learningTechCompleted => $composableBuilder(
      column: $table.learningTechCompleted, builder: (column) => column);

  GeneratedColumn<String> get learningTechName => $composableBuilder(
      column: $table.learningTechName, builder: (column) => column);

  GeneratedColumn<int> get learningTechTime => $composableBuilder(
      column: $table.learningTechTime, builder: (column) => column);

  GeneratedColumn<String> get learningTechSource => $composableBuilder(
      column: $table.learningTechSource, builder: (column) => column);

  GeneratedColumn<String> get learningTechUrl => $composableBuilder(
      column: $table.learningTechUrl, builder: (column) => column);

  GeneratedColumn<bool> get walkingCompleted => $composableBuilder(
      column: $table.walkingCompleted, builder: (column) => column);

  GeneratedColumn<int> get walkingSteps => $composableBuilder(
      column: $table.walkingSteps, builder: (column) => column);

  GeneratedColumn<int> get walkingTime => $composableBuilder(
      column: $table.walkingTime, builder: (column) => column);

  GeneratedColumn<String> get avoidHabitLabel => $composableBuilder(
      column: $table.avoidHabitLabel, builder: (column) => column);

  GeneratedColumn<bool> get avoidHabitValue => $composableBuilder(
      column: $table.avoidHabitValue, builder: (column) => column);

  GeneratedColumn<bool> get avoidSweetsValue => $composableBuilder(
      column: $table.avoidSweetsValue, builder: (column) => column);

  GeneratedColumn<bool> get workDoneValue => $composableBuilder(
      column: $table.workDoneValue, builder: (column) => column);

  GeneratedColumn<bool> get movieSeriesCompleted => $composableBuilder(
      column: $table.movieSeriesCompleted, builder: (column) => column);

  GeneratedColumn<String> get movieSeriesName => $composableBuilder(
      column: $table.movieSeriesName, builder: (column) => column);

  GeneratedColumn<int> get movieSeriesDuration => $composableBuilder(
      column: $table.movieSeriesDuration, builder: (column) => column);

  GeneratedColumn<String> get movieSeriesStartTime => $composableBuilder(
      column: $table.movieSeriesStartTime, builder: (column) => column);

  GeneratedColumn<String> get movieSeriesEndTime => $composableBuilder(
      column: $table.movieSeriesEndTime, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get timezoneOffset => $composableBuilder(
      column: $table.timezoneOffset, builder: (column) => column);

  GeneratedColumn<bool> get needsSync =>
      $composableBuilder(column: $table.needsSync, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncAt => $composableBuilder(
      column: $table.lastSyncAt, builder: (column) => column);
}

class $$DailyTasksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DailyTasksTable,
    DailyTask,
    $$DailyTasksTableFilterComposer,
    $$DailyTasksTableOrderingComposer,
    $$DailyTasksTableAnnotationComposer,
    $$DailyTasksTableCreateCompanionBuilder,
    $$DailyTasksTableUpdateCompanionBuilder,
    (DailyTask, BaseReferences<_$AppDatabase, $DailyTasksTable, DailyTask>),
    DailyTask,
    PrefetchHooks Function()> {
  $$DailyTasksTableTableManager(_$AppDatabase db, $DailyTasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> userId = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<bool> readingBookCompleted = const Value.absent(),
            Value<int?> readingBookPages = const Value.absent(),
            Value<int?> readingBookTime = const Value.absent(),
            Value<bool> stretchCompleted = const Value.absent(),
            Value<int?> stretchMinutes = const Value.absent(),
            Value<String?> stretchType = const Value.absent(),
            Value<bool> meditationCompleted = const Value.absent(),
            Value<int?> meditationMinutes = const Value.absent(),
            Value<bool> readingDocsCompleted = const Value.absent(),
            Value<int?> readingDocsPages = const Value.absent(),
            Value<int?> readingDocsTime = const Value.absent(),
            Value<String?> readingDocsNameLink = const Value.absent(),
            Value<bool> learningTechCompleted = const Value.absent(),
            Value<String?> learningTechName = const Value.absent(),
            Value<int?> learningTechTime = const Value.absent(),
            Value<String?> learningTechSource = const Value.absent(),
            Value<String?> learningTechUrl = const Value.absent(),
            Value<bool> walkingCompleted = const Value.absent(),
            Value<int?> walkingSteps = const Value.absent(),
            Value<int?> walkingTime = const Value.absent(),
            Value<String?> avoidHabitLabel = const Value.absent(),
            Value<bool> avoidHabitValue = const Value.absent(),
            Value<bool> avoidSweetsValue = const Value.absent(),
            Value<bool> workDoneValue = const Value.absent(),
            Value<bool> movieSeriesCompleted = const Value.absent(),
            Value<String?> movieSeriesName = const Value.absent(),
            Value<int?> movieSeriesDuration = const Value.absent(),
            Value<String?> movieSeriesStartTime = const Value.absent(),
            Value<String?> movieSeriesEndTime = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int?> timezoneOffset = const Value.absent(),
            Value<bool> needsSync = const Value.absent(),
            Value<DateTime?> lastSyncAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DailyTasksCompanion(
            userId: userId,
            date: date,
            readingBookCompleted: readingBookCompleted,
            readingBookPages: readingBookPages,
            readingBookTime: readingBookTime,
            stretchCompleted: stretchCompleted,
            stretchMinutes: stretchMinutes,
            stretchType: stretchType,
            meditationCompleted: meditationCompleted,
            meditationMinutes: meditationMinutes,
            readingDocsCompleted: readingDocsCompleted,
            readingDocsPages: readingDocsPages,
            readingDocsTime: readingDocsTime,
            readingDocsNameLink: readingDocsNameLink,
            learningTechCompleted: learningTechCompleted,
            learningTechName: learningTechName,
            learningTechTime: learningTechTime,
            learningTechSource: learningTechSource,
            learningTechUrl: learningTechUrl,
            walkingCompleted: walkingCompleted,
            walkingSteps: walkingSteps,
            walkingTime: walkingTime,
            avoidHabitLabel: avoidHabitLabel,
            avoidHabitValue: avoidHabitValue,
            avoidSweetsValue: avoidSweetsValue,
            workDoneValue: workDoneValue,
            movieSeriesCompleted: movieSeriesCompleted,
            movieSeriesName: movieSeriesName,
            movieSeriesDuration: movieSeriesDuration,
            movieSeriesStartTime: movieSeriesStartTime,
            movieSeriesEndTime: movieSeriesEndTime,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            timezoneOffset: timezoneOffset,
            needsSync: needsSync,
            lastSyncAt: lastSyncAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String userId,
            required DateTime date,
            Value<bool> readingBookCompleted = const Value.absent(),
            Value<int?> readingBookPages = const Value.absent(),
            Value<int?> readingBookTime = const Value.absent(),
            Value<bool> stretchCompleted = const Value.absent(),
            Value<int?> stretchMinutes = const Value.absent(),
            Value<String?> stretchType = const Value.absent(),
            Value<bool> meditationCompleted = const Value.absent(),
            Value<int?> meditationMinutes = const Value.absent(),
            Value<bool> readingDocsCompleted = const Value.absent(),
            Value<int?> readingDocsPages = const Value.absent(),
            Value<int?> readingDocsTime = const Value.absent(),
            Value<String?> readingDocsNameLink = const Value.absent(),
            Value<bool> learningTechCompleted = const Value.absent(),
            Value<String?> learningTechName = const Value.absent(),
            Value<int?> learningTechTime = const Value.absent(),
            Value<String?> learningTechSource = const Value.absent(),
            Value<String?> learningTechUrl = const Value.absent(),
            Value<bool> walkingCompleted = const Value.absent(),
            Value<int?> walkingSteps = const Value.absent(),
            Value<int?> walkingTime = const Value.absent(),
            Value<String?> avoidHabitLabel = const Value.absent(),
            Value<bool> avoidHabitValue = const Value.absent(),
            Value<bool> avoidSweetsValue = const Value.absent(),
            Value<bool> workDoneValue = const Value.absent(),
            Value<bool> movieSeriesCompleted = const Value.absent(),
            Value<String?> movieSeriesName = const Value.absent(),
            Value<int?> movieSeriesDuration = const Value.absent(),
            Value<String?> movieSeriesStartTime = const Value.absent(),
            Value<String?> movieSeriesEndTime = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int?> timezoneOffset = const Value.absent(),
            Value<bool> needsSync = const Value.absent(),
            Value<DateTime?> lastSyncAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DailyTasksCompanion.insert(
            userId: userId,
            date: date,
            readingBookCompleted: readingBookCompleted,
            readingBookPages: readingBookPages,
            readingBookTime: readingBookTime,
            stretchCompleted: stretchCompleted,
            stretchMinutes: stretchMinutes,
            stretchType: stretchType,
            meditationCompleted: meditationCompleted,
            meditationMinutes: meditationMinutes,
            readingDocsCompleted: readingDocsCompleted,
            readingDocsPages: readingDocsPages,
            readingDocsTime: readingDocsTime,
            readingDocsNameLink: readingDocsNameLink,
            learningTechCompleted: learningTechCompleted,
            learningTechName: learningTechName,
            learningTechTime: learningTechTime,
            learningTechSource: learningTechSource,
            learningTechUrl: learningTechUrl,
            walkingCompleted: walkingCompleted,
            walkingSteps: walkingSteps,
            walkingTime: walkingTime,
            avoidHabitLabel: avoidHabitLabel,
            avoidHabitValue: avoidHabitValue,
            avoidSweetsValue: avoidSweetsValue,
            workDoneValue: workDoneValue,
            movieSeriesCompleted: movieSeriesCompleted,
            movieSeriesName: movieSeriesName,
            movieSeriesDuration: movieSeriesDuration,
            movieSeriesStartTime: movieSeriesStartTime,
            movieSeriesEndTime: movieSeriesEndTime,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            timezoneOffset: timezoneOffset,
            needsSync: needsSync,
            lastSyncAt: lastSyncAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DailyTasksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DailyTasksTable,
    DailyTask,
    $$DailyTasksTableFilterComposer,
    $$DailyTasksTableOrderingComposer,
    $$DailyTasksTableAnnotationComposer,
    $$DailyTasksTableCreateCompanionBuilder,
    $$DailyTasksTableUpdateCompanionBuilder,
    (DailyTask, BaseReferences<_$AppDatabase, $DailyTasksTable, DailyTask>),
    DailyTask,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DailyTasksTableTableManager get dailyTasks =>
      $$DailyTasksTableTableManager(_db, _db.dailyTasks);
}
