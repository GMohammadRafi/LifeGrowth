import '../services/supabase_service_v2.dart';
import '../models/task_type.dart';
import '../models/task.dart';
import '../models/daily_entry.dart';
import '../models/task_entry.dart';

class V2UsageExample {
  // Example 1: Create a new custom task type
  static Future<TaskType> createCustomTaskType() async {
    return await SupabaseServiceV2.createTaskType(
      name: 'language_learning',
      description: 'Language Learning Activity',
      schemaDefinition: {
        'type': 'object',
        'properties': {
          'language': {
            'type': 'string',
            'enum': ['Spanish', 'French', 'German', 'Japanese', 'Other']
          },
          'minutes': {
            'type': 'integer',
            'minimum': 0
          },
          'lesson_topic': {
            'type': 'string',
            'maxLength': 200
          },
          'app_used': {
            'type': 'string',
            'maxLength': 100
          },
          'difficulty_level': {
            'type': 'string',
            'enum': ['Beginner', 'Intermediate', 'Advanced']
          }
        },
        'required': ['language', 'minutes']
      },
    );
  }

  // Example 2: Create a user task instance
  static Future<Task> createUserTask(String taskTypeId) async {
    return await SupabaseServiceV2.createTask(
      taskTypeId: taskTypeId,
      name: 'Daily Spanish Learning',
      description: 'Practice Spanish for 30 minutes daily',
    );
  }

  // Example 3: Log a daily task entry
  static Future<void> logDailyTaskEntry() async {
    final userId = 'user-id-here'; // Get from auth
    final today = DateTime.now();
    
    // Create or get daily entry
    final dailyEntry = await SupabaseServiceV2.createOrUpdateDailyEntry(
      date: today,
      notes: 'Good progress today!',
    );
    
    // Get user's tasks
    final tasks = await SupabaseServiceV2.getUserTasks(userId);
    final languageTask = tasks.firstWhere(
      (task) => task.name.contains('Spanish'),
    );
    
    // Log the task entry
    await SupabaseServiceV2.createOrUpdateTaskEntry(
      dailyEntryId: dailyEntry.id,
      taskId: languageTask.id,
      data: {
        'language': 'Spanish',
        'minutes': 45,
        'lesson_topic': 'Past tense verbs',
        'app_used': 'Duolingo',
        'difficulty_level': 'Intermediate',
      },
      completed: true,
    );
  }

  // Example 4: Get daily data for display
  static Future<Map<String, dynamic>> getDailyData(String userId, DateTime date) async {
    return await SupabaseServiceV2.getDailyData(
      userId: userId,
      date: date,
    );
  }

  // Example 5: Create a reading book entry
  static Future<void> logReadingBookEntry() async {
    final userId = 'user-id-here';
    final today = DateTime.now();
    
    final dailyEntry = await SupabaseServiceV2.createOrUpdateDailyEntry(
      date: today,
    );
    
    final tasks = await SupabaseServiceV2.getUserTasks(userId);
    final readingTask = tasks.firstWhere(
      (task) => task.name.contains('Reading Book'),
    );
    
    await SupabaseServiceV2.createOrUpdateTaskEntry(
      dailyEntryId: dailyEntry.id,
      taskId: readingTask.id,
      data: {
        'pages': 25,
        'time': 60, // minutes
        'book_title': 'The Pragmatic Programmer',
      },
      completed: true,
    );
  }
}