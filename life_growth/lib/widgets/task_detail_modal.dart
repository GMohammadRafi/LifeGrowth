import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/task_entry.dart';
import '../models/daily_entry.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';

class TaskDetailModal extends StatefulWidget {
  final Task task;
  final List<TaskEntry> taskEntries;
  final List<DailyEntry> dailyEntries;

  const TaskDetailModal({
    super.key,
    required this.task,
    required this.taskEntries,
    required this.dailyEntries,
  });

  @override
  State<TaskDetailModal> createState() => _TaskDetailModalState();
}

class _TaskDetailModalState extends State<TaskDetailModal> with TickerProviderStateMixin {
  late TabController _tabController;
  String _timeFilter = 'all'; // all, week, month, year
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<TaskEntry> _getFilteredEntries() {
    final now = DateTime.now();
    DateTime startDate;
    
    switch (_timeFilter) {
      case 'week':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'month':
        // Safely calculate one month ago
        final year = now.month == 1 ? now.year - 1 : now.year;
        final month = now.month == 1 ? 12 : now.month - 1;
        // Use the first day of the month to avoid day overflow issues
        startDate = DateTime(year, month, 1);
        break;
      case 'year':
        // Use the same date one year ago, but handle leap year edge case
        startDate = DateTime(now.year - 1, now.month, now.day > 28 && now.month == 2 ? 28 : now.day);
        break;
      default:
        return widget.taskEntries;
    }
    
    return widget.taskEntries
        .where((entry) => entry.createdAt.isAfter(startDate))
        .toList();
  }

  Map<String, List<TaskEntry>> _groupEntriesByDay(List<TaskEntry> entries) {
    final Map<String, List<TaskEntry>> groupedEntries = {};
    
    for (final entry in entries) {
      final dateKey = DateFormat('yyyy-MM-dd').format(entry.createdAt);
      if (groupedEntries[dateKey] == null) {
        groupedEntries[dateKey] = [];
      }
      groupedEntries[dateKey]!.add(entry);
    }
    
    // Sort entries within each day by time (newest first)
    for (final dayEntries in groupedEntries.values) {
      dayEntries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    
    return groupedEntries;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isMobile = screenSize.width < 600;
    
    if (isMobile) {
      // Full screen modal for mobile
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.task.name),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            // Time filter dropdown for mobile
             PopupMenuButton<String>(
               initialValue: _timeFilter,
               onSelected: (value) {
                 if (value != null) {
                   setState(() {
                     _timeFilter = value;
                   });
                 }
               },
               itemBuilder: (context) => const [
                 PopupMenuItem(value: 'all', child: Text('All Time')),
                 PopupMenuItem(value: 'year', child: Text('Past Year')),
                 PopupMenuItem(value: 'month', child: Text('Past Month')),
                 PopupMenuItem(value: 'week', child: Text('Past Week')),
               ],
               icon: const Icon(Icons.filter_list),
             ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Overview', icon: Icon(Icons.analytics)),
              Tab(text: 'Timeline', icon: Icon(Icons.timeline)),
              Tab(text: 'Statistics', icon: Icon(Icons.bar_chart)),
              Tab(text: 'Calendar', icon: Icon(Icons.calendar_month)),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildTimelineTab(),
            _buildStatisticsTab(),
            _buildCalendarTab(),
          ],
        ),
      );
    } else {
      // Dialog for tablet and desktop
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: isTablet ? screenSize.width * 0.85 : screenSize.width * 0.9,
          height: screenSize.height * 0.8,
          constraints: const BoxConstraints(
            maxWidth: 1000,
            maxHeight: 800,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.task.name,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (widget.task.description != null && widget.task.description!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                widget.task.description!,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Time filter dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _timeFilter,
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('All Time')),
                            DropdownMenuItem(value: 'year', child: Text('Past Year')),
                            DropdownMenuItem(value: 'month', child: Text('Past Month')),
                            DropdownMenuItem(value: 'week', child: Text('Past Week')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _timeFilter = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              
              // Tab bar
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Overview', icon: Icon(Icons.analytics)),
                  Tab(text: 'Timeline', icon: Icon(Icons.timeline)),
                  Tab(text: 'Statistics', icon: Icon(Icons.bar_chart)),
                  Tab(text: 'Calendar', icon: Icon(Icons.calendar_month)),
                ],
              ),
              
              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildTimelineTab(),
                    _buildStatisticsTab(),
                    _buildCalendarTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
  
  Widget _buildOverviewTab() {
    final filteredEntries = _getFilteredEntries();
    final completedEntries = filteredEntries.where((e) => e.completed).length;
    final totalEntries = filteredEntries.length;
    final completionRate = totalEntries > 0 ? (completedEntries / totalEntries) * 100 : 0.0;
    
    // Calculate streak
    final currentStreak = _calculateCurrentStreak(filteredEntries);
    final longestStreak = _calculateLongestStreak(filteredEntries);
    
    // Recent activity
    final recentEntries = filteredEntries
        .where((e) => e.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards with responsive layout
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              
              if (isMobile) {
                // Mobile: 2x2 grid
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            'Total Entries',
                            totalEntries.toString(),
                            Icons.assignment,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            'Completed',
                            completedEntries.toString(),
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
                            '${completionRate.toStringAsFixed(1)}%',
                            Icons.trending_up,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            'Current Streak',
                            '$currentStreak days',
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
                            '$longestStreak days',
                            Icons.emoji_events,
                            Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ],
                );
              } else {
                // Desktop/Tablet: 2x3 grid
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            'Total Entries',
                            totalEntries.toString(),
                            Icons.assignment,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            'Completed',
                            completedEntries.toString(),
                            Icons.check_circle,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            'Completion Rate',
                            '${completionRate.toStringAsFixed(1)}%',
                            Icons.trending_up,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            'Current Streak',
                            '$currentStreak days',
                            Icons.local_fire_department,
                            Colors.red,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            'Longest Streak',
                            '$longestStreak days',
                            Icons.emoji_events,
                            Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ],
                );
              }
            },
          ),
          
          const SizedBox(height: 24),
          
          // Recent activity
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          if (recentEntries.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Center(
                child: Text(
                  'No recent activity',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            )
          else
            ...recentEntries.take(5).map((entry) => _buildActivityItem(entry)),
        ],
      ),
    );
  }
  
  Widget _buildTimelineTab() {
    final filteredEntries = _getFilteredEntries();
    final groupedEntries = _groupEntriesByDay(filteredEntries);
    final sortedDates = groupedEntries.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Sort dates in descending order (newest first)
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Completion Timeline',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          if (filteredEntries.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Center(
                child: Text(
                  'No entries found for the selected time period',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            )
          else
            ...sortedDates.map((dateKey) {
              final dayEntries = groupedEntries[dateKey]!;
              final date = DateTime.parse(dateKey);
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Daily header
                  Container(
                    margin: const EdgeInsets.only(bottom: 12, top: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      DateFormat('EEEE, MMMM dd, yyyy').format(date),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  // Entries for this day
                  ...dayEntries.asMap().entries.map((entryWithIndex) {
                    final index = entryWithIndex.key;
                    final entry = entryWithIndex.value;
                    final isLastInDay = index == dayEntries.length - 1;
                    final isLastOverall = dateKey == sortedDates.last && isLastInDay;
                    return _buildTimelineItem(entry, isLastOverall);
                  }).toList(),
                ],
              );
            }).toList(),
        ],
      ),
    );
  }
  
  Widget _buildStatisticsTab() {
    final filteredEntries = _getFilteredEntries();
    final completionData = _getCompletionChartData(filteredEntries);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Completion Statistics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Completion chart
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: completionData.isEmpty
                ? Center(
                    child: Text(
                      'No data available for chart',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval: 1,
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
                              if (value.toInt() >= 0 && value.toInt() < completionData.length) {
                                final date = DateTime.now().subtract(
                                  Duration(days: completionData.length - value.toInt() - 1),
                                );
                                return Text(
                                  DateFormat('MM/dd').format(date),
                                  style: const TextStyle(fontSize: 10),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      minX: 0,
                      maxX: completionData.length.toDouble() - 1,
                      minY: 0,
                      maxY: completionData.isNotEmpty
                          ? completionData.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 1
                          : 5,
                      lineBarsData: [
                        LineChartBarData(
                          spots: completionData,
                          isCurved: true,
                          color: Theme.of(context).colorScheme.primary,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          
          const SizedBox(height: 20),
          
          // Additional statistics
          _buildStatisticsGrid(filteredEntries),
        ],
      ),
    );
  }
  
  Widget _buildCalendarTab() {
    final filteredEntries = _getFilteredEntries();
    final completedDates = _getCompletedTaskDates(filteredEntries);
    final pendingDates = _getPendingTaskDates(filteredEntries);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Task Completion Calendar',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Legend
          Row(
            children: [
              Expanded(
                child: _buildLegendItem(
                  'Completed',
                  Theme.of(context).colorScheme.primary,
                  Icons.check_circle,
                ),
              ),
              Expanded(
                child: _buildLegendItem(
                  'Pending',
                  Colors.orange,
                  Icons.pending,
                ),
              ),
              Expanded(
                child: _buildLegendItem(
                  'No Tasks',
                  Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  Icons.circle_outlined,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Calendar
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: TableCalendar<TaskEntry>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: DateTime.now(),
              calendarFormat: CalendarFormat.month,
              eventLoader: (day) {
                return filteredEntries
                    .where((entry) {
                      // Use updatedAt for completed tasks (when they were completed)
                      // Use createdAt for pending tasks (when they were created)
                      final dateToCheck = entry.completed ? entry.updatedAt : entry.createdAt;
                      return isSameDay(dateToCheck, day);
                    })
                    .toList();
              },
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
                holidayTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
                markersMaxCount: 1,
                markerDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ) ?? const TextStyle(),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  return _buildCalendarDay(day, completedDates, pendingDates);
                },
                todayBuilder: (context, day, focusedDay) {
                  return _buildCalendarDay(day, completedDates, pendingDates, isToday: true);
                },
                outsideBuilder: (context, day, focusedDay) {
                  return Container(
                    margin: const EdgeInsets.all(4),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Calendar statistics
          _buildCalendarStatistics(completedDates, pendingDates),
        ],
      ),
    );
  }
  
  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivityItem(TaskEntry entry) {
    final dailyEntry = widget.dailyEntries
        .where((de) => de.id == entry.dailyEntryId)
        .firstOrNull;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: entry.completed ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.completed ? 'Completed' : 'Not Completed',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: entry.completed ? Colors.green : Colors.grey,
                  ),
                ),
                Text(
                  DateFormat('MMM dd, yyyy at HH:mm').format(entry.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                if (dailyEntry != null)
                  Text(
                    'Entry: ${DateFormat('MMM dd, yyyy').format(dailyEntry.date)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimelineItem(TaskEntry entry, bool isLast) {
    final dailyEntry = widget.dailyEntries
        .where((de) => de.id == entry.dailyEntryId)
        .firstOrNull;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: entry.completed ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 2,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      entry.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: entry.completed ? Colors.green : Colors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      entry.completed ? 'Completed' : 'Not Completed',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: entry.completed ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('HH:mm').format(entry.createdAt), // Only show time since date is in header
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                if (dailyEntry != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Daily Entry: ${DateFormat('MMM dd, yyyy').format(dailyEntry.date)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
                if (entry.data.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Data: ${entry.data.toString()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatisticsGrid(List<TaskEntry> entries) {
    final completedEntries = entries.where((e) => e.completed).length;
    final totalEntries = entries.length;
    final averagePerWeek = _calculateAveragePerWeek(entries);
    final bestStreak = _calculateLongestStreak(entries);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate appropriate aspect ratio based on available width
        final cardWidth = (constraints.maxWidth - 12) / 2; // Account for spacing
        final aspectRatio = cardWidth / 80; // Minimum height of 80 for content
        
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: aspectRatio.clamp(1.5, 3.0), // Ensure reasonable bounds
          children: [
            _buildStatCard('Total Entries', totalEntries.toString(), Icons.assignment),
            _buildStatCard('Completed', completedEntries.toString(), Icons.check_circle),
            _buildStatCard('Avg/Week', averagePerWeek.toStringAsFixed(1), Icons.trending_up),
            _buildStatCard('Best Streak', '$bestStreak days', Icons.emoji_events),
          ],
        );
      },
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
  
  List<FlSpot> _getCompletionChartData(List<TaskEntry> entries) {
    if (entries.isEmpty) return [];
    
    // Group entries by date
    final Map<String, int> dailyCounts = {};
    for (final entry in entries) {
      final dateKey = DateFormat('yyyy-MM-dd').format(entry.createdAt);
      dailyCounts[dateKey] = (dailyCounts[dateKey] ?? 0) + (entry.completed ? 1 : 0);
    }
    
    // Create chart data for the last 30 days
    final List<FlSpot> spots = [];
    final now = DateTime.now();
    
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      final count = dailyCounts[dateKey] ?? 0;
      spots.add(FlSpot((29 - i).toDouble(), count.toDouble()));
    }
    
    return spots;
  }
  
  int _calculateCurrentStreak(List<TaskEntry> entries) {
    final completedEntries = entries
        .where((e) => e.completed)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    if (completedEntries.isEmpty) return 0;
    
    final Map<String, bool> dailyCompletions = {};
    for (final entry in completedEntries) {
      final dateKey = DateFormat('yyyy-MM-dd').format(entry.createdAt);
      dailyCompletions[dateKey] = true;
    }
    
    int streak = 0;
    DateTime checkDate = DateTime.now();
    
    while (streak < 365) {
      final dateKey = DateFormat('yyyy-MM-dd').format(checkDate);
      if (dailyCompletions.containsKey(dateKey)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        if (streak == 0 && dateKey == DateFormat('yyyy-MM-dd').format(DateTime.now())) {
          checkDate = checkDate.subtract(const Duration(days: 1));
          continue;
        }
        break;
      }
    }
    
    return streak;
  }
  
  int _calculateLongestStreak(List<TaskEntry> entries) {
    final completedEntries = entries
        .where((e) => e.completed)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    
    if (completedEntries.isEmpty) return 0;
    
    final Map<String, bool> dailyCompletions = {};
    for (final entry in completedEntries) {
      final dateKey = DateFormat('yyyy-MM-dd').format(entry.createdAt);
      dailyCompletions[dateKey] = true;
    }
    
    final sortedDates = dailyCompletions.keys.toList()
      ..sort();
    
    int longestStreak = 0;
    int currentStreak = 0;
    DateTime? lastDate;
    
    for (final dateStr in sortedDates) {
      final date = DateTime.parse(dateStr);
      
      if (lastDate == null || date.difference(lastDate).inDays == 1) {
        currentStreak++;
        longestStreak = longestStreak > currentStreak ? longestStreak : currentStreak;
      } else {
        currentStreak = 1;
      }
      
      lastDate = date;
    }
    
    return longestStreak;
  }
  
  double _calculateAveragePerWeek(List<TaskEntry> entries) {
    if (entries.isEmpty) return 0.0;
    
    final now = DateTime.now();
    final oldestEntry = entries.reduce((a, b) => a.createdAt.isBefore(b.createdAt) ? a : b);
    final daysDifference = now.difference(oldestEntry.createdAt).inDays;
    final weeks = daysDifference / 7;
    
    return weeks > 0 ? entries.length / weeks : entries.length.toDouble();
  }
  
  Set<DateTime> _getCompletedTaskDates(List<TaskEntry> entries) {
    return entries
        .where((entry) => entry.completed)
        .map((entry) => DateTime(entry.updatedAt.year, entry.updatedAt.month, entry.updatedAt.day))
        .toSet();
  }

  Set<DateTime> _getPendingTaskDates(List<TaskEntry> entries) {
    return entries
        .where((entry) => !entry.completed)
        .map((entry) => DateTime(entry.createdAt.year, entry.createdAt.month, entry.createdAt.day))
        .toSet();
  }
  
  Widget _buildCalendarDay(DateTime day, Set<DateTime> completedDates, Set<DateTime> pendingDates, {bool isToday = false}) {
    final dayOnly = DateTime(day.year, day.month, day.day);
    final hasCompleted = completedDates.contains(dayOnly);
    final hasPending = pendingDates.contains(dayOnly);
    
    Color? backgroundColor;
    Color? textColor;
    Border? border;
    
    if (hasCompleted && hasPending) {
      // Mixed: completed and pending tasks
      backgroundColor = Theme.of(context).colorScheme.primary.withOpacity(0.7);
      textColor = Theme.of(context).colorScheme.onPrimary;
    } else if (hasCompleted) {
      // Only completed tasks
      backgroundColor = Theme.of(context).colorScheme.primary;
      textColor = Theme.of(context).colorScheme.onPrimary;
    } else if (hasPending) {
      // Only pending tasks
      backgroundColor = Colors.orange.withOpacity(0.7);
      textColor = Colors.white;
    }
    
    if (isToday) {
      border = Border.all(
        color: Theme.of(context).colorScheme.secondary,
        width: 2,
      );
    }
    
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: border,
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: TextStyle(
          color: textColor ?? Theme.of(context).colorScheme.onSurface,
          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
  
  Widget _buildLegendItem(String label, Color color, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
  
  Widget _buildCalendarStatistics(Set<DateTime> completedDates, Set<DateTime> pendingDates) {
    final totalDaysWithTasks = completedDates.length + pendingDates.length;
    final completionPercentage = totalDaysWithTasks > 0 
        ? (completedDates.length / totalDaysWithTasks * 100).toStringAsFixed(1)
        : '0.0';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calendar Statistics',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Days with Completed Tasks', completedDates.length.toString()),
              ),
              Expanded(
                child: _buildStatItem('Days with Pending Tasks', pendingDates.length.toString()),
              ),
              Expanded(
                child: _buildStatItem('Completion Rate', '$completionPercentage%'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}