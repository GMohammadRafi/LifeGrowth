import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'telemetry_service.dart';

class ErrorService {
  static final ErrorService _instance = ErrorService._internal();
  factory ErrorService() => _instance;
  ErrorService._internal();

  final TelemetryService _telemetryService = TelemetryService();

  Future<void> initialize(String dsn) async {
    try {
      await SentryFlutter.init(
        (options) {
          options.dsn = dsn;
          options.debug = kDebugMode;
          options.tracesSampleRate = kDebugMode ? 1.0 : 0.1;
          options.environment = kDebugMode ? 'development' : 'production';
          options.beforeSend = (event, hint) {
            // Filter out debug events in production
            if (!kDebugMode && event.level == SentryLevel.debug) {
              return null;
            }
            return event;
          };
        },
      );
      
      if (kDebugMode) {
        print('ErrorService: Sentry initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('ErrorService: Failed to initialize Sentry: $e');
      }
    }
  }

  // Report exceptions to Sentry and track in analytics
  Future<void> reportError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? additionalData,
    SentryLevel level = SentryLevel.error,
  }) async {
    try {
      // Report to Sentry
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
        withScope: (scope) {
          if (context != null) {
            scope.setTag('context', context);
          }
          
          if (additionalData != null) {
            for (final entry in additionalData.entries) {
              scope.setExtra(entry.key, entry.value);
            }
          }
          
          scope.level = level;
        },
      );

      // Track in analytics
      await _telemetryService.trackError(
        errorType: exception.runtimeType.toString(),
        errorMessage: exception.toString(),
        stackTrace: stackTrace?.toString(),
        additionalData: {
          'context': context,
          'level': level.name,
          ...?additionalData,
        },
      );

      if (kDebugMode) {
        print('ErrorService: Error reported - $exception');
        if (stackTrace != null) {
          print('StackTrace: $stackTrace');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('ErrorService: Failed to report error: $e');
      }
    }
  }

  // Report messages to Sentry
  Future<void> reportMessage(
    String message, {
    SentryLevel level = SentryLevel.info,
    String? context,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      await Sentry.captureMessage(
        message,
        level: level,
        withScope: (scope) {
          if (context != null) {
            scope.setTag('context', context);
          }
          
          if (additionalData != null) {
            for (final entry in additionalData.entries) {
              scope.setExtra(entry.key, entry.value);
            }
          }
        },
      );

      if (kDebugMode) {
        print('ErrorService: Message reported - $message');
      }
    } catch (e) {
      if (kDebugMode) {
        print('ErrorService: Failed to report message: $e');
      }
    }
  }

  // Set user context
  Future<void> setUser({
    String? id,
    String? email,
    String? username,
    Map<String, dynamic>? extras,
  }) async {
    try {
      await Sentry.configureScope((scope) {
        scope.setUser(SentryUser(
          id: id,
          email: email,
          username: username,
          extras: extras,
        ));
      });
    } catch (e) {
      if (kDebugMode) {
        print('ErrorService: Failed to set user: $e');
      }
    }
  }

  // Add breadcrumb for debugging
  Future<void> addBreadcrumb(
    String message, {
    String? category,
    SentryLevel level = SentryLevel.info,
    Map<String, dynamic>? data,
  }) async {
    try {
      await Sentry.addBreadcrumb(Breadcrumb(
        message: message,
        category: category,
        level: level,
        data: data,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      if (kDebugMode) {
        print('ErrorService: Failed to add breadcrumb: $e');
      }
    }
  }

  // Wrapper for handling async operations with error reporting
  Future<T?> handleAsync<T>(
    Future<T> Function() operation, {
    String? context,
    T? fallbackValue,
    bool silent = false,
  }) async {
    try {
      return await operation();
    } catch (e, stackTrace) {
      await reportError(
        e,
        stackTrace,
        context: context,
      );
      
      if (!silent && kDebugMode) {
        print('ErrorService: Operation failed in context "$context": $e');
      }
      
      return fallbackValue;
    }
  }

  // Wrapper for handling sync operations with error reporting
  T? handleSync<T>(
    T Function() operation, {
    String? context,
    T? fallbackValue,
    bool silent = false,
  }) {
    try {
      return operation();
    } catch (e, stackTrace) {
      // Report async but don't wait
      reportError(
        e,
        stackTrace,
        context: context,
      );
      
      if (!silent && kDebugMode) {
        print('ErrorService: Operation failed in context "$context": $e');
      }
      
      return fallbackValue;
    }
  }
}