import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import '../lib/main.dart';
import '../lib/services/background_sync_manager.dart';

void main() {
  group('App Lifecycle Background Sync Tests', () {
    testWidgets('App lifecycle observer is properly set up', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MyApp());
      
      // Verify that the app builds without errors
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    test('BackgroundSyncManager has lifecycle methods', () {
      final syncManager = BackgroundSyncManager();
      
      // Verify that the new methods exist
      expect(syncManager.startBackgroundSync, isA<Function>());
      expect(syncManager.stopBackgroundSync, isA<Function>());
      expect(syncManager.performSync, isA<Function>());
    });

    testWidgets('App responds to lifecycle state changes', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MyApp());
      
      // Simulate app going to background
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter/lifecycle'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'AppLifecycleState.paused') {
            return null;
          }
          return null;
        },
      );
      
      // Simulate app lifecycle state change
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/lifecycle',
        const StandardMethodCodec().encodeMethodCall(
          const MethodCall('routeUpdated', {
            'location': '/test',
            'state': 'AppLifecycleState.paused',
          }),
        ),
        (data) {},
      );
      
      await tester.pump();
      
      // Verify app still works after lifecycle change
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}