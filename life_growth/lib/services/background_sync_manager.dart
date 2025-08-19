import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:workmanager/workmanager.dart';
import 'notification_service.dart';
import 'background_task_handler.dart' as bg_handler;
import 'supabase_service.dart';
import 'auth_service.dart';

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

      // Initialize WorkManager only on supported platforms
      if (_isWorkManagerSupported()) {
        await Workmanager().initialize(
          bg_handler
              .callbackDispatcher, // Use the callback dispatcher from background_task_handler.dart
        );

        // Add a small delay to ensure WorkManager is fully initialized
        await Future.delayed(const Duration(milliseconds: 300));
      } else {
        if (kDebugMode) {
          print(
              'WorkManager not supported on this platform, using alternative sync method');
        }
      }

      _isInitialized = true;

      if (kDebugMode) {
        print('BackgroundSyncManager initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize BackgroundSyncManager: $e');
      }
      // Don't rethrow to prevent app crashes during initialization
      // rethrow;
    }
  }

  Future<void> schedulePeriodicSync() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      if (_isWorkManagerSupported()) {
        // Add a small delay to ensure WorkManager is fully ready
        await Future.delayed(const Duration(milliseconds: 500));

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
      } else {
        if (kDebugMode) {
          print('Periodic sync not available on this platform');
        }
      }

      if (kDebugMode) {
        print('Periodic sync scheduled successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to schedule periodic sync: $e');
      }
      // Don't show notification for initialization errors to avoid user confusion
      // await NotificationService().showSyncErrorNotification(
      //   'Failed to schedule background sync: $e',
      // );
    }
  }

  Future<void> scheduleImmediateSync() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      if (_isWorkManagerSupported()) {
        // Add a small delay to ensure WorkManager is fully ready
        await Future.delayed(const Duration(milliseconds: 200));

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
      } else {
        // Perform immediate sync directly on unsupported platforms
        await _performDirectSync();
      }

      if (kDebugMode) {
        print('Immediate sync scheduled successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to schedule immediate sync: $e');
      }
      // Only show notification for immediate sync errors if it's not an initialization issue
      if (_isInitialized) {
        await NotificationService().showSyncErrorNotification(
          'Failed to start sync: $e',
        );
      }
    }
  }

  Future<void> cancelAllSyncTasks() async {
    try {
      if (_isWorkManagerSupported()) {
        await Workmanager().cancelAll();
      }

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
      if (_isWorkManagerSupported()) {
        await Workmanager().cancelByUniqueName(_periodicSyncTaskName);
      }

      if (kDebugMode) {
        print('Periodic sync cancelled');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to cancel periodic sync: $e');
      }
    }
  }

  /// Check if WorkManager is supported on the current platform
  bool _isWorkManagerSupported() {
    // WorkManager is supported on Android and iOS, but not on Windows, macOS, Linux, or Web
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Perform direct sync for platforms that don't support WorkManager
  Future<void> _performDirectSync() async {
    try {
      if (!AuthService.isAuthenticated) {
        if (kDebugMode) {
          print('User not authenticated, skipping sync');
        }
        return;
      }

      final userId = AuthService.userId;
      if (userId == null || userId.isEmpty) {
        if (kDebugMode) {
          print('No user ID available, skipping sync');
        }
        return;
      }

      if (kDebugMode) {
        print('Performing direct sync for user: $userId');
      }

      await SupabaseService.syncAllPendingChanges(userId);

      if (kDebugMode) {
        print('Direct sync completed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Direct sync failed: $e');
      }
      rethrow;
    }
  }

  bool get isInitialized => _isInitialized;

  /// Start background sync when app goes to background
  Future<void> startBackgroundSync() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Only start background sync if user is authenticated
      if (!AuthService.isAuthenticated) {
        if (kDebugMode) {
          print('User not authenticated, skipping background sync start');
        }
        return;
      }

      // Schedule periodic sync for background operation
      await schedulePeriodicSync();

      if (kDebugMode) {
        print('Background sync started successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to start background sync: $e');
      }
    }
  }

  /// Stop background sync when app comes to foreground
  Future<void> stopBackgroundSync() async {
    try {
      // Cancel periodic sync tasks
      await cancelPeriodicSync();

      if (kDebugMode) {
        print('Background sync stopped successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to stop background sync: $e');
      }
    }
  }

  /// Perform immediate sync when app comes to foreground
  Future<void> performSync() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Only perform sync if user is authenticated
      if (!AuthService.isAuthenticated) {
        if (kDebugMode) {
          print('User not authenticated, skipping sync');
        }
        return;
      }

      // Perform immediate sync
      await scheduleImmediateSync();

      if (kDebugMode) {
        print('Immediate sync performed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to perform sync: $e');
      }
    }
  }
}
