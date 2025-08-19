import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../lib/firebase_options.dart';
import '../lib/services/telemetry_service.dart';

void main() {
  group('Firebase Analytics Tests', () {
    setUpAll(() async {
      // Initialize Firebase for testing
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    });

    test('Firebase Analytics should initialize successfully', () async {
      // Test Firebase Analytics initialization
      final analytics = FirebaseAnalytics.instance;
      expect(analytics, isNotNull);
      
      // Test setting analytics collection
      await analytics.setAnalyticsCollectionEnabled(true);
      
      // This should not throw an exception
      expect(() async {
        await analytics.logEvent(
          name: 'test_event',
          parameters: {
            'test_parameter': 'test_value',
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          },
        );
      }, returnsNormally);
    });

    test('TelemetryService should initialize without errors', () async {
      final telemetryService = TelemetryService();
      
      // This should not throw an exception
      expect(() async {
        await telemetryService.initialize();
      }, returnsNormally);
    });

    test('TelemetryService should track events successfully', () async {
      final telemetryService = TelemetryService();
      await telemetryService.initialize();
      
      // Test tracking various events
      expect(() async {
        await telemetryService.trackTaskToggle(
          taskId: 'test_task_1',
          isCompleted: true,
          category: 'test_category',
        );
      }, returnsNormally);
      
      expect(() async {
        await telemetryService.trackDetailEdit(
          itemType: 'task',
          itemId: 'test_task_1',
          editType: 'update',
        );
      }, returnsNormally);
    });
  });
}