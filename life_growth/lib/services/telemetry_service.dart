import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class TelemetryService {
  static final TelemetryService _instance = TelemetryService._internal();
  factory TelemetryService() => _instance;
  TelemetryService._internal();

  late FirebaseAnalytics _analytics;
  late FirebaseAnalyticsObserver _observer;

  FirebaseAnalyticsObserver get observer => _observer;

  Future<void> initialize() async {
    try {
      _analytics = FirebaseAnalytics.instance;
      _observer = FirebaseAnalyticsObserver(analytics: _analytics);
      
      // Set analytics collection enabled
      await _analytics.setAnalyticsCollectionEnabled(true);
      
      // Send a test event to verify Firebase Analytics is working
      await _analytics.logEvent(
        name: 'app_initialized',
        parameters: {
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'platform': 'flutter',
        },
      );
      
      if (kDebugMode) {
        print('TelemetryService: Firebase Analytics initialized successfully');
        print('TelemetryService: Test event sent to verify analytics');
      }
    } catch (e) {
      if (kDebugMode) {
        print('TelemetryService: Failed to initialize Firebase Analytics: $e');
        print('TelemetryService: Stack trace: ${StackTrace.current}');
      }
      rethrow;
    }
  }

  // Track task toggle events
  Future<void> trackTaskToggle({
    required String taskId,
    required bool isCompleted,
    String? category,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'task_toggle',
        parameters: {
          'task_id': taskId,
          'is_completed': isCompleted,
          'category': category ?? 'unknown',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('TelemetryService: Failed to track task toggle: $e');
      }
    }
  }

  // Track detail edits
  Future<void> trackDetailEdit({
    required String itemType,
    required String itemId,
    String? editType,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'detail_edit',
        parameters: {
          'item_type': itemType,
          'item_id': itemId,
          'edit_type': editType ?? 'unknown',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('TelemetryService: Failed to track detail edit: $e');
      }
    }
  }

  // Track task detail edits
  Future<void> trackTaskDetailEdit({
    required DateTime taskDate,
    required int completedTasksCount,
    required bool hasNotes,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'task_detail_edit',
        parameters: {
          'task_date': taskDate.toIso8601String(),
          'completed_tasks_count': completedTasksCount,
          'has_notes': hasNotes,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('TelemetryService: Failed to track task detail edit: $e');
      }
    }
  }

  // Track authentication events
  Future<void> trackAuthEvent({
    required String eventType,
    required String method,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final parameters = <String, Object>{
        'event_type': eventType,
        'auth_method': method,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      if (additionalData != null) {
        additionalData.forEach((key, value) {
          if (value != null) {
            parameters[key] = value;
          }
        });
      }
      
      await _analytics.logEvent(
        name: 'auth_event',
        parameters: parameters,
      );
    } catch (e) {
      if (kDebugMode) {
        print('TelemetryService: Failed to track auth event: $e');
      }
    }
  }

  // Track sync events
  Future<void> trackSyncStart() async {
    try {
      await _analytics.logEvent(
        name: 'sync_start',
        parameters: {
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('TelemetryService: Failed to track sync start: $e');
      }
    }
  }

  Future<void> trackSyncFinish({
    required bool success,
    String? errorMessage,
    int? itemsSync,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'sync_finish',
        parameters: {
          'success': success,
          'error_message': errorMessage ?? 'none',
          'items_synced': itemsSync ?? 0,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('TelemetryService: Failed to track sync finish: $e');
      }
    }
  }

  // Track errors
  Future<void> trackError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final parameters = <String, Object>{
        'error_type': errorType,
        'error_message': errorMessage,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      if (stackTrace != null) {
        parameters['stack_trace'] = stackTrace.substring(0, stackTrace.length > 500 ? 500 : stackTrace.length);
      }
      
      if (additionalData != null) {
        additionalData.forEach((key, value) {
          if (value != null) {
            parameters[key] = value;
          }
        });
      }
      
      await _analytics.logEvent(
        name: 'app_error',
        parameters: parameters,
      );
    } catch (e) {
      if (kDebugMode) {
        print('TelemetryService: Failed to track error: $e');
      }
    }
  }

  // Track screen views
  Future<void> trackScreenView(String screenName) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenName,
      );
    } catch (e) {
      if (kDebugMode) {
        print('TelemetryService: Failed to track screen view: $e');
      }
    }
  }

  // Track user properties
  Future<void> setUserProperty(String name, String value) async {
    try {
      await _analytics.setUserProperty(
        name: name,
        value: value,
      );
    } catch (e) {
      if (kDebugMode) {
        print('TelemetryService: Failed to set user property: $e');
      }
    }
  }
}