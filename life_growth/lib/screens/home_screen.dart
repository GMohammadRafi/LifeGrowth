import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';
import '../services/database_service.dart';
import '../services/background_sync_manager.dart';
import '../models/daily_task.dart' as model;
import 'auth_screen.dart';
import 'daily_checkin_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  model.DailyTask? _todayTask;
  bool _isLoading = true;
  bool _isSyncing = false;
  String? _errorMessage;
  String? _syncStatus;

  @override
  void initState() {
    super.initState();
    _loadTodayTask();
  }

  Future<void> _loadTodayTask() async {
    if (!AuthService.isAuthenticated) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'User not authenticated';
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final today = DateTime.now();
      final userId = AuthService.userId!;
      
      model.DailyTask? task = await SupabaseService.getDailyTask(
        userId: userId,
        date: today,
      );
      
      // If no task exists for today, create an empty one
      task ??= model.DailyTask.empty(date: today);

      setState(() {
        _todayTask = task;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load today\'s tasks: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateTask(model.DailyTask updatedTask) async {
    if (!AuthService.isAuthenticated) return;

    try {
      final savedTask = await SupabaseService.upsertDailyTask(updatedTask);
      setState(() {
        _todayTask = savedTask;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task updated (saved locally, will sync when online)'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _syncData() async {
    if (!AuthService.isAuthenticated) return;

    setState(() {
      _isSyncing = true;
      _syncStatus = 'Syncing...';
    });

    try {
      // Use background sync manager for immediate sync
      await BackgroundSyncManager().scheduleImmediateSync();
      
      // Also perform direct sync for immediate feedback
      await SupabaseService.syncAllPendingChanges(AuthService.userId!);
      await _loadTodayTask(); // Reload to get any updates
      
      setState(() {
        _syncStatus = 'Sync completed successfully';
      });
      
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
      setState(() {
        _syncStatus = 'Sync failed: $e';
      });
      
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
      setState(() {
        _isSyncing = false;
      });
      
      // Clear sync status after 3 seconds
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

  Widget _buildTaskTile({
    required String title,
    required bool completed,
    required VoidCallback onToggle,
    String? subtitle,
    Widget? trailing,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: completed,
          onChanged: (_) => onToggle(),
        ),
        title: Text(
          title,
          style: TextStyle(
            decoration: completed ? TextDecoration.lineThrough : null,
            color: completed ? Colors.grey : null,
          ),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: trailing,
        onTap: onToggle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Life Growth'),
            if (_syncStatus != null)
              Text(
                _syncStatus!,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTodayTask,
            tooltip: 'Refresh',
          ),
          IconButton(
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
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'signout') {
                _signOut();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'signout',
                child: Row(
                  children: [
                    const Icon(Icons.logout),
                    const SizedBox(width: 8),
                    Text('Sign Out (${AuthService.userEmail ?? 'Unknown'})'),
                  ],
                ),
              ),
            ],
          ),
        ],
       ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.withOpacity(0.7),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadTodayTask,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _todayTask == null
                  ? const Center(child: Text('No task data available'))
                  : RefreshIndicator(
                      onRefresh: _loadTodayTask,
                      child: ListView(
                        children: [
                          // Header
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Today - ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Completed: ${_todayTask!.completedTasksCount}/10 tasks',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Task list
                          _buildTaskTile(
                            title: 'Reading Book',
                            completed: _todayTask!.isReadingBookEffectivelyCompleted,
                            subtitle: _todayTask!.readingBookPages != null || _todayTask!.readingBookTime != null
                                ? '${_todayTask!.readingBookPages ?? 0} pages, ${_todayTask!.readingBookTime ?? 0} min'
                                : null,
                            onToggle: () {
                              final updated = _todayTask!.copyWith(
                                readingBookCompleted: !_todayTask!.readingBookCompleted,
                              );
                              _updateTask(updated);
                            },
                          ),
                          
                          _buildTaskTile(
                            title: 'Stretch (${_todayTask!.stretchType ?? 'Not specified'})',
                            completed: _todayTask!.isStretchEffectivelyCompleted,
                            subtitle: _todayTask!.stretchMinutes != null
                                ? '${_todayTask!.stretchMinutes} minutes'
                                : null,
                            onToggle: () {
                              final updated = _todayTask!.copyWith(
                                stretchCompleted: !_todayTask!.stretchCompleted,
                              );
                              _updateTask(updated);
                            },
                          ),
                          
                          _buildTaskTile(
                            title: 'Meditation',
                            completed: _todayTask!.isMeditationEffectivelyCompleted,
                            subtitle: _todayTask!.meditationMinutes != null
                                ? '${_todayTask!.meditationMinutes} minutes'
                                : null,
                            onToggle: () {
                              final updated = _todayTask!.copyWith(
                                meditationCompleted: !_todayTask!.meditationCompleted,
                              );
                              _updateTask(updated);
                            },
                          ),
                          
                          _buildTaskTile(
                            title: 'Reading Docs',
                            completed: _todayTask!.isReadingDocsEffectivelyCompleted,
                            subtitle: _todayTask!.readingDocsPages != null || _todayTask!.readingDocsTime != null
                                ? '${_todayTask!.readingDocsPages ?? 0} pages, ${_todayTask!.readingDocsTime ?? 0} min'
                                : null,
                            onToggle: () {
                              final updated = _todayTask!.copyWith(
                                readingDocsCompleted: !_todayTask!.readingDocsCompleted,
                              );
                              _updateTask(updated);
                            },
                          ),
                          
                          _buildTaskTile(
                            title: 'Learning New Technology',
                            completed: _todayTask!.isLearningTechEffectivelyCompleted,
                            subtitle: _todayTask!.learningTechName != null || _todayTask!.learningTechTime != null
                                ? '${_todayTask!.learningTechName ?? 'Not specified'}, ${_todayTask!.learningTechTime ?? 0} min'
                                : null,
                            onToggle: () {
                              final updated = _todayTask!.copyWith(
                                learningTechCompleted: !_todayTask!.learningTechCompleted,
                              );
                              _updateTask(updated);
                            },
                          ),
                          
                          _buildTaskTile(
                            title: 'Walking',
                            completed: _todayTask!.isWalkingEffectivelyCompleted,
                            subtitle: _todayTask!.walkingSteps != null || _todayTask!.walkingTime != null
                                ? '${_todayTask!.walkingSteps ?? 0} steps, ${_todayTask!.walkingTime ?? 0} min'
                                : null,
                            onToggle: () {
                              final updated = _todayTask!.copyWith(
                                walkingCompleted: !_todayTask!.walkingCompleted,
                              );
                              _updateTask(updated);
                            },
                          ),
                          
                          _buildTaskTile(
                            title: _todayTask!.avoidHabitLabel ?? 'Avoid X',
                            completed: _todayTask!.avoidHabitValue,
                            onToggle: () {
                              final updated = _todayTask!.copyWith(
                                avoidHabitValue: !_todayTask!.avoidHabitValue,
                              );
                              _updateTask(updated);
                            },
                          ),
                          
                          _buildTaskTile(
                            title: 'Avoid Sweets',
                            completed: _todayTask!.avoidSweetsValue,
                            onToggle: () {
                              final updated = _todayTask!.copyWith(
                                avoidSweetsValue: !_todayTask!.avoidSweetsValue,
                              );
                              _updateTask(updated);
                            },
                          ),
                          
                          _buildTaskTile(
                            title: 'Work Done Today',
                            completed: _todayTask!.workDoneValue,
                            onToggle: () {
                              final updated = _todayTask!.copyWith(
                                workDoneValue: !_todayTask!.workDoneValue,
                              );
                              _updateTask(updated);
                            },
                          ),
                          
                          _buildTaskTile(
                            title: 'Movie or Series',
                            completed: _todayTask!.isMovieSeriesEffectivelyCompleted,
                            subtitle: _todayTask!.movieSeriesName != null || _todayTask!.movieSeriesDuration != null
                                ? '${_todayTask!.movieSeriesName ?? 'Not specified'}, ${_todayTask!.movieSeriesDuration ?? 0} min'
                                : null,
                            onToggle: () {
                              final updated = _todayTask!.copyWith(
                                movieSeriesCompleted: !_todayTask!.movieSeriesCompleted,
                              );
                              _updateTask(updated);
                            },
                          ),
                          
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
      floatingActionButton: _todayTask == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                if (!AuthService.isAuthenticated) return;
                final saved = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (context) => DailyCheckinScreen(
                      existingTask: _todayTask,
                      date: DateTime.now(),
                    ),
                  ),
                );
                if (saved == true) {
                  _loadTodayTask();
                }
              },
              icon: const Icon(Icons.edit),
              label: const Text('Daily Check-in'),
            ),
    );
  }
}