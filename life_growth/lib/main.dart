import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'services/background_sync_manager.dart';
import 'services/notification_service.dart';
import 'services/theme_service.dart';
import 'providers/theme_provider.dart';
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

  // Initialize timezone data
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('UTC')); // Default to UTC, will be updated based on device timezone

  // Initialize notification service (only on mobile platforms)
  if (!kIsWeb) {
    try {
      await NotificationService().initialize();
      if (kDebugMode) {
        print('Notification service initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize notification service: $e');
      }
    }
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

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Life Growth',
          theme: ThemeService.lightTheme,
          darkTheme: ThemeService.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const AuthWrapper(),
          debugShowCheckedModeBanner: false,
          // Accessibility improvements
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                // Ensure text scaling doesn't break layout
                textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.4),
              ),
              child: child!,
            );
          },
        );
      },
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
