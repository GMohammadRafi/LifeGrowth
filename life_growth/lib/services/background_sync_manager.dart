import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'notification_service.dart';
import 'background_task_handler.dart' as bg_handler;

class BackgroundSyncManager {
  static const String _syncTaskName = 'life_growth_sync';
  static const String _periodicSyncTaskName = 'life_growth_periodic_sync';

  static final BackgroundSyncManager _instance =
      BackgroundSyncManager._internal();
  factory BackgroundSyncManager() => _instance;
  BackgroundSyncManager._internal();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize notifications first
      await NotificationService().initialize();
      await NotificationService().requestPermissions();

      // Initialize WorkManager
      await Workmanager().initialize(
        bg_handler
            .callbackDispatcher, // Use the callback dispatcher from background_task_handler.dart
      );

      _isInitialized = true;

      if (kDebugMode) {
        print('BackgroundSyncManager initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize BackgroundSyncManager: $e');
      }
      rethrow;
    }
  }

  Future<void> schedulePeriodicSync() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Cancel any existing periodic sync
      await Workmanager().cancelByUniqueName(_periodicSyncTaskName);

      // Schedule new periodic sync every 15 minutes
      await Workmanager().registerPeriodicTask(
        _periodicSyncTaskName,
        _syncTaskName,
        frequency: const Duration(minutes: 15),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
        ),
        inputData: {
          'sync_type': 'periodic',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );

      if (kDebugMode) {
        print('Periodic sync scheduled successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to schedule periodic sync: $e');
      }
      await NotificationService().showSyncErrorNotification(
        'Failed to schedule background sync: $e',
      );
    }
  }

  Future<void> scheduleImmediateSync() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await Workmanager().registerOneOffTask(
        'immediate_sync_${DateTime.now().millisecondsSinceEpoch}',
        _syncTaskName,
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
        inputData: {
          'sync_type': 'immediate',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );

      if (kDebugMode) {
        print('Immediate sync scheduled successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to schedule immediate sync: $e');
      }
      await NotificationService().showSyncErrorNotification(
        'Failed to start sync: $e',
      );
    }
  }

  Future<void> cancelAllSyncTasks() async {
    try {
      await Workmanager().cancelAll();

      if (kDebugMode) {
        print('All sync tasks cancelled');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to cancel sync tasks: $e');
      }
    }
  }

  Future<void> cancelPeriodicSync() async {
    try {
      await Workmanager().cancelByUniqueName(_periodicSyncTaskName);

      if (kDebugMode) {
        print('Periodic sync cancelled');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to cancel periodic sync: $e');
      }
    }
  }

  bool get isInitialized => _isInitialized;
}
