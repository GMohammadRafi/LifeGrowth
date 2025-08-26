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

// Removed DailyTasks table - replaced with v2 schema

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
