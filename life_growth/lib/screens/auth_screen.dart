import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:local_auth/local_auth.dart';
import '../services/auth_service.dart';
import '../services/telemetry_service.dart';
import '../services/error_service.dart';
import '../services/notification_service.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isSignUp = false;
  String? _errorMessage;
  bool _isBiometricAvailable = false;
  List<BiometricType> _availableBiometrics = [];

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
    
    // Track screen view for telemetry (fire and forget)
    TelemetryService().trackScreenView('auth_screen').catchError((e) {
      ErrorService().reportError(e, StackTrace.current, context: 'auth_screen_view');
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final isAvailable = await AuthService.isBiometricAvailable();
      final availableBiometrics = await AuthService.getAvailableBiometrics();

      if (mounted) {
        setState(() {
          _isBiometricAvailable = isAvailable;
          _availableBiometrics = availableBiometrics;
        });
      }
    } catch (e) {
      // Biometric check failed, continue without biometric option
    }
  }

  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isSignUp) {
        await AuthService.signUpWithEmailPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        
        // Track authentication event for telemetry
        try {
          await TelemetryService().trackAuthEvent(
            eventType: 'sign_up',
            method: 'email',
          );
          await NotificationService().showSuccessToast('Account created successfully!');
        } catch (e) {
          await ErrorService().reportError(e, StackTrace.current, context: 'email_auth');
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Check your email for verification link'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await AuthService.signInWithEmailPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        
        // Track authentication event for telemetry
        try {
          await TelemetryService().trackAuthEvent(
            eventType: 'sign_in',
            method: 'email',
          );
          await NotificationService().showSuccessToast('Signed in successfully!');
        } catch (e) {
          await ErrorService().reportError(e, StackTrace.current, context: 'email_auth');
        }

        // Background sync will be managed by app lifecycle

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      }
    } on AuthException catch (e) {
      // Track authentication error
        try {
          await ErrorService().reportError(e, StackTrace.current, context: 'auth_failed');
          await TelemetryService().trackError(
            errorType: 'auth_failed',
            errorMessage: e.message ?? 'Authentication failed',
          );
          await NotificationService().showErrorToast('Authentication failed');
        } catch (telemetryError) {
          // Silently fail telemetry to avoid cascading errors
        }
      
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      // Track unexpected error
        try {
          await ErrorService().reportError(e, StackTrace.current, context: 'auth_unexpected_error');
          await TelemetryService().trackError(
            errorType: 'auth_unexpected_error',
            errorMessage: e.toString(),
          );
          await NotificationService().showErrorToast('An unexpected error occurred');
        } catch (telemetryError) {
          // Silently fail telemetry to avoid cascading errors
        }
      
      setState(() {
        _errorMessage = 'An unexpected error occurred';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService.signInWithGoogle();
      
      // Track authentication event for telemetry
      try {
        await TelemetryService().trackAuthEvent(
          eventType: 'sign_in',
          method: 'google',
        );
        await NotificationService().showSuccessToast('Signed in with Google successfully!');
      } catch (e) {
        await ErrorService().reportError(e, StackTrace.current, context: 'google_auth');
      }

      // Background sync will be managed by app lifecycle

      // Navigation will be handled by auth state listener
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred with Google sign in';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGitHubSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService.signInWithGitHub();
      
      // Track authentication event for telemetry
      try {
        await TelemetryService().trackAuthEvent(
          eventType: 'sign_in',
          method: 'github',
        );
        await NotificationService().showSuccessToast('Signed in with GitHub successfully!');
      } catch (e) {
        await ErrorService().reportError(e, StackTrace.current, context: 'github_auth');
      }

      // Background sync will be managed by app lifecycle

      // Navigation will be handled by auth state listener
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred with GitHub sign in';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleBiometricAuth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final didAuthenticate = await AuthService.authenticateWithBiometrics(
        localizedReason: 'Please authenticate to access Life Growth',
      );

      if (didAuthenticate && mounted) {
        // Check if user is already signed in after biometric auth
        if (AuthService.isAuthenticated) {
          // Track authentication event for telemetry
          try {
            await TelemetryService().trackAuthEvent(
              eventType: 'sign_in',
              method: 'biometric',
            );
            await NotificationService().showSuccessToast('Biometric authentication successful!');
          } catch (e) {
            await ErrorService().reportError(e, StackTrace.current, context: 'biometric_auth');
          }
          
          // Background sync will be managed by app lifecycle

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          // If not authenticated, show message that they need to sign in first
          setState(() {
            _errorMessage =
                'Please sign in with your email and password first to enable biometric authentication';
          });
        }
      }
    } on PlatformException catch (e) {
      setState(() {
        if (e.code == 'NotAvailable') {
          _errorMessage =
              'Biometric authentication is not available on this device';
        } else if (e.code == 'NotEnrolled') {
          _errorMessage =
              'No biometrics enrolled. Please set up biometric authentication in your device settings';
        } else {
          _errorMessage = 'Biometric authentication failed: ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'An unexpected error occurred during biometric authentication';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  // App Logo/Title
                  Icon(
                    Icons.trending_up,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Life Growth',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track your daily habits and grow',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Error message
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Sign in/up button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleEmailAuth,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isSignUp ? 'Sign Up' : 'Sign In'),
                  ),
                  const SizedBox(height: 16),

                  // Toggle sign in/up
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            setState(() {
                              _isSignUp = !_isSignUp;
                              _errorMessage = null;
                            });
                          },
                    child: Text(
                      _isSignUp
                          ? 'Already have an account? Sign In'
                          : 'Don\'t have an account? Sign Up',
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // OAuth buttons
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _handleGoogleSignIn,
                    icon: const Icon(Icons.login, color: Colors.red),
                    label: const Text('Continue with Google'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),

                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _handleGitHubSignIn,
                    icon: const Icon(Icons.code, color: Colors.black),
                    label: const Text('Continue with GitHub'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),

                  // Biometric authentication button
                  if (_isBiometricAvailable &&
                      _availableBiometrics.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _isLoading ? null : _handleBiometricAuth,
                      icon: Icon(
                        _availableBiometrics.contains(BiometricType.face)
                            ? Icons.face
                            : _availableBiometrics
                                    .contains(BiometricType.fingerprint)
                                ? Icons.fingerprint
                                : Icons.security,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      label: Text(
                        _availableBiometrics.contains(BiometricType.face)
                            ? 'Continue with Face ID'
                            : _availableBiometrics
                                    .contains(BiometricType.fingerprint)
                                ? 'Continue with Fingerprint'
                                : 'Continue with Biometrics',
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
