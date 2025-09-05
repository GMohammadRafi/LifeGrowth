import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/supabase_service_v2.dart';
import '../services/telemetry_service.dart';
import '../providers/undo_provider.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'analytics_screen.dart';
import 'personalization_screen.dart';
import 'accessibility_settings_screen.dart';
import 'task_reminder_screen.dart';

import 'auth_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final GlobalKey<HomeScreenState> _homeScreenKey = GlobalKey<HomeScreenState>();
  final GlobalKey<HistoryScreenState> _historyScreenKey = GlobalKey<HistoryScreenState>();
  bool _isSyncing = false;
  String? _syncStatus;
  bool _includeDeleted = false; // Add this state for history screen
  
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
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _titles[_currentIndex],
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            if (_syncStatus != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _syncStatus!.contains('failed') 
                      ? Colors.red.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _syncStatus!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _syncStatus!.contains('failed') 
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
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
                  child: Container(
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: undoProvider.canUndo 
                          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                          : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: undoProvider.canUndo ? [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ] : [],
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.undo,
                        color: undoProvider.canUndo 
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                      ),
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
                  ),
                );
              },
            ),
            Semantics(
              label: 'Refresh',
              hint: 'Refresh today\'s task data',
              button: true,
              child: Container(
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () {
                    if (_homeScreenKey.currentState != null) {
                      _homeScreenKey.currentState!.loadTodayData();
                    }
                  },
                  tooltip: 'Refresh',
                ),
              ),
            ),
            Semantics(
              label: 'Sync Data',
              hint: _isSyncing ? 'Syncing data with server' : 'Sync your data with the server',
              button: true,
              child: Container(
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: _isSyncing 
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                      : Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: (_isSyncing 
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.tertiary).withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: _isSyncing
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.sync,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                  onPressed: _isSyncing ? null : _syncData,
                  tooltip: 'Sync Data',
                ),
              ),
            ),
          ],
          // Add eye toggle for History screen
          if (_currentIndex == 1) 
            Container(
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: _includeDeleted 
                    ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                    : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                boxShadow: _includeDeleted ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ] : [],
              ),
              child: IconButton(
                icon: Icon(
                  _includeDeleted ? Icons.visibility : Icons.visibility_off,
                  color: _includeDeleted 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                onPressed: () {
                  setState(() {
                    _includeDeleted = !_includeDeleted;
                  });
                  // Notify history screen of the change
                  if (_historyScreenKey.currentState != null) {
                    _historyScreenKey.currentState!.updateIncludeDeleted(_includeDeleted);
                  }
                },
                tooltip: _includeDeleted ? 'Hide deleted entries' : 'Show deleted entries',
              ),
            ),
          // Settings menu for all screens
          Semantics(
            label: 'Menu',
            hint: 'Open menu with options for settings and sign out',
            button: true,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
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

                } else if (value == 'signout') {
                  _signOut();
                }
              },
                icon: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Theme.of(context).colorScheme.surface,
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.2),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'personalization',
                    child: Semantics(
                      label: 'Personalization',
                      hint: 'Customize your task preferences and settings',
                      button: true,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.tune,
                                size: 18,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Personalization',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'accessibility',
                    child: Semantics(
                      label: 'Accessibility',
                      hint: 'Configure accessibility settings and theme preferences',
                      button: true,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.accessibility,
                                size: 18,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Accessibility',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'reminders',
                    child: Semantics(
                      label: 'Task Reminders',
                      hint: 'Manage reminders for your tasks',
                      button: true,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.notifications,
                                size: 18,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Task Reminders',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'signout',
                    child: Semantics(
                      label: 'Sign Out',
                      hint: 'Sign out from your account: ${AuthService.userEmail ?? 'Unknown'}',
                      button: true,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.logout,
                                size: 18,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Sign Out',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
            ),
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
          HistoryScreen(key: _historyScreenKey),
          const AnalyticsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onBottomNavTap, // Use the new method that handles page animation
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 0 
                      ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.home,
                  color: _currentIndex == 0 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 1 
                      ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.history,
                  color: _currentIndex == 1 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 2 
                      ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.analytics,
                  color: _currentIndex == 2 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              label: 'Analytics',
            ),
          ],
        ),
      ),
    );
  }
}