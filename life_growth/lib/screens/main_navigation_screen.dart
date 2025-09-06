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
  bool _isMenuOpen = false; // Track menu state for animation
  
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

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  void _showQuickActionsMenu() {
    setState(() {
      _isMenuOpen = true;
    });
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
         child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildMenuOption(
                    icon: Icons.tune,
                    title: 'Personalization',
                    subtitle: 'Customize your preferences',
                    color: Theme.of(context).colorScheme.primary,
                    onTap: () async {
                      Navigator.pop(context);
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const PersonalizationScreen(),
                        ),
                      );
                      if (result == true && _currentIndex == 0 && _homeScreenKey.currentState != null) {
                        await _homeScreenKey.currentState!.loadTodayData();
                      }
                    },
                  ),
                  _buildMenuOption(
                    icon: Icons.accessibility,
                    title: 'Accessibility',
                    subtitle: 'Configure accessibility settings',
                    color: Theme.of(context).colorScheme.secondary,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AccessibilitySettingsScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 32),
                  _buildMenuOption(
                    icon: Icons.logout,
                    title: 'Sign Out',
                    subtitle: 'Sign out from your account',
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      _signOut();
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      setState(() {
        _isMenuOpen = false;
      });
    });
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return GestureDetector(
      onTap: () => _onBottomNavTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 8 : 12,
          vertical: 6,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            width: 1,
          ) : null,
          boxShadow: isSelected ? [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                size: isSmallScreen ? 20 : 22,
              ),
            ),
            SizedBox(height: isSmallScreen ? 1 : 2),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: isSmallScreen ? 10 : 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: 0.3,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
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
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 70,
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.06,
              vertical: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Home navigation item
                Expanded(
                  child: _buildNavItem(
                    icon: _currentIndex == 0 ? Icons.home : Icons.home_outlined,
                    label: 'Home',
                    index: 0,
                    isSelected: _currentIndex == 0,
                  ),
                ),
                // History navigation item
                Expanded(
                  child: _buildNavItem(
                    icon: _currentIndex == 1 ? Icons.history : Icons.history_outlined,
                    label: 'History',
                    index: 1,
                    isSelected: _currentIndex == 1,
                  ),
                ),
                // Analysis navigation item
                Expanded(
                  child: _buildNavItem(
                    icon: _currentIndex == 2 ? Icons.analytics : Icons.analytics_outlined,
                    label: 'Analysis',
                    index: 2,
                    isSelected: _currentIndex == 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}