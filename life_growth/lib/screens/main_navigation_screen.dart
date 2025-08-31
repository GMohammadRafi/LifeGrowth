import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/supabase_service_v2.dart';
import '../services/background_sync_manager.dart';
import '../services/telemetry_service.dart';
import '../providers/undo_provider.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'analytics_screen.dart';
import 'personalization_screen.dart';
import 'accessibility_settings_screen.dart';
import 'task_reminder_screen.dart';
import 'csv_export_screen.dart';
import 'auth_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final GlobalKey<HomeScreenState> _homeScreenKey = GlobalKey<HomeScreenState>();
  bool _isSyncing = false;
  String? _syncStatus;
  
  // Add PageController for swipe navigation
  late PageController _pageController;
  
  final List<String> _titles = [
    'Life Growth',
    'History',
    'Analytics',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Handle page changes from swipe gestures
  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Track navigation
    TelemetryService().trackScreenView(_titles[index].toLowerCase().replaceAll(' ', '_'));
  }

  // Handle bottom navigation bar taps
  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Animate to the selected page
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    // Track navigation
    TelemetryService().trackScreenView(_titles[index].toLowerCase().replaceAll(' ', '_'));
  }

  Future<void> _syncData() async {
    if (!AuthService.isAuthenticated) return;

    if (mounted) {
      setState(() {
        _isSyncing = true;
        _syncStatus = 'Syncing...';
      });
    }

    try {
      await BackgroundSyncManager().scheduleImmediateSync();
      await SupabaseServiceV2.syncAllPendingChanges(AuthService.userId!);
      
      // Refresh home screen if it's the current tab
      if (_currentIndex == 0 && _homeScreenKey.currentState != null) {
        await _homeScreenKey.currentState!.loadTodayData();
      }

      if (mounted) {
        setState(() {
          _syncStatus = 'Sync completed successfully';
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data synced successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _syncStatus = 'Sync failed: $e';
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _syncStatus = null;
          });
        }
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await AuthService.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sign out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_titles[_currentIndex]),
            if (_syncStatus != null)
              Text(
                _syncStatus!,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        actions: [
          // Keep the undo and refresh buttons for Home screen
          if (_currentIndex == 0) ...[
            Consumer<UndoProvider>(
              builder: (context, undoProvider, child) {
                return Semantics(
                  label: 'Undo',
                  hint: undoProvider.canUndo 
                      ? 'Undo last action: ${undoProvider.getUndoDescription()}'
                      : 'No actions to undo',
                  button: true,
                  child: IconButton(
                    icon: const Icon(Icons.undo),
                    onPressed: undoProvider.canUndo ? () async {
                      final success = await undoProvider.undoLastAction();
                      if (success) {
                        await Future.delayed(const Duration(milliseconds: 200));
                        if (_homeScreenKey.currentState != null) {
                          await _homeScreenKey.currentState!.loadTodayData();
                        }
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Action undone')),
                          );
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to undo action'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    } : null,
                    tooltip: undoProvider.canUndo 
                        ? 'Undo: ${undoProvider.getUndoDescription()}'
                        : 'No actions to undo',
                  ),
                );
              },
            ),
            Semantics(
              label: 'Refresh',
              hint: 'Refresh today\'s task data',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  if (_homeScreenKey.currentState != null) {
                    _homeScreenKey.currentState!.loadTodayData();
                  }
                },
                tooltip: 'Refresh',
              ),
            ),
            Semantics(
              label: 'Sync Data',
              hint: _isSyncing ? 'Syncing data with server' : 'Sync your data with the server',
              button: true,
              child: IconButton(
                icon: _isSyncing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.sync),
                onPressed: _isSyncing ? null : _syncData,
                tooltip: 'Sync Data',
              ),
            ),
          ],
          // Settings menu for all screens
          Semantics(
            label: 'Menu',
            hint: 'Open menu with options for settings and sign out',
            button: true,
            child: PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'personalization') {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PersonalizationScreen(),
                    ),
                  );
                  if (result == true && _currentIndex == 0 && _homeScreenKey.currentState != null) {
                    await _homeScreenKey.currentState!.loadTodayData();
                  }
                } else if (value == 'accessibility') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AccessibilitySettingsScreen(),
                    ),
                  );
                } else if (value == 'reminders') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TaskReminderScreen(),
                    ),
                  );
                } else if (value == 'export') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CsvExportScreen(),
                    ),
                  );
                } else if (value == 'signout') {
                  _signOut();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'personalization',
                  child: Semantics(
                    label: 'Personalization',
                    hint: 'Customize your task preferences and settings',
                    button: true,
                    child: const Row(
                      children: [
                        Icon(Icons.tune),
                        SizedBox(width: 8),
                        Text('Personalization'),
                      ],
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'accessibility',
                  child: Semantics(
                    label: 'Accessibility',
                    hint: 'Configure accessibility settings and theme preferences',
                    button: true,
                    child: const Row(
                      children: [
                        Icon(Icons.accessibility),
                        SizedBox(width: 8),
                        Text('Accessibility'),
                      ],
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'reminders',
                  child: Semantics(
                    label: 'Task Reminders',
                    hint: 'Manage reminders for your tasks',
                    button: true,
                    child: const Row(
                      children: [
                        Icon(Icons.notifications),
                        SizedBox(width: 8),
                        Text('Task Reminders'),
                      ],
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'export',
                  child: Semantics(
                    label: 'Export Data',
                    hint: 'Export your data to CSV files',
                    button: true,
                    child: const Row(
                      children: [
                        Icon(Icons.file_download),
                        SizedBox(width: 8),
                        Text('Export Data'),
                      ],
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'signout',
                  child: Semantics(
                    label: 'Sign Out',
                    hint: 'Sign out from your account: ${AuthService.userEmail ?? 'Unknown'}',
                    button: true,
                    child: const Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Sign Out'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Replace IndexedStack with PageView for swipe navigation
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          HomeScreen(key: _homeScreenKey, showAppBar: false),
          const HistoryScreen(),
          const AnalyticsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap, // Use the new method that handles page animation
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }
}