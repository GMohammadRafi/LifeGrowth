import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/supabase_service_v2.dart';
import '../services/auth_service.dart';
import '../services/telemetry_service.dart';
import '../models/daily_entry.dart';
import '../models/task_entry.dart';
import '../models/task.dart';
import '../models/task_type.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<DailyEntry> _allEntries = [];
  List<TaskEntry> _allTaskEntries = [];
  List<Task> _userTasks = [];
  List<TaskType> _taskTypes = [];
  
  // Analytics data
  int _totalEntries = 0;
  int _completedEntries = 0;
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
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User not authenticated';
        });
      }
      return;
    }

    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }

      final userId = AuthService.userId!;
      
      // Load all data for analytics
      final entries = await SupabaseServiceV2.getAllDailyEntries(userId);
      final taskEntries = await SupabaseServiceV2.getAllTaskEntries(userId);
      final tasks = await SupabaseServiceV2.getUserTasks(userId);
      final taskTypes = await SupabaseServiceV2.getTaskTypes();

      _allEntries = entries;
      _allTaskEntries = taskEntries;
      _userTasks = tasks;
      _taskTypes = taskTypes;
      
      _calculateAnalytics();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load analytics data: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _calculateAnalytics() {
    if (_allEntries.isEmpty) return;

    _totalEntries = _allEntries.length;
    _completedEntries = _allEntries.where((entry) => _isEntryCompleted(entry)).length;
    _completionRate = _totalEntries > 0 ? (_completedEntries / _totalEntries) * 100 : 0.0;

    _calculateStreaks();
    _calculateTaskCompletionCounts();
    _calculateWeeklyCompletionData();
  }

  bool _isEntryCompleted(DailyEntry entry) {
    // Get task entries for this daily entry
    final entryTaskEntries = _allTaskEntries.where(
      (taskEntry) => taskEntry.dailyEntryId == entry.id
    ).toList();
    
    if (entryTaskEntries.isEmpty) return false;
    
    // Consider entry completed if at least 50% of tasks are completed
    final completedTasks = entryTaskEntries.where((te) => te.completed).length;
    return completedTasks >= (entryTaskEntries.length * 0.5);
  }

  void _calculateStreaks() {
    if (_allEntries.isEmpty) return;

    // Group entries by date and check if each day is completed
    final Map<DateTime, bool> dailyCompletions = {};
    
    for (final entry in _allEntries) {
      final dateKey = DateTime(entry.date.year, entry.date.month, entry.date.day);
      if (!dailyCompletions.containsKey(dateKey)) {
        dailyCompletions[dateKey] = _isEntryCompleted(entry);
      } else {
        // If multiple entries for same day, consider day completed if any entry is completed
        dailyCompletions[dateKey] = dailyCompletions[dateKey]! || _isEntryCompleted(entry);
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
    _taskCompletionCounts = {};
    
    // Initialize counts for all user tasks
    for (final task in _userTasks) {
      _taskCompletionCounts[task.name] = 0;
    }

    // Count completions for each task
    for (final taskEntry in _allTaskEntries) {
      if (taskEntry.completed) {
        final task = _userTasks.firstWhere(
          (t) => t.id == taskEntry.taskId,
          orElse: () => Task(
            id: '',
            userId: '',
            taskTypeId: '',
            name: 'Unknown Task',
            description: '',
            customSchema: {},
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        _taskCompletionCounts[task.name] = (_taskCompletionCounts[task.name] ?? 0) + 1;
      }
    }
  }

  void _calculateWeeklyCompletionData() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Start from Monday
    
    _weeklyCompletionData = [];
    
    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final entriesForDay = _allEntries.where((entry) => 
        entry.date.year == date.year &&
        entry.date.month == date.month &&
        entry.date.day == date.day
      ).toList();
      
      double completionPercentage = 0.0;
      if (entriesForDay.isNotEmpty) {
        // Calculate average completion rate across all entries for that day
        double totalCompletionRate = 0.0;
        for (final entry in entriesForDay) {
          final entryTaskEntries = _allTaskEntries.where(
            (te) => te.dailyEntryId == entry.id
          ).toList();
          
          if (entryTaskEntries.isNotEmpty) {
            final completedTasks = entryTaskEntries.where((te) => te.completed).length;
            totalCompletionRate += (completedTasks / entryTaskEntries.length) * 100;
          }
        }
        completionPercentage = totalCompletionRate / entriesForDay.length;
      }
      
      _weeklyCompletionData.add(FlSpot(i.toDouble(), completionPercentage));
    }
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Theme.of(context).colorScheme.background,
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards
                    _buildSummaryCards(),
                    const SizedBox(height: 32),
                    
                    // Weekly Completion Chart
                    _buildWeeklyCompletionChart(),
                    const SizedBox(height: 32),
                    
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
              'Total Entries',
              _totalEntries.toString(),
              Icons.assignment,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Completed',
              _completedEntries.toString(),
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
      Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Longest Streak',
              '$_longestStreak days',
              Icons.emoji_events,
              Colors.amber,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(child: SizedBox()), // Empty space for alignment
        ],
      ),
    ],
  );
}

Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
  return Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
  return Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Completion Trend',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              horizontalInterval: 25,
              verticalInterval: 1,
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                    if (value.toInt() >= 0 && value.toInt() < days.length) {
                      return Text(days[value.toInt()]);
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text('${value.toInt()}%');
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: const Color(0xff37434d)),
            ),
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
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.blue.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
      ],
    ),
  );
}

Widget _buildTaskCompletionBreakdown() {
  return Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Task Completion Breakdown',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 20),
        Column(
          children: _taskCompletionCounts.entries.map((entry) {
              if (entry.value == 0) return const SizedBox.shrink();
              
              final percentage = _totalEntries > 0
                  ? (entry.value / _totalEntries) * 100
                  : 0.0;
              
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        entry.key,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: percentage / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: _getColorForTask(entry.key),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 90,
                      child: Text(
                        '${entry.value}/${_totalEntries} (${percentage.toStringAsFixed(1)}%)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        ),
      ],
    ),
  );
}

Color _getColorForTask(String taskName) {
  // Generate colors based on task name hash for consistency
  final hash = taskName.hashCode;
  final colors = [
    Colors.blue, Colors.red, Colors.purple, Colors.cyan,
    Colors.green, Colors.orange, Colors.brown, Colors.pink,
    Colors.teal, Colors.indigo, Colors.amber, Colors.deepOrange,
  ];
  return colors[hash.abs() % colors.length];
}}