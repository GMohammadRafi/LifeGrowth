import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../services/telemetry_service.dart';
import '../models/daily_task.dart' as model;

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<model.DailyTask> _allTasks = [];
  
  // Analytics data
  int _totalTasks = 0;
  int _completedTasks = 0;
  double _completionRate = 0.0;
  int _currentStreak = 0;
  int _longestStreak = 0;
  Map<String, int> _taskCompletionCounts = {};
  List<FlSpot> _weeklyCompletionData = [];

  @override
  void initState() {
    super.initState();
    // Track screen view
    TelemetryService().trackScreenView('analytics_screen');
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
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

      final userId = AuthService.userId!;
      final tasks = await DatabaseService.instance.getAllDailyTasksForUser(
        userId,
        includeDeleted: false,
      );

      _allTasks = tasks;
      _calculateAnalytics();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load analytics data: $e';
        _isLoading = false;
      });
    }
  }

  void _calculateAnalytics() {
    if (_allTasks.isEmpty) return;

    _totalTasks = _allTasks.length;
    _completedTasks = _allTasks.where((task) => _isTaskCompleted(task)).length;
    _completionRate = _totalTasks > 0 ? (_completedTasks / _totalTasks) * 100 : 0.0;

    _calculateStreaks();
    _calculateTaskCompletionCounts();
    _calculateWeeklyCompletionData();
  }

  bool _isTaskCompleted(model.DailyTask task) {
    // Consider a task completed if at least 50% of activities are done
    int completedActivities = 0;
    int totalActivities = 10; // Total number of trackable activities

    if (task.readingBookCompleted) completedActivities++;
    if (task.stretchCompleted) completedActivities++;
    if (task.meditationCompleted) completedActivities++;
    if (task.readingDocsCompleted) completedActivities++;
    if (task.learningTechCompleted) completedActivities++;
    if (task.walkingCompleted) completedActivities++;
    if (task.avoidHabitValue) completedActivities++;
    if (task.avoidSweetsValue) completedActivities++;
    if (task.workDoneValue) completedActivities++;
    if (task.movieSeriesCompleted) completedActivities++;

    return completedActivities >= (totalActivities * 0.5);
  }

  void _calculateStreaks() {
    if (_allTasks.isEmpty) return;

    // Group tasks by date and check if each day is completed
    final Map<DateTime, bool> dailyCompletions = {};
    
    for (final task in _allTasks) {
      final dateKey = DateTime(task.date.year, task.date.month, task.date.day);
      if (!dailyCompletions.containsKey(dateKey)) {
        dailyCompletions[dateKey] = _isTaskCompleted(task);
      } else {
        // If multiple tasks for same day, consider day completed if any task is completed
        dailyCompletions[dateKey] = dailyCompletions[dateKey]! || _isTaskCompleted(task);
      }
    }

    // Sort dates
    final sortedDates = dailyCompletions.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    // Calculate longest streak
    for (int i = 0; i < sortedDates.length; i++) {
      final date = sortedDates[i];
      final isCompleted = dailyCompletions[date]!;
      
      if (isCompleted) {
        tempStreak++;
        longestStreak = longestStreak > tempStreak ? longestStreak : tempStreak;
      } else {
        tempStreak = 0;
      }
    }

    // Calculate current streak (working backwards from today)
    DateTime checkDate = today;
    currentStreak = 0;
    
    // Check if today or yesterday has a completed task to start the streak
    while (checkDate.isAfter(today.subtract(const Duration(days: 30)))) {
      if (dailyCompletions.containsKey(checkDate) && dailyCompletions[checkDate]!) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        // If this is the first day we're checking and it's not completed,
        // check the previous day to see if we can start the streak there
        if (currentStreak == 0 && checkDate == today) {
          checkDate = checkDate.subtract(const Duration(days: 1));
          continue;
        }
        break; // Streak is broken
      }
    }

    _currentStreak = currentStreak;
    _longestStreak = longestStreak;
  }

  void _calculateTaskCompletionCounts() {
    _taskCompletionCounts = {
      'Reading Book': 0,
      'Stretch/Workout': 0,
      'Meditation': 0,
      'Reading Docs': 0,
      'Learning Tech': 0,
      'Walking': 0,
      'Avoid Habit': 0,
      'Avoid Sweets': 0,
      'Work Done': 0,
      'Movie/Series': 0,
    };

    for (final task in _allTasks) {
      if (task.readingBookCompleted) _taskCompletionCounts['Reading Book'] = _taskCompletionCounts['Reading Book']! + 1;
      if (task.stretchCompleted) _taskCompletionCounts['Stretch/Workout'] = _taskCompletionCounts['Stretch/Workout']! + 1;
      if (task.meditationCompleted) _taskCompletionCounts['Meditation'] = _taskCompletionCounts['Meditation']! + 1;
      if (task.readingDocsCompleted) _taskCompletionCounts['Reading Docs'] = _taskCompletionCounts['Reading Docs']! + 1;
      if (task.learningTechCompleted) _taskCompletionCounts['Learning Tech'] = _taskCompletionCounts['Learning Tech']! + 1;
      if (task.walkingCompleted) _taskCompletionCounts['Walking'] = _taskCompletionCounts['Walking']! + 1;
      if (task.avoidHabitValue) _taskCompletionCounts['Avoid Habit'] = _taskCompletionCounts['Avoid Habit']! + 1;
      if (task.avoidSweetsValue) _taskCompletionCounts['Avoid Sweets'] = _taskCompletionCounts['Avoid Sweets']! + 1;
      if (task.workDoneValue) _taskCompletionCounts['Work Done'] = _taskCompletionCounts['Work Done']! + 1;
      if (task.movieSeriesCompleted) _taskCompletionCounts['Movie/Series'] = _taskCompletionCounts['Movie/Series']! + 1;
    }
  }

  void _calculateWeeklyCompletionData() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Start from Monday
    
    _weeklyCompletionData = [];
    
    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final tasksForDay = _allTasks.where((task) => 
        task.date.year == date.year &&
        task.date.month == date.month &&
        task.date.day == date.day
      ).toList();
      
      double completionPercentage = 0.0;
      if (tasksForDay.isNotEmpty) {
        // Calculate average completion rate across all tasks for that day
        double totalCompletionRate = 0.0;
        for (final task in tasksForDay) {
          int completedActivities = 0;
          int totalActivities = 10;
          
          if (task.readingBookCompleted) completedActivities++;
          if (task.stretchCompleted) completedActivities++;
          if (task.meditationCompleted) completedActivities++;
          if (task.readingDocsCompleted) completedActivities++;
          if (task.learningTechCompleted) completedActivities++;
          if (task.walkingCompleted) completedActivities++;
          if (task.avoidHabitValue) completedActivities++;
          if (task.avoidSweetsValue) completedActivities++;
          if (task.workDoneValue) completedActivities++;
          if (task.movieSeriesCompleted) completedActivities++;
          
          totalCompletionRate += (completedActivities / totalActivities) * 100;
        }
        completionPercentage = totalCompletionRate / tasksForDay.length;
      }
      
      _weeklyCompletionData.add(FlSpot(i.toDouble(), completionPercentage));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalyticsData,
            tooltip: 'Refresh',
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
                        onPressed: _loadAnalyticsData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Cards
                      _buildSummaryCards(),
                      const SizedBox(height: 24),
                      
                      // Weekly Completion Chart
                      _buildWeeklyCompletionChart(),
                      const SizedBox(height: 24),
                      
                      // Task Completion Breakdown
                      _buildTaskCompletionBreakdown(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Tasks',
                _totalTasks.toString(),
                Icons.assignment,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Completed',
                _completedTasks.toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Completion Rate',
                '${_completionRate.toStringAsFixed(1)}%',
                Icons.trending_up,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Current Streak',
                '$_currentStreak days',
                Icons.local_fire_department,
                Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildSummaryCard(
          'Longest Streak',
          '$_longestStreak days',
          Icons.emoji_events,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyCompletionChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Completion Trend',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}%');
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          final index = value.toInt();
                          if (index >= 0 && index < days.length) {
                            return Text(days[index]);
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _weeklyCompletionData,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCompletionBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Task Completion Breakdown',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: _taskCompletionCounts.entries.map((entry) {
                // Calculate percentage based on how many times this activity was completed
                // out of total possible times (total tasks)
                final percentage = _totalTasks > 0 
                    ? (entry.value / _totalTasks) * 100 
                    : 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          entry.key,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getColorForTask(entry.key),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 80,
                        child: Text(
                          '${entry.value}/${_totalTasks} (${percentage.toStringAsFixed(1)}%)',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Color _getColorForTask(String taskName) {
    switch (taskName) {
      case 'Reading Book':
        return Colors.blue;
      case 'Stretch/Workout':
        return Colors.red;
      case 'Meditation':
        return Colors.purple;
      case 'Reading Docs':
        return Colors.cyan;
      case 'Learning Tech':
        return Colors.green;
      case 'Walking':
        return Colors.orange;
      case 'Avoid Habit':
        return Colors.brown;
      case 'Avoid Sweets':
        return Colors.pink;
      case 'Work Done':
        return Colors.teal;
      case 'Movie/Series':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}