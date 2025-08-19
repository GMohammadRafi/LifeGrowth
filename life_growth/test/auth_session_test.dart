import 'package:flutter_test/flutter_test.dart';
import 'package:life_growth/services/auth_service.dart';
import 'package:life_growth/services/supabase_service.dart';

void main() {
  group('Authentication Session Tests', () {
    test('should handle null userId gracefully', () async {
      // Test that sync methods handle null userId without crashing
      try {
        // This should not throw an exception anymore
        await SupabaseService.syncAllPendingChanges('');
        fail('Should have thrown an ArgumentError');
      } catch (e) {
        expect(e, isA<ArgumentError>());
        expect(e.toString(), contains('userId cannot be empty'));
      }
    });

    test('should validate authentication state', () {
      // Test authentication state validation
      expect(AuthService.isAuthenticated, isA<bool>());
      expect(AuthService.userId, isA<String?>());
    });
  });
}