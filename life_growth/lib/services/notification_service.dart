import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io' show Platform;
import 'dart:convert';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _syncChannelId = 'life_growth_sync';
  static const String _syncChannelName = 'Life Growth Sync';
  static const String _syncChannelDescription =
      'Notifications for background sync operations';
  
  static const String _reminderChannelId = 'life_growth_reminders';
  static const String _reminderChannelName = 'Life Growth Reminders';
  static const String _reminderChannelDescription =
      'Daily and task reminders for Life Growth';
  
  static const int _dailyReminderId = 1000;
  static const String _dailyReminderKey = 'daily_reminder_enabled';
  static const String _dailyReminderTimeKey = 'daily_reminder_time';
  static const String _taskRemindersKey = 'task_reminders';

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    if (!kIsWeb) {
      await _createNotificationChannels();
    }
  }

  Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel syncChannel = AndroidNotificationChannel(
      _syncChannelId,
      _syncChannelName,
      description: _syncChannelDescription,
      importance: Importance.defaultImportance,
    );
    
    const AndroidNotificationChannel reminderChannel = AndroidNotificationChannel(
      _reminderChannelId,
      _reminderChannelName,
      description: _reminderChannelDescription,
      importance: Importance.high,
      playSound: true,
    );

    final androidImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    await androidImplementation?.createNotificationChannel(syncChannel);
    await androidImplementation?.createNotificationChannel(reminderChannel);
  }

  Future<void> _onNotificationTapped(NotificationResponse response) async {
    // Handle notification tap
    if (kDebugMode) {
      print('Notification tapped: ${response.payload}');
    }
    
    // Handle different notification types
    if (response.payload != null) {
      final payload = response.payload!;
      if (payload.startsWith('daily_reminder')) {
        // Handle daily reminder tap - could navigate to daily check-in
      } else if (payload.startsWith('task_reminder:')) {
        // Handle task reminder tap - could navigate to specific task
        final taskId = payload.split(':')[1];
        if (kDebugMode) {
          print('Task reminder tapped for task: $taskId');
        }
      }
    }
  }

  Future<void> showSyncNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      _syncChannelId,
      _syncChannelName,
      channelDescription: _syncChannelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      showWhen: false,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
      macOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  Future<void> showSyncSuccessNotification() async {
    await showSyncNotification(
      title: 'Sync Complete',
      body: 'Your data has been successfully synchronized.',
      payload: 'sync_success',
    );
  }

  Future<void> showSyncErrorNotification(String error) async {
    // Create a more user-friendly error message
    String userFriendlyMessage = getUserFriendlyErrorMessage(error);
    
    await showSyncNotification(
      title: 'Sync Failed',
      body: userFriendlyMessage,
      payload: 'sync_error',
    );
  }

  // Helper method to convert technical errors to user-friendly messages
  String getUserFriendlyErrorMessage(String error) {
    final errorLower = error.toLowerCase();
    
    if (errorLower.contains('failed host lookup') ||
        errorLower.contains('no address associated with hostname') ||
        errorLower.contains('socketexception') ||
        errorLower.contains('network is unreachable')) {
      return 'Unable to connect to server. Please check your internet connection and try again later.';
    }
    
    if (errorLower.contains('timeout')) {
      return 'Connection timed out. Please check your internet connection and try again.';
    }
    
    if (errorLower.contains('connection refused')) {
      return 'Server is temporarily unavailable. Please try again later.';
    }
    
    if (errorLower.contains('unable to connect to server')) {
      return error; // This is already user-friendly from our retry logic
    }
    
    // For other errors, show a generic message but log the actual error
    print('Unhandled sync error: $error');
    return 'Sync failed. Your data is saved locally and will sync when connection is restored.';
  }

  Future<void> showConflictResolvedNotification(int conflictsResolved) async {
    await showSyncNotification(
      title: 'Conflicts Resolved',
      body: '$conflictsResolved data conflicts were automatically resolved.',
      payload: 'conflicts_resolved',
    );
  }

  Future<bool> requestPermissions() async {
    if (kIsWeb) return true;

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final bool? grantedAndroid =
        await androidImplementation?.requestNotificationsPermission();

    if (kDebugMode) {
      print('Android notification permission granted: $grantedAndroid');
    }

    bool? grantedIOS;
    if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
      // iOS/macOS permission handling would go here
      // For now, we'll skip this since we're building for Windows
      grantedIOS = true;
    }

    final result = grantedAndroid ?? grantedIOS ?? false;
    if (kDebugMode) {
      print('Final permission result: $result');
    }

    return result;
  }

  Future<bool> areNotificationsEnabled() async {
    if (kIsWeb) return true;

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final bool? enabled = await androidImplementation?.areNotificationsEnabled();
    
    if (kDebugMode) {
      print('Notifications enabled status: $enabled');
    }
    
    return enabled ?? false;
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Daily Reminder Methods
  Future<void> setDailyReminder({
    required bool enabled,
    required TimeOfDay time,
  }) async {
    if (kDebugMode) {
      print('Setting daily reminder: enabled=$enabled, time=${time.hour}:${time.minute}');
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dailyReminderKey, enabled);
    await prefs.setString(_dailyReminderTimeKey, '${time.hour}:${time.minute}');
    
    if (enabled) {
      await _scheduleDailyReminder(time);
      if (kDebugMode) {
        print('Daily reminder scheduled successfully');
      }
    } else {
      await _flutterLocalNotificationsPlugin.cancel(_dailyReminderId);
      if (kDebugMode) {
        print('Daily reminder cancelled');
      }
    }
  }

  Future<bool> isDailyReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_dailyReminderKey) ?? false;
  }

  Future<TimeOfDay> getDailyReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString(_dailyReminderTimeKey) ?? '20:00';
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> _scheduleDailyReminder(TimeOfDay time) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (kDebugMode) {
      print('Current time: $now');
      print('Initial scheduled date: $scheduledDate');
    }

    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
      if (kDebugMode) {
        print('Time has passed today, scheduling for tomorrow: $scheduledDate');
      }
    } else {
      if (kDebugMode) {
        print('Scheduling for today: $scheduledDate');
      }
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      _reminderChannelId,
      _reminderChannelName,
      channelDescription: _reminderChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'snooze',
          'Snooze (10 min)',
          icon: DrawableResourceAndroidBitmap('ic_snooze'),
        ),
        AndroidNotificationAction(
          'dismiss',
          'Dismiss',
          icon: DrawableResourceAndroidBitmap('ic_dismiss'),
        ),
      ],
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      categoryIdentifier: 'daily_reminder',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
      macOS: iOSPlatformChannelSpecifics,
    );

    final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);
    
    if (kDebugMode) {
      print('Scheduling notification for: $tzDateTime');
      print('Timezone: ${tz.local.name}');
      print('Current timezone offset: ${tz.local.currentTimeZone.offset}');
    }

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        _dailyReminderId,
        'Daily Check-in Reminder',
        'Time for your daily reflection and goal tracking!',
        tzDateTime,
        platformChannelSpecifics,
        payload: 'daily_reminder',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      
      if (kDebugMode) {
        print('Daily reminder scheduled successfully with exactAllowWhileIdle mode');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error scheduling with exactAllowWhileIdle: $e');
      }
      
      // If exact alarms are not permitted, fall back to inexact scheduling
      if (e.toString().contains('exact_alarms_not_permitted')) {
        if (kDebugMode) {
          print('Falling back to alarmClock mode');
        }
        
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          _dailyReminderId,
          'Daily Check-in Reminder',
          'Time for your daily reflection and goal tracking!',
          tzDateTime,
          platformChannelSpecifics,
          payload: 'daily_reminder',
          androidScheduleMode: AndroidScheduleMode.alarmClock,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
        
        if (kDebugMode) {
          print('Daily reminder scheduled successfully with alarmClock mode');
        }
      } else {
        if (kDebugMode) {
          print('Rethrowing error: $e');
        }
        rethrow;
      }
    }
  }

  // Task Reminder Methods
  Future<void> setTaskReminder({
    required String taskId,
    required String taskTitle,
    required DateTime reminderTime,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final taskReminders = await _getTaskReminders();
    
    taskReminders[taskId] = {
      'title': taskTitle,
      'time': reminderTime.toIso8601String(),
    };
    
    await prefs.setString(_taskRemindersKey, jsonEncode(taskReminders));
    await _scheduleTaskReminder(taskId, taskTitle, reminderTime);
  }

  Future<void> removeTaskReminder(String taskId) async {
    final prefs = await SharedPreferences.getInstance();
    final taskReminders = await _getTaskReminders();
    
    taskReminders.remove(taskId);
    await prefs.setString(_taskRemindersKey, jsonEncode(taskReminders));
    await _flutterLocalNotificationsPlugin.cancel(taskId.hashCode);
  }

  Future<Map<String, dynamic>> _getTaskReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final remindersJson = prefs.getString(_taskRemindersKey) ?? '{}';
    return Map<String, dynamic>.from(jsonDecode(remindersJson));
  }

  Future<void> _scheduleTaskReminder(
    String taskId,
    String taskTitle,
    DateTime reminderTime,
  ) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      _reminderChannelId,
      _reminderChannelName,
      channelDescription: _reminderChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'snooze_task',
          'Snooze (10 min)',
          icon: DrawableResourceAndroidBitmap('ic_snooze'),
        ),
        AndroidNotificationAction(
          'complete_task',
          'Mark Complete',
          icon: DrawableResourceAndroidBitmap('ic_check'),
        ),
      ],
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      categoryIdentifier: 'task_reminder',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
      macOS: iOSPlatformChannelSpecifics,
    );

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        taskId.hashCode,
        'Task Reminder',
        'Don\'t forget: $taskTitle',
        tz.TZDateTime.from(reminderTime, tz.local),
        platformChannelSpecifics,
        payload: 'task_reminder:$taskId',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      // If exact alarms are not permitted, fall back to inexact scheduling
      if (e.toString().contains('exact_alarms_not_permitted')) {
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          taskId.hashCode,
          'Task Reminder',
          'Don\'t forget: $taskTitle',
          tz.TZDateTime.from(reminderTime, tz.local),
          platformChannelSpecifics,
          payload: 'task_reminder:$taskId',
          androidScheduleMode: AndroidScheduleMode.alarmClock,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } else {
        rethrow;
      }
    }
  }

  // Snooze and Action Methods
  Future<void> snoozeDailyReminder() async {
    await _flutterLocalNotificationsPlugin.cancel(_dailyReminderId);
    
    final snoozeTime = DateTime.now().add(const Duration(minutes: 10));
    
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      _reminderChannelId,
      _reminderChannelName,
      channelDescription: _reminderChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        _dailyReminderId + 1, // Different ID for snoozed notification
        'Daily Check-in Reminder (Snoozed)',
        'Time for your daily reflection and goal tracking!',
        tz.TZDateTime.from(snoozeTime, tz.local),
        platformChannelSpecifics,
        payload: 'daily_reminder_snoozed',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      // If exact alarms are not permitted, fall back to inexact scheduling
      if (e.toString().contains('exact_alarms_not_permitted')) {
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          _dailyReminderId + 1, // Different ID for snoozed notification
          'Daily Check-in Reminder (Snoozed)',
          'Time for your daily reflection and goal tracking!',
          tz.TZDateTime.from(snoozeTime, tz.local),
          platformChannelSpecifics,
          payload: 'daily_reminder_snoozed',
          androidScheduleMode: AndroidScheduleMode.alarmClock,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } else {
        rethrow;
      }
    }
  }

  Future<void> snoozeTaskReminder(String taskId) async {
    await _flutterLocalNotificationsPlugin.cancel(taskId.hashCode);
    
    final taskReminders = await _getTaskReminders();
    final taskData = taskReminders[taskId];
    
    if (taskData != null) {
      final snoozeTime = DateTime.now().add(const Duration(minutes: 10));
      await _scheduleTaskReminder(
        '${taskId}_snoozed',
        taskData['title'],
        snoozeTime,
      );
    }
  }

  Future<void> dismissDailyReminder() async {
    await _flutterLocalNotificationsPlugin.cancel(_dailyReminderId);
    await _flutterLocalNotificationsPlugin.cancel(_dailyReminderId + 1); // Also cancel snoozed
  }

  Future<void> dismissTaskReminder(String taskId) async {
    await _flutterLocalNotificationsPlugin.cancel(taskId.hashCode);
    await removeTaskReminder(taskId);
  }

  // Get all scheduled reminders
  Future<List<Map<String, dynamic>>> getPendingReminders() async {
    final pendingRequests = await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
    final taskReminders = await _getTaskReminders();
    final List<Map<String, dynamic>> reminders = [];
    
    // Add daily reminder if enabled
    final isDailyEnabled = await isDailyReminderEnabled();
    if (isDailyEnabled) {
      final dailyTime = await getDailyReminderTime();
      reminders.add({
        'type': 'daily',
        'time': dailyTime,
        'enabled': true,
      });
    }
    
    // Add task reminders
    for (final entry in taskReminders.entries) {
      final taskId = entry.key;
      final taskData = entry.value as Map<String, dynamic>;
      reminders.add({
        'type': 'task',
        'taskId': int.tryParse(taskId) ?? 0,
        'title': taskData['title'],
        'scheduledDate': DateTime.parse(taskData['time']),
      });
    }
    
    return reminders;
  }
}
