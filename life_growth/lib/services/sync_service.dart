import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:drift/drift.dart';
import '../database/database.dart';

import '../database/tables.dart';
import 'auth_service.dart';
import 'background_task_handler.dart';

class SyncService {
  static const String _syncTaskName = 'background_sync';
  static const String _syncChannelId = 'sync_notifications';
  static const String _syncChannelName = 'Sync Notifications';

  final AppDatabase? _database;
  final FlutterLocalNotificationsPlugin? _notificationsPlugin;

  SyncService({
    AppDatabase? database,
    FlutterLocalNotificationsPlugin? notificationsPlugin,
  })  : _database = database,
        _notificationsPlugin = notificationsPlugin;

  /// Default constructor for background tasks
  SyncService.background()
      : _database = null,
        _notificationsPlugin = null;

  /// Initialize the sync service
  Future<void> initialize() async {
    await _initializeNotifications();
    await _initializeWorkManager();
  }

  /// Initialize local notifications
  Future<void> _initializeNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin?.initialize(initSettings);

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      _syncChannelId,
      _syncChannelName,
      description: 'Notifications for data synchronization',
      importance: Importance.low,
    );

    await _notificationsPlugin
        ?.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Initialize WorkManager for background tasks
  Future<void> _initializeWorkManager() async {
    await Workmanager().initialize(
      callbackDispatcher,
    );
  }

  /// Start periodic background sync
  Future<void> startPeriodicSync() async {
    await Workmanager().registerPeriodicTask(
      'sync_task',
      _syncTaskName,
      frequency: const Duration(hours: 1), // Sync every hour
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
    );
  }

  /// Stop background sync
  Future<void> stopPeriodicSync() async {
    await Workmanager().cancelByUniqueName('sync_task');
  }

  /// Perform manual sync
  Future<SyncResult> performSync() async {
    try {
      if (!await AuthService.hasValidSession()) {
        return SyncResult(
          hasErrors: true,
          syncedItemsCount: 0,
          errorMessages: ['User not authenticated'],
        );
      }

      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        return SyncResult(
          hasErrors: true,
          syncedItemsCount: 0,
          errorMessages: ['User ID not available'],
        );
      }

      return await performFullSync(userId);
    } catch (e) {
      return SyncResult(
        hasErrors: true,
        syncedItemsCount: 0,
        errorMessages: ['Sync failed: ${e.toString()}'],
      );
    }
  }

  /// Perform full synchronization for background tasks
  /// Returns detailed sync result with conflict and error information
  Future<SyncResult> performFullSync(String userId) async {
    try {
      if (kDebugMode) {
        print('Starting full sync for user: $userId');
      }

      final supabase = Supabase.instance.client;

      if (supabase.auth.currentUser?.id != userId) {
        throw Exception('User authentication mismatch');
      }

      int totalSynced = 0;
      int totalConflicts = 0;
      bool hasErrors = false;
      List<String> errorMessages = [];
      List<String> conflictMessages = [];

      // Sync habits
      try {
        final habitResult = await _syncHabits(userId);
        totalSynced += habitResult.syncedItemsCount;
        if (habitResult.hasConflicts) {
          totalConflicts += habitResult.conflictMessages.length;
          conflictMessages.addAll(habitResult.conflictMessages);
        }
        if (habitResult.hasErrors) {
          hasErrors = true;
          errorMessages.addAll(habitResult.errorMessages);
        }
      } catch (e) {
        hasErrors = true;
        errorMessages.add('Habits sync failed: ${e.toString()}');
        if (kDebugMode) {
          print('Habits sync failed: $e');
        }
      }

      // Sync daily check-ins
      try {
        final checkinResult = await _syncDailyCheckins(userId);
        totalSynced += checkinResult.syncedItemsCount;
        if (checkinResult.hasConflicts) {
          totalConflicts += checkinResult.conflictMessages.length;
          conflictMessages.addAll(checkinResult.conflictMessages);
        }
        if (checkinResult.hasErrors) {
          hasErrors = true;
          errorMessages.addAll(checkinResult.errorMessages);
        }
      } catch (e) {
        hasErrors = true;
        errorMessages.add('Check-ins sync failed: ${e.toString()}');
        if (kDebugMode) {
          print('Check-ins sync failed: $e');
        }
      }

      // Sync goals
      try {
        final goalResult = await _syncGoals(userId);
        totalSynced += goalResult.syncedItemsCount;
        if (goalResult.hasConflicts) {
          totalConflicts += goalResult.conflictMessages.length;
          conflictMessages.addAll(goalResult.conflictMessages);
        }
        if (goalResult.hasErrors) {
          hasErrors = true;
          errorMessages.addAll(goalResult.errorMessages);
        }
      } catch (e) {
        hasErrors = true;
        errorMessages.add('Goals sync failed: ${e.toString()}');
        if (kDebugMode) {
          print('Goals sync failed: $e');
        }
      }

      // Sync journal entries
      try {
        final journalResult = await _syncJournalEntries(userId);
        totalSynced += journalResult.syncedItemsCount;
        if (journalResult.hasConflicts) {
          totalConflicts += journalResult.conflictMessages.length;
          conflictMessages.addAll(journalResult.conflictMessages);
        }
        if (journalResult.hasErrors) {
          hasErrors = true;
          errorMessages.addAll(journalResult.errorMessages);
        }
      } catch (e) {
        hasErrors = true;
        errorMessages.add('Journal sync failed: ${e.toString()}');
        if (kDebugMode) {
          print('Journal sync failed: $e');
        }
      }

      final result = SyncResult(
        hasConflicts: totalConflicts > 0,
        hasErrors: hasErrors,
        syncedItemsCount: totalSynced,
        errorMessages: errorMessages,
        conflictMessages: conflictMessages,
      );

      if (kDebugMode) {
        print('Full sync completed: $result');
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Full sync failed: $e');
      }

      return SyncResult(
        hasConflicts: false,
        hasErrors: true,
        syncedItemsCount: 0,
        errorMessages: [e.toString()],
        conflictMessages: [],
      );
    }
  }

  /// Sync habits with conflict resolution
  Future<SyncResult> _syncHabits(String userId) async {
    try {
      final supabase = Supabase.instance.client;
      int synced = 0;
      int conflicts = 0;

      // Get local habits that need syncing
      final localHabits = await _database?.getHabitsToSync(userId) ?? [];

      for (final habit in localHabits) {
        try {
          // Convert to JSON for Supabase
          final habitJson = {
            'id': habit.id,
            'user_id': userId,
            'name': habit.name,
            'description': habit.description,
            'frequency': habit.frequency.toString().split('.').last,
            'is_active': habit.isActive,
            'created_at': habit.createdAt.toIso8601String(),
            'updated_at': habit.updatedAt.toIso8601String(),
          };

          // Upload to Supabase
          await supabase.from('habits').upsert(habitJson);

          // Mark as synced locally
          await _database?.markHabitAsSynced(habit.id);
          synced++;
        } catch (e) {
          if (kDebugMode) {
            print('Failed to sync habit ${habit.id}: $e');
          }
        }
      }

      // Download from Supabase and update local database
      final remoteHabits = await supabase
          .from('habits')
          .select()
          .eq('user_id', userId)
          .order('updated_at', ascending: false);

      for (final habitData in remoteHabits) {
        final habitId = habitData['id'] as String;
        final localHabit = await _database?.getHabit(habitId);
        final remoteUpdatedAt = DateTime.parse(habitData['updated_at']);

        if (localHabit == null ||
            remoteUpdatedAt.isAfter(localHabit.updatedAt)) {
          // Remote is newer or doesn't exist locally
          final habitCompanion = HabitsCompanion(
            id: Value(habitData['id']),
            userId: Value(habitData['user_id']),
            name: Value(habitData['name']),
            description: Value(habitData['description']),
            frequency: Value(HabitFrequency.values.firstWhere(
              (e) => e.toString().split('.').last == habitData['frequency'],
              orElse: () => HabitFrequency.daily,
            )),
            isActive: Value(habitData['is_active']),
            createdAt: Value(DateTime.parse(habitData['created_at'])),
            updatedAt: Value(remoteUpdatedAt),
            needsSync: const Value(false),
            lastSyncAt: Value(DateTime.now()),
          );
          await _database?.upsertHabit(habitCompanion);
          synced++;
        } else if (localHabit.updatedAt.isAfter(remoteUpdatedAt) &&
            localHabit.needsSync) {
          // Local is newer, upload to remote
          final habitJson = {
            'id': localHabit.id,
            'user_id': localHabit.userId,
            'name': localHabit.name,
            'description': localHabit.description,
            'frequency': localHabit.frequency.toString().split('.').last,
            'is_active': localHabit.isActive,
            'created_at': localHabit.createdAt.toIso8601String(),
            'updated_at': localHabit.updatedAt.toIso8601String(),
          };
          await supabase.from('habits').upsert(habitJson);
          await _database?.markHabitAsSynced(habitId);
          conflicts++;
        }
      }

      return SyncResult(
        hasConflicts: conflicts > 0,
        hasErrors: false,
        syncedItemsCount: synced,
        errorMessages: [],
        conflictMessages: conflicts > 0 ? ['Habits: $conflicts conflicts'] : [],
      );
    } catch (e) {
      return SyncResult(
        hasConflicts: false,
        hasErrors: true,
        syncedItemsCount: 0,
        errorMessages: ['Habit sync failed: ${e.toString()}'],
        conflictMessages: [],
      );
    }
  }

  /// Sync daily check-ins with conflict resolution
  Future<SyncResult> _syncDailyCheckins(String userId) async {
    try {
      final supabase = Supabase.instance.client;
      int synced = 0;
      int conflicts = 0;

      // Get local check-ins that need syncing
      final localCheckins =
          await _database?.getDailyCheckinsToSync(userId) ?? [];

      for (final checkin in localCheckins) {
        try {
          // Convert to JSON for Supabase
          final checkinJson = {
            'id': checkin.id,
            'user_id': userId,
            'date': checkin.date.toIso8601String(),
            'mood': checkin.mood,
            'energy': checkin.energy,
            'stress': checkin.stress,
            'notes': checkin.notes,
            'created_at': checkin.createdAt.toIso8601String(),
            'updated_at': checkin.updatedAt.toIso8601String(),
          };

          // Upload to Supabase
          await supabase.from('daily_checkins').upsert(checkinJson);

          // Mark as synced locally
          await _database?.markDailyCheckinAsSynced(checkin.id);
          synced++;
        } catch (e) {
          if (kDebugMode) {
            print('Failed to sync daily checkin ${checkin.id}: $e');
          }
        }
      }

      // Download from Supabase and update local database
      final remoteCheckins = await supabase
          .from('daily_checkins')
          .select()
          .eq('user_id', userId)
          .order('updated_at', ascending: false);

      for (final checkinData in remoteCheckins) {
        final checkinId = checkinData['id'] as String;
        final localCheckin = await _database?.getDailyCheckin(checkinId);
        final remoteUpdatedAt = DateTime.parse(checkinData['updated_at']);

        if (localCheckin == null ||
            remoteUpdatedAt.isAfter(localCheckin.updatedAt)) {
          // Remote is newer or doesn't exist locally
          final checkinCompanion = DailyCheckinsCompanion(
            id: Value(checkinData['id']),
            userId: Value(checkinData['user_id']),
            date: Value(DateTime.parse(checkinData['date'])),
            mood: Value(checkinData['mood']),
            energy: Value(checkinData['energy']),
            stress: Value(checkinData['stress']),
            notes: Value(checkinData['notes']),
            createdAt: Value(DateTime.parse(checkinData['created_at'])),
            updatedAt: Value(remoteUpdatedAt),
            needsSync: const Value(false),
            lastSyncAt: Value(DateTime.now()),
          );
          await _database?.upsertDailyCheckin(checkinCompanion);
          synced++;
        } else if (localCheckin.updatedAt.isAfter(remoteUpdatedAt) &&
            localCheckin.needsSync) {
          // Local is newer, upload to remote
          final checkinJson = {
            'id': localCheckin.id,
            'user_id': localCheckin.userId,
            'date': localCheckin.date.toIso8601String(),
            'mood': localCheckin.mood,
            'energy': localCheckin.energy,
            'stress': localCheckin.stress,
            'notes': localCheckin.notes,
            'created_at': localCheckin.createdAt.toIso8601String(),
            'updated_at': localCheckin.updatedAt.toIso8601String(),
          };
          await supabase.from('daily_checkins').upsert(checkinJson);
          await _database?.markDailyCheckinAsSynced(checkinId);
          conflicts++;
        }
      }

      return SyncResult(
        hasConflicts: conflicts > 0,
        hasErrors: false,
        syncedItemsCount: synced,
        errorMessages: [],
        conflictMessages:
            conflicts > 0 ? ['Daily check-ins: $conflicts conflicts'] : [],
      );
    } catch (e) {
      return SyncResult(
        hasConflicts: false,
        hasErrors: true,
        syncedItemsCount: 0,
        errorMessages: ['Daily check-in sync failed: ${e.toString()}'],
        conflictMessages: [],
      );
    }
  }

  /// Sync goals with conflict resolution
  Future<SyncResult> _syncGoals(String userId) async {
    try {
      final supabase = Supabase.instance.client;
      int synced = 0;
      int conflicts = 0;

      // Get local goals that need syncing
      final localGoals = await _database?.getGoalsToSync(userId) ?? [];

      for (final goal in localGoals) {
        try {
          // Convert to JSON for Supabase
          final goalJson = {
            'id': goal.id,
            'user_id': userId,
            'title': goal.title,
            'description': goal.description,
            'category': goal.category.toString().split('.').last,
            'target_date': goal.targetDate.toIso8601String(),
            'is_completed': goal.isCompleted,
            'created_at': goal.createdAt.toIso8601String(),
            'updated_at': goal.updatedAt.toIso8601String(),
          };

          // Upload to Supabase
          await supabase.from('goals').upsert(goalJson);

          // Mark as synced locally
          await _database?.markGoalAsSynced(goal.id);
          synced++;
        } catch (e) {
          if (kDebugMode) {
            print('Failed to sync goal ${goal.id}: $e');
          }
        }
      }

      // Download from Supabase and update local database
      final remoteGoals = await supabase
          .from('goals')
          .select()
          .eq('user_id', userId)
          .order('updated_at', ascending: false);

      for (final goalData in remoteGoals) {
        final goalId = goalData['id'] as String;
        final localGoal = await _database?.getGoal(goalId);
        final remoteUpdatedAt = DateTime.parse(goalData['updated_at']);

        if (localGoal == null || remoteUpdatedAt.isAfter(localGoal.updatedAt)) {
          // Remote is newer or doesn't exist locally
          final goalCompanion = GoalsCompanion(
            id: Value(goalData['id']),
            userId: Value(goalData['user_id']),
            title: Value(goalData['title']),
            description: Value(goalData['description']),
            category: Value(GoalCategory.values.firstWhere(
              (e) => e.toString().split('.').last == goalData['category'],
              orElse: () => GoalCategory.personal,
            )),
            targetDate: Value(DateTime.parse(goalData['target_date'])),
            isCompleted: Value(goalData['is_completed']),
            createdAt: Value(DateTime.parse(goalData['created_at'])),
            updatedAt: Value(remoteUpdatedAt),
            needsSync: const Value(false),
            lastSyncAt: Value(DateTime.now()),
          );
          await _database?.upsertGoal(goalCompanion);
          synced++;
        } else if (localGoal.updatedAt.isAfter(remoteUpdatedAt) &&
            localGoal.needsSync) {
          // Local is newer, upload to remote
          final goalJson = {
            'id': localGoal.id,
            'user_id': localGoal.userId,
            'title': localGoal.title,
            'description': localGoal.description,
            'category': localGoal.category.toString().split('.').last,
            'target_date': localGoal.targetDate.toIso8601String(),
            'is_completed': localGoal.isCompleted,
            'created_at': localGoal.createdAt.toIso8601String(),
            'updated_at': localGoal.updatedAt.toIso8601String(),
          };
          await supabase.from('goals').upsert(goalJson);
          await _database?.markGoalAsSynced(goalId);
          conflicts++;
        }
      }

      return SyncResult(
        hasConflicts: conflicts > 0,
        hasErrors: false,
        syncedItemsCount: synced,
        errorMessages: [],
        conflictMessages: conflicts > 0 ? ['Goals: $conflicts conflicts'] : [],
      );
    } catch (e) {
      return SyncResult(
        hasConflicts: false,
        hasErrors: true,
        syncedItemsCount: 0,
        errorMessages: ['Goal sync failed: ${e.toString()}'],
        conflictMessages: [],
      );
    }
  }

  /// Sync journal entries with conflict resolution
  Future<SyncResult> _syncJournalEntries(String userId) async {
    try {
      final supabase = Supabase.instance.client;
      int synced = 0;
      int conflicts = 0;

      // Get local journal entries that need syncing
      final localEntries =
          await _database?.getJournalEntriesToSync(userId) ?? [];

      for (final entry in localEntries) {
        try {
          // Convert to JSON for Supabase
          final entryJson = {
            'id': entry.id,
            'user_id': userId,
            'title': entry.title,
            'content': entry.content,
            'mood': entry.mood,
            'tags': jsonEncode(entry.tags),
            'created_at': entry.createdAt.toIso8601String(),
            'updated_at': entry.updatedAt.toIso8601String(),
          };

          // Upload to Supabase
          await supabase.from('journal_entries').upsert(entryJson);

          // Mark as synced locally
          await _database?.markJournalEntryAsSynced(entry.id);
          synced++;
        } catch (e) {
          if (kDebugMode) {
            print('Failed to sync journal entry ${entry.id}: $e');
          }
        }
      }

      // Download from Supabase and update local database
      final remoteEntries = await supabase
          .from('journal_entries')
          .select()
          .eq('user_id', userId)
          .order('updated_at', ascending: false);

      for (final entryData in remoteEntries) {
        final entryId = entryData['id'] as String;
        final localEntry = await _database?.getJournalEntry(entryId);
        final remoteUpdatedAt = DateTime.parse(entryData['updated_at']);

        if (localEntry == null ||
            remoteUpdatedAt.isAfter(localEntry.updatedAt)) {
          // Remote is newer or doesn't exist locally
          final entryCompanion = JournalEntriesCompanion(
            id: Value(entryData['id']),
            userId: Value(entryData['user_id']),
            title: Value(entryData['title']),
            content: Value(entryData['content']),
            mood: Value(entryData['mood']),
            tags: Value(List<String>.from(jsonDecode(entryData['tags']))),
            createdAt: Value(DateTime.parse(entryData['created_at'])),
            updatedAt: Value(remoteUpdatedAt),
            needsSync: const Value(false),
            lastSyncAt: Value(DateTime.now()),
          );
          await _database?.upsertJournalEntry(entryCompanion);
          synced++;
        } else if (localEntry.updatedAt.isAfter(remoteUpdatedAt) &&
            localEntry.needsSync) {
          // Local is newer, upload to remote
          final entryJson = {
            'id': localEntry.id,
            'user_id': localEntry.userId,
            'title': localEntry.title,
            'content': localEntry.content,
            'mood': localEntry.mood,
            'tags': jsonEncode(localEntry.tags),
            'created_at': localEntry.createdAt.toIso8601String(),
            'updated_at': localEntry.updatedAt.toIso8601String(),
          };
          await supabase.from('journal_entries').upsert(entryJson);
          await _database?.markJournalEntryAsSynced(entryId);
          conflicts++;
        }
      }

      return SyncResult(
        hasConflicts: conflicts > 0,
        hasErrors: false,
        syncedItemsCount: synced,
        errorMessages: [],
        conflictMessages:
            conflicts > 0 ? ['Journal entries: $conflicts conflicts'] : [],
      );
    } catch (e) {
      return SyncResult(
        hasConflicts: false,
        hasErrors: true,
        syncedItemsCount: 0,
        errorMessages: ['Journal entry sync failed: ${e.toString()}'],
        conflictMessages: [],
      );
    }
  }


}

/// Background task callback dispatcher
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Initialize services for background task
      // Note: This is a simplified version - in a real app, you'd need to
      // properly initialize all dependencies in the background context

      switch (task) {
        case 'background_sync':
          // Perform background sync
          // This would need proper initialization of database and auth service
          print('Background sync task executed');
          break;
      }

      return Future.value(true);
    } catch (e) {
      print('Background task failed: $e');
      return Future.value(false);
    }
  });
}
