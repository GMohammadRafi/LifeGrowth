import 'package:drift/drift.dart';

// Enum converters for Drift
class HabitFrequencyConverter extends TypeConverter<HabitFrequency, String> {
  const HabitFrequencyConverter();

  @override
  HabitFrequency fromSql(String fromDb) {
    return HabitFrequency.values.firstWhere((e) => e.name == fromDb);
  }

  @override
  String toSql(HabitFrequency value) {
    return value.name;
  }
}

class GoalCategoryConverter extends TypeConverter<GoalCategory, String> {
  const GoalCategoryConverter();

  @override
  GoalCategory fromSql(String fromDb) {
    return GoalCategory.values.firstWhere((e) => e.name == fromDb);
  }

  @override
  String toSql(GoalCategory value) {
    return value.name;
  }
}

class GoalPriorityConverter extends TypeConverter<GoalPriority, String> {
  const GoalPriorityConverter();

  @override
  GoalPriority fromSql(String fromDb) {
    return GoalPriority.values.firstWhere((e) => e.name == fromDb);
  }

  @override
  String toSql(GoalPriority value) {
    return value.name;
  }
}

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    return fromDb.split(',');
  }

  @override
  String toSql(List<String> value) {
    return value.join(',');
  }
}

// Import enums
enum HabitFrequency { daily, weekly, monthly }

enum GoalCategory {
  personal,
  professional,
  health,
  education,
  financial,
  relationships,
  hobbies,
  other
}

enum GoalPriority { low, medium, high, urgent }

@DataClassName('DailyTask')
class DailyTasks extends Table {
  // Primary key and user identification
  TextColumn get userId => text()();
  DateTimeColumn get date => dateTime()();

  // Reading book task
  BoolColumn get readingBookCompleted =>
      boolean().withDefault(const Constant(false))();
  IntColumn get readingBookPages => integer().nullable()();
  IntColumn get readingBookTime => integer().nullable()(); // minutes

  // Stretch task
  BoolColumn get stretchCompleted =>
      boolean().withDefault(const Constant(false))();
  IntColumn get stretchMinutes => integer().nullable()();
  TextColumn get stretchType => text().nullable()();

  // Meditation task
  BoolColumn get meditationCompleted =>
      boolean().withDefault(const Constant(false))();
  IntColumn get meditationMinutes => integer().nullable()();

  // Reading docs task
  BoolColumn get readingDocsCompleted =>
      boolean().withDefault(const Constant(false))();
  IntColumn get readingDocsPages => integer().nullable()();
  IntColumn get readingDocsTime => integer().nullable()(); // minutes
  TextColumn get readingDocsNameLink => text().nullable()();

  // Learning tech task
  BoolColumn get learningTechCompleted =>
      boolean().withDefault(const Constant(false))();
  TextColumn get learningTechName => text().nullable()();
  IntColumn get learningTechTime => integer().nullable()(); // minutes
  TextColumn get learningTechSource => text().nullable()();
  TextColumn get learningTechUrl => text().nullable()();

  // Walking task
  BoolColumn get walkingCompleted =>
      boolean().withDefault(const Constant(false))();
  IntColumn get walkingSteps => integer().nullable()();
  IntColumn get walkingTime => integer().nullable()(); // minutes

  // Avoid habit task
  TextColumn get avoidHabitLabel => text().nullable()();
  BoolColumn get avoidHabitValue =>
      boolean().withDefault(const Constant(false))();

  // Avoid sweets task
  BoolColumn get avoidSweetsValue =>
      boolean().withDefault(const Constant(false))();

  // Work done task
  BoolColumn get workDoneValue =>
      boolean().withDefault(const Constant(false))();

  // Movie/series task
  BoolColumn get movieSeriesCompleted =>
      boolean().withDefault(const Constant(false))();
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

@DataClassName('Habit')
class Habits extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  TextColumn get frequency => text().map(const HabitFrequencyConverter())();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get needsSync => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DailyCheckin')
class DailyCheckins extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  DateTimeColumn get date => dateTime()();
  IntColumn get mood => integer()(); // 1-10 scale
  IntColumn get energy => integer()(); // 1-10 scale
  IntColumn get stress => integer()(); // 1-10 scale
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get needsSync => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Goal')
class Goals extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get category => text().map(const GoalCategoryConverter())();
  TextColumn get priority => text()
      .map(const GoalPriorityConverter())
      .withDefault(const Constant('medium'))();
  DateTimeColumn get targetDate => dateTime()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get progress =>
      integer().withDefault(const Constant(0))(); // 0-100 percentage
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get needsSync => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('JournalEntry')
class JournalEntries extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  IntColumn get mood =>
      integer().withDefault(const Constant(5))(); // 1-10 scale
  TextColumn get tags =>
      text().map(const StringListConverter()).withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get needsSync => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
