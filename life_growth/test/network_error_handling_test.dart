import 'package:flutter_test/flutter_test.dart';
import 'package:life_growth/services/supabase_service.dart';
import 'package:life_growth/services/notification_service.dart';

void main() {
  group('Network Error Handling Tests', () {
    test('should identify network errors correctly', () {
      // Test various network error scenarios
      expect(
        SupabaseService.isNetworkError(
          Exception('SocketException: Failed host lookup: example.com')
        ),
        isTrue,
      );
      
      expect(
        SupabaseService.isNetworkError(
          Exception('ClientException with SocketException: No address associated with hostname')
        ),
        isTrue,
      );
      
      expect(
        SupabaseService.isNetworkError(
          Exception('Connection timeout')
        ),
        isTrue,
      );
      
      expect(
        SupabaseService.isNetworkError(
          Exception('Network is unreachable')
        ),
        isTrue,
      );
      
      // Test non-network errors
      expect(
        SupabaseService.isNetworkError(
          Exception('Invalid JSON format')
        ),
        isFalse,
      );
    });
    
    test('should provide user-friendly error messages', () {
      final notificationService = NotificationService();
      
      // Test DNS resolution error
      String friendlyMessage = notificationService.getUserFriendlyErrorMessage(
        'SocketException: Failed host lookup: fcrjonyocxjkqpfllirw.supabase.co'
      );
      expect(
        friendlyMessage,
        'Unable to connect to server. Please check your internet connection and try again later.'
      );
      
      // Test timeout error
      friendlyMessage = notificationService.getUserFriendlyErrorMessage(
        'Connection timeout after 30 seconds'
      );
      expect(
        friendlyMessage,
        'Connection timed out. Please check your internet connection and try again.'
      );
      
      // Test connection refused
      friendlyMessage = notificationService.getUserFriendlyErrorMessage(
        'Connection refused by server'
      );
      expect(
        friendlyMessage,
        'Server is temporarily unavailable. Please try again later.'
      );
      
      // Test generic error
      friendlyMessage = notificationService.getUserFriendlyErrorMessage(
        'Some unknown error occurred'
      );
      expect(
        friendlyMessage,
        'Sync failed. Your data is saved locally and will sync when connection is restored.'
      );
    });
  });
}