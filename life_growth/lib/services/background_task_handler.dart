import 'package:workmanager/workmanager.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'sync_service.dart';
import 'notification_service.dart';
import 'auth_service.dart';

/// Background task handler for WorkManager
/// This function is called by WorkManager to execute background sync tasks
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (kDebugMode) {
      print('Background task started: $task');
    }

    try {
      // Check if Supabase is initialized
      try {
        Supabase.instance.client;
      } catch (e) {
        if (kDebugMode) {
          print('Supabase not initialized in background task: $e');
        }
        return true;
      }

      // Check if user is authenticated
      if (!AuthService.isAuthenticated) {
        if (kDebugMode) {
          print('User not authenticated, skipping background sync');
        }
        return true;
      }

      final userId = AuthService.userId;
      if (userId == null) {
        if (kDebugMode) {
          print('No user ID available, skipping background sync');
        }
        return Future.value(true);
      }

      // Initialize notification service
      final notificationService = NotificationService();
      await notificationService.initialize();

      // Perform sync based on task type
      switch (task) {
        case 'periodic_sync':
        case 'immediate_sync':
          await _performBackgroundSync(userId, notificationService);
          break;
        default:
          if (kDebugMode) {
            print('Unknown background task: $task');
          }
      }

      if (kDebugMode) {
        print('Background task completed successfully: $task');
      }
      return Future.value(true);
    } catch (e) {
      if (kDebugMode) {
        print('Background task failed: $task, error: $e');
      }
      
      // Show error notification
      try {
        final notificationService = NotificationService();
        await notificationService.initialize();
        await notificationService.showSyncErrorNotification(
          'Background sync failed: ${e.toString()}'
        );
      } catch (notificationError) {
        if (kDebugMode) {
          print('Failed to show error notification: $notificationError');
        }
      }
      
      return Future.value(false);
    }
  });
}

/// Performs the actual background synchronization
Future<void> _performBackgroundSync(
  String userId,
  NotificationService notificationService,
) async {
  try {
    if (kDebugMode) {
      print('Starting background sync for user: $userId');
    }

    // Initialize sync service for background tasks
    final syncService = SyncService.background();
    
    // Perform synchronization
    final result = await syncService.performFullSync(userId);
    
    if (result.hasConflicts) {
      // Show conflict notification
      await notificationService.showConflictResolvedNotification(
        result.conflictMessages.length,
      );
      
      if (kDebugMode) {
        print('Background sync completed with conflicts');
      }
    } else if (result.hasErrors) {
      // Show error notification
      await notificationService.showSyncErrorNotification(
        'Some data failed to sync. Please check your connection.',
      );
      
      if (kDebugMode) {
        print('Background sync completed with errors');
      }
    } else {
      // Show success notification (optional, can be disabled for less intrusive UX)
      if (result.syncedItemsCount > 0) {
        await notificationService.showSyncSuccessNotification();
      }
      
      if (kDebugMode) {
        print('Background sync completed successfully. Synced ${result.syncedItemsCount} items');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Background sync failed: $e');
    }
    
    // Show error notification
    await notificationService.showSyncErrorNotification(
      'Background sync failed: ${e.toString()}',
    );
    
    rethrow;
  }
}

/// Result class for sync operations
class SyncResult {
  final bool hasConflicts;
  final bool hasErrors;
  final int syncedItemsCount;
  final List<String> errorMessages;
  final List<String> conflictMessages;

  const SyncResult({
    this.hasConflicts = false,
    this.hasErrors = false,
    this.syncedItemsCount = 0,
    this.errorMessages = const [],
    this.conflictMessages = const [],
  });

  bool get isSuccess => !hasConflicts && !hasErrors;
}