import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// import 'package:flutter_native_timezone/flutter_native_timezone.dart'; // Removed due to AGP compatibility
import 'services/auth_service.dart';
import 'services/database_service.dart';

import 'services/notification_service.dart';
import 'services/theme_service.dart';
import 'services/telemetry_service.dart';
import 'services/error_service.dart';
import 'providers/theme_provider.dart';
import 'providers/undo_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/main_navigation_screen.dart'; // Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with proper configuration
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize local SQLite database (skip for web due to SQL.js issues)
  if (!kIsWeb) {
    await DatabaseService.initialize();
  }

  // Initialize Supabase with error handling
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl != null && supabaseAnonKey != null) {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );
      
      // Wait for session recovery on desktop platforms
      if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
        // Give Supabase time to restore the session
        await Future.delayed(const Duration(milliseconds: 1000));
        
        // Try to refresh the session if it exists
        try {
          final session = Supabase.instance.client.auth.currentSession;
          if (session != null) {
            await Supabase.instance.client.auth.refreshSession();
          }
        } catch (e) {
          if (kDebugMode) {
            print('Session refresh failed: $e');
          }
        }
      }
      
      if (kDebugMode) {
        print('Supabase initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Supabase initialization failed: $e');
        
        // Provide specific error messages for common network issues
        if (e.toString().contains('SocketException') || 
            e.toString().contains('ClientException') ||
            e.toString().contains('No address associated with hostname')) {
          print('Network Error Details:');
          print('- Check your internet connection');
          print('- Verify the SUPABASE_URL in your .env file');
          print('- Ensure the Supabase project URL is correct');
          print('- Check if the domain exists: ${supabaseUrl}');
        } else if (e.toString().contains('TimeoutException')) {
          print('Connection timeout - check network stability');
        } else if (e.toString().contains('FormatException')) {
          print('Invalid URL format in SUPABASE_URL');
        }
        
        print('App will continue with offline mode using local database');
      }
    }
  } else {
    if (kDebugMode) {
      print('Supabase credentials not found. Running in offline mode.');
    }
  }

  // Initialize timezone data
  tz.initializeTimeZones();
  
  // Set device's local timezone using system default
  try {
    // Get the system's timezone offset
    final now = DateTime.now();
    final offset = now.timeZoneOffset;
    
    // Try to find a matching timezone location
    // Common timezone mappings based on offset
    String timeZoneName = 'UTC';
    
    // Map common offsets to timezone names
    final offsetHours = offset.inHours;
    switch (offsetHours) {
      case -8: timeZoneName = 'America/Los_Angeles'; break;
      case -7: timeZoneName = 'America/Denver'; break;
      case -6: timeZoneName = 'America/Chicago'; break;
      case -5: timeZoneName = 'America/New_York'; break;
      case 0: timeZoneName = 'UTC'; break;
      case 1: timeZoneName = 'Europe/London'; break;
      case 2: timeZoneName = 'Europe/Berlin'; break;
      case 3: timeZoneName = 'Europe/Moscow'; break;
      case 5: timeZoneName = 'Asia/Karachi'; break;
      case 8: timeZoneName = 'Asia/Shanghai'; break;
      case 9: timeZoneName = 'Asia/Tokyo'; break;
      default: 
        // For other offsets, try to use a generic UTC offset
        if (offsetHours > 0) {
          timeZoneName = 'Etc/GMT-$offsetHours';
        } else if (offsetHours < 0) {
          timeZoneName = 'Etc/GMT+${-offsetHours}';
        }
    }
    
    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      if (kDebugMode) {
        print('Timezone set to: $timeZoneName (offset: ${offset.inHours}h)');
      }
    } catch (e) {
      // If the timezone name is not found, fallback to UTC
      tz.setLocalLocation(tz.getLocation('UTC'));
      if (kDebugMode) {
        print('Timezone $timeZoneName not found, using UTC. Offset was: ${offset.inHours}h');
      }
    }
  } catch (e) {
    // Fallback to UTC if timezone detection fails
    tz.setLocalLocation(tz.getLocation('UTC'));
    if (kDebugMode) {
      print('Failed to detect timezone, using UTC: $e');
    }
  }

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

  // Initialize telemetry service
  try {
    await TelemetryService().initialize();
    if (kDebugMode) {
      print('Telemetry service initialized successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Failed to initialize telemetry service: $e');
    }
  }

  // Initialize error service
  try {
    final sentryDsn = dotenv.env['SENTRY_DSN'];
    if (sentryDsn != null && sentryDsn.isNotEmpty) {
      await ErrorService().initialize(sentryDsn);
      if (kDebugMode) {
        print('Error service initialized successfully');
      }
    } else {
      if (kDebugMode) {
        print('Sentry DSN not found in environment variables');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Failed to initialize error service: $e');
    }
  }

  // Background sync manager removed - using direct sync only

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => UndoProvider()),
      ],
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

class _AuthWrapperState extends State<AuthWrapper> with WidgetsBindingObserver {
  bool _isCheckingBiometric = false;

  @override
  void initState() {
    super.initState();
    // Add app lifecycle observer
    WidgetsBinding.instance.addObserver(this);
    
    // Listen to auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      if (mounted) {
        setState(() {});
      }

      // Handle auth state changes
      try {
        if (data.event == AuthChangeEvent.signedOut) {
          // Clear local data upon logout
          if (!kIsWeb) {
            await DatabaseService.instance.clearAllData();
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error handling auth state change: $e');
        }
      }
    });

    // Check biometric on app start and wait for session restoration
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _waitForSessionRestoration();
    });
  }

  Future<void> _waitForSessionRestoration() async {
    // On desktop platforms, wait a bit longer for session restoration
    if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      await Future.delayed(const Duration(milliseconds: 2000));
    }
    
    _checkBiometricOnStart();

    // Session restoration completed
    if (AuthService.isAuthenticated) {
      if (kDebugMode) {
        print('Session restored successfully');
      }
    }
  }

  @override
  void dispose() {
    // Remove app lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Only manage background sync on mobile platforms
    if (!kIsWeb) {
      switch (state) {
        case AppLifecycleState.paused:
        case AppLifecycleState.detached:
          // App is going to background
          _handleAppBackground();
          break;
        case AppLifecycleState.resumed:
          // App is coming to foreground
          _handleAppForeground();
          break;
        case AppLifecycleState.inactive:
          // App is inactive (e.g., during a phone call)
          break;
        case AppLifecycleState.hidden:
          // App is hidden
          break;
      }
    }
  }

  Future<void> _handleAppBackground() async {
    // Background sync functionality removed
    if (kDebugMode) {
      print('App went to background');
    }
  }

  Future<void> _handleAppForeground() async {
    // Background sync functionality removed
    if (kDebugMode) {
      print('App came to foreground');
    }
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
      return const MainNavigationScreen();
    } else {
      return const AuthScreen();
    }
  }
}
