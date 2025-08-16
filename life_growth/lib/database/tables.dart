import 'package:drift/drift.dart';

@DataClassName('DailyTask')
class DailyTasks extends Table {
  // Primary key and user identification
  TextColumn get userId => text()();
  DateTimeColumn get date => dateTime()();
  
  // Reading book task
  BoolColumn get readingBookCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get readingBookPages => integer().nullable()();
  IntColumn get readingBookTime => integer().nullable()(); // minutes
  
  // Stretch task
  BoolColumn get stretchCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get stretchMinutes => integer().nullable()();
  TextColumn get stretchType => text().nullable()();
  
  // Meditation task
  BoolColumn get meditationCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get meditationMinutes => integer().nullable()();
  
  // Reading docs task
  BoolColumn get readingDocsCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get readingDocsPages => integer().nullable()();
  IntColumn get readingDocsTime => integer().nullable()(); // minutes
  TextColumn get readingDocsNameLink => text().nullable()();
  
  // Learning tech task
  BoolColumn get learningTechCompleted => boolean().withDefault(const Constant(false))();
  TextColumn get learningTechName => text().nullable()();
  IntColumn get learningTechTime => integer().nullable()(); // minutes
  TextColumn get learningTechSource => text().nullable()();
  TextColumn get learningTechUrl => text().nullable()();
  
  // Walking task
  BoolColumn get walkingCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get walkingSteps => integer().nullable()();
  IntColumn get walkingTime => integer().nullable()(); // minutes
  
  // Avoid habit task
  TextColumn get avoidHabitLabel => text().nullable()();
  BoolColumn get avoidHabitValue => boolean().withDefault(const Constant(false))();
  
  // Avoid sweets task
  BoolColumn get avoidSweetsValue => boolean().withDefault(const Constant(false))();
  
  // Work done task
  BoolColumn get workDoneValue => boolean().withDefault(const Constant(false))();
  
  // Movie/series task
  BoolColumn get movieSeriesCompleted => boolean().withDefault(const Constant(false))();
  TextColumn get movieSeriesName => text().nullable()();
  IntColumn get movieSeriesDuration => integer().nullable()(); // minutes
  TextColumn get movieSeriesStartTime => text().nullable()(); // HH:MM format
  TextColumn get movieSeriesEndTime => text().nullable()(); // HH:MM format
  
  // Notes
  TextColumn get notes => text().nullable()();
  
  // Metadata
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get timezoneOffset => integer().nullable()(); // minutes from UTC
  
  // Sync metadata for offline support
  BoolColumn get needsSync => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  
  @override
  Set<Column> get primaryKey => {userId, date};
  
  @override
  List<String> get customConstraints => [
    // Ensure date is stored as date only (no time component)
    'CHECK (date = date(date))',
  ];
}