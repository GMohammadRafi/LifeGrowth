import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'services/background_sync_manager.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize local SQLite database (skip for web due to SQL.js issues)
  if (!kIsWeb) {
    await DatabaseService.initialize();
  }

  // Initialize Supabase
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl != null && supabaseAnonKey != null) {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  // Initialize background sync manager (only on mobile platforms)
  if (!kIsWeb) {
    try {
      await BackgroundSyncManager().initialize();
      if (kDebugMode) {
        print('Background sync manager initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize background sync manager: $e');
      }
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life Growth',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isCheckingBiometric = false;

  @override
  void initState() {
    super.initState();
    // Listen to auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        setState(() {});
      }
    });

    // Check for biometric authentication on app start
    _checkBiometricOnStart();
  }

  Future<void> _checkBiometricOnStart() async {
    // Only attempt biometric auth if user was previously authenticated
    // and biometric is available
    if (!AuthService.isAuthenticated) {
      final isAvailable = await AuthService.isBiometricAvailable();
      if (isAvailable) {
        setState(() {
          _isCheckingBiometric = true;
        });

        try {
          // This is a placeholder for checking if user has enabled biometric auth
          // In a real app, you'd store this preference in secure storage
          // For now, we'll skip automatic biometric prompt
        } catch (e) {
          // Biometric auth failed, continue to normal auth screen
        } finally {
          if (mounted) {
            setState(() {
              _isCheckingBiometric = false;
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while checking biometric
    if (_isCheckingBiometric) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Check if user is authenticated
    if (AuthService.isAuthenticated) {
      return const HomeScreen();
    } else {
      return const AuthScreen();
    }
  }
}
