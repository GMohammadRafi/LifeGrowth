import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Get the current user
  static User? get currentUser => _client.auth.currentUser;

  // Auth methods
  static Future<AuthResponse> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<AuthResponse> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  static Future<void> signInWithOAuth(OAuthProvider provider) async {
    await _client.auth.signInWithOAuth(provider);
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Helper method to identify network-related errors
  static bool isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('socketexception') ||
           errorString.contains('clientexception') ||
           errorString.contains('failed host lookup') ||
           errorString.contains('network is unreachable') ||
           errorString.contains('connection refused') ||
           errorString.contains('timeout') ||
           errorString.contains('no address associated with hostname');
  }

  // Helper method to check network connectivity
  static Future<bool> _hasNetworkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}