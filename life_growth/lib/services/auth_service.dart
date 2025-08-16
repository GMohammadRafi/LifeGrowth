import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final SupabaseClient _client = Supabase.instance.client;
  
  // Get current user
  static User? get currentUser => _client.auth.currentUser;
  
  // Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;
  
  // Get auth state stream
  static Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  
  // Sign in with email and password
  static Future<AuthResponse> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw AuthException('Sign in failed: No user returned');
      }
      
      return response;
    } on AuthException catch (e) {
      debugPrint('Auth error during sign in: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error during sign in: $e');
      throw AuthException('An unexpected error occurred during sign in');
    }
  }
  
  // Sign up with email and password
  static Future<AuthResponse> signUpWithEmailPassword({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: data,
      );
      
      return response;
    } on AuthException catch (e) {
      debugPrint('Auth error during sign up: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error during sign up: $e');
      throw AuthException('An unexpected error occurred during sign up');
    }
  }
  
  // Sign in with OAuth provider
  static Future<bool> signInWithOAuth(OAuthProvider provider) async {
    try {
      final response = await _client.auth.signInWithOAuth(
        provider,
        redirectTo: kIsWeb ? null : 'io.supabase.lifegrowth://login-callback/',
      );
      
      return response;
    } on AuthException catch (e) {
      debugPrint('Auth error during OAuth sign in: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error during OAuth sign in: $e');
      throw AuthException('An unexpected error occurred during OAuth sign in');
    }
  }
  
  // Sign in with Google
  static Future<bool> signInWithGoogle() async {
    return await signInWithOAuth(OAuthProvider.google);
  }
  
  // Sign in with GitHub
  static Future<bool> signInWithGitHub() async {
    return await signInWithOAuth(OAuthProvider.github);
  }
  
  // Sign out
  static Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      debugPrint('Auth error during sign out: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error during sign out: $e');
      throw AuthException('An unexpected error occurred during sign out');
    }
  }
  
  // Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: kIsWeb ? null : 'io.supabase.lifegrowth://reset-password/',
      );
    } on AuthException catch (e) {
      debugPrint('Auth error during password reset: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error during password reset: $e');
      throw AuthException('An unexpected error occurred during password reset');
    }
  }
  
  // Update password
  static Future<UserResponse> updatePassword(String newPassword) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      
      if (response.user == null) {
        throw AuthException('Password update failed: No user returned');
      }
      
      return response;
    } on AuthException catch (e) {
      debugPrint('Auth error during password update: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error during password update: $e');
      throw AuthException('An unexpected error occurred during password update');
    }
  }
  
  // Update user profile
  static Future<UserResponse> updateProfile({
    String? email,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(
          email: email,
          data: data,
        ),
      );
      
      if (response.user == null) {
        throw AuthException('Profile update failed: No user returned');
      }
      
      return response;
    } on AuthException catch (e) {
      debugPrint('Auth error during profile update: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error during profile update: $e');
      throw AuthException('An unexpected error occurred during profile update');
    }
  }
  
  // Refresh session
  static Future<AuthResponse> refreshSession() async {
    try {
      final response = await _client.auth.refreshSession();
      
      if (response.user == null) {
        throw AuthException('Session refresh failed: No user returned');
      }
      
      return response;
    } on AuthException catch (e) {
      debugPrint('Auth error during session refresh: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error during session refresh: $e');
      throw AuthException('An unexpected error occurred during session refresh');
    }
  }
  
  // Get user metadata
  static Map<String, dynamic>? get userMetadata => currentUser?.userMetadata;
  
  // Get user email
  static String? get userEmail => currentUser?.email;
  
  // Get user ID
  static String? get userId => currentUser?.id;
  
  // Check if email is confirmed
  static bool get isEmailConfirmed => currentUser?.emailConfirmedAt != null;
  
  // Get user creation date
  static DateTime? get userCreatedAt {
    final createdAtStr = currentUser?.createdAt;
    return createdAtStr != null ? DateTime.tryParse(createdAtStr) : null;
  }
  
  // Get last sign in date
  static DateTime? get lastSignInAt {
    final lastSignInStr = currentUser?.lastSignInAt;
    return lastSignInStr != null ? DateTime.tryParse(lastSignInStr) : null;
  }
}