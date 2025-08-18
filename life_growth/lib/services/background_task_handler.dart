import 'package:workmanager/workmanager.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'supabase_service.dart';
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
      // Initialize Supabase in background context if not already initialized
      await _initializeSupabaseInBackground();

      // Check if Supabase is now initialized
      try {
        Supabase.instance.client;
      } catch (e) {
        if (kDebugMode) {
          print('Supabase initialization failed in background task: $e');
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
      if (userId == null || userId.isEmpty) {
        if (kDebugMode) {
          print('No user ID available, skipping background sync');
        }
        return true;
      }

      // Initialize notification service
      final notificationService = NotificationService();
      await notificationService.initialize();

      // Perform sync based on task type
      switch (task) {
        case 'life_growth_sync':
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
            'Background sync failed: ${e.toString()}');
      } catch (notificationError) {
        if (kDebugMode) {
          print('Failed to show error notification: $notificationError');
        }
      }

      return Future.value(false);
    }
  });
}

/// Initialize Supabase in background context
/// Background tasks run in isolated Dart isolates and need their own initialization
Future<void> _initializeSupabaseInBackground() async {
  try {
    // Check if already initialized
    try {
      Supabase.instance.client;
      return; // Already initialized
    } catch (_) {
      // Not initialized, proceed with initialization
    }

    // Load environment variables
    await dotenv.load(fileName: ".env");

    // Get Supabase configuration
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl != null && supabaseAnonKey != null) {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );

      if (kDebugMode) {
        print('Supabase initialized successfully in background context');
      }
    } else {
      if (kDebugMode) {
        print('Supabase configuration not found in environment variables');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Failed to initialize Supabase in background context: $e');
    }
    // Don't rethrow - let the background task continue without Supabase
  }
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

    // Use the daily_tasks-focused sync to avoid errors from non-existent tables
    await SupabaseService.syncAllPendingChanges(userId);

    // Be silent on success to reduce notification noise
    if (kDebugMode) {
      print('Background sync completed successfully.');
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
