import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/task_entry.dart';
import '../models/daily_entry.dart';
import '../services/supabase_service_v2.dart';
import 'package:intl/intl.dart';

class TaskStatusTable extends StatefulWidget {
  final List<Task> tasks;
  final List<TaskEntry> taskEntries;
  final List<DailyEntry> dailyEntries;
  final Function(Task, List<TaskEntry>) onTaskTap;

  const TaskStatusTable({
    super.key,
    required this.tasks,
    required this.taskEntries,
    required this.dailyEntries,
    required this.onTaskTap,
  });

  @override
  State<TaskStatusTable> createState() => _TaskStatusTableState();
}

class _TaskStatusTableState extends State<TaskStatusTable> {
  String _sortBy = 'name'; // name, completion_rate, total_entries, last_completed
  bool _sortAscending = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TaskStatusData> _getTaskStatusData() {
    List<TaskStatusData> statusData = [];
    
    for (final task in widget.tasks) {
      if (!task.isActive) continue;
      
      final taskEntries = widget.taskEntries
          .where((entry) => entry.taskId == task.id)
          .toList();
      
      final completedEntries = taskEntries.where((entry) => entry.completed).length;
      final totalEntries = taskEntries.length;
      final completionRate = totalEntries > 0 ? (completedEntries / totalEntries) * 100 : 0.0;
      
      // Find last completed entry
      DateTime? lastCompleted;
      if (completedEntries > 0) {
        final completedTaskEntries = taskEntries
            .where((entry) => entry.completed)
            .toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        lastCompleted = completedTaskEntries.first.updatedAt;
      }
      
      // Calculate streak
      int currentStreak = _calculateCurrentStreak(task.id, taskEntries);
      
      statusData.add(TaskStatusData(
        task: task,
        taskEntries: taskEntries,
        totalEntries: totalEntries,
        completedEntries: completedEntries,
        completionRate: completionRate,
        lastCompleted: lastCompleted,
        currentStreak: currentStreak,
      ));
    }
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      statusData = statusData.where((data) => 
        data.task.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (data.task.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
    }
    
    // Sort data
    statusData.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'name':
          comparison = a.task.name.compareTo(b.task.name);
          break;
        case 'completion_rate':
          comparison = a.completionRate.compareTo(b.completionRate);
          break;
        case 'total_entries':
          comparison = a.totalEntries.compareTo(b.totalEntries);
          break;
        case 'last_completed':
          if (a.lastCompleted == null && b.lastCompleted == null) {
            comparison = 0;
          } else if (a.lastCompleted == null) {
            comparison = 1;
          } else if (b.lastCompleted == null) {
            comparison = -1;
          } else {
            comparison = a.lastCompleted!.compareTo(b.lastCompleted!);
          }
          break;
        case 'current_streak':
          comparison = a.currentStreak.compareTo(b.currentStreak);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });
    
    return statusData;
  }
  
  int _calculateCurrentStreak(String taskId, List<TaskEntry> taskEntries) {
    // Get completed entries sorted by date (newest first)
    final completedEntries = taskEntries
        .where((entry) => entry.completed)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    
    if (completedEntries.isEmpty) return 0;
    
    // Group by date and count consecutive days
    final Map<String, bool> dailyCompletions = {};
    for (final entry in completedEntries) {
      final dateKey = DateFormat('yyyy-MM-dd').format(entry.updatedAt);
      dailyCompletions[dateKey] = true;
    }
    
    // Calculate streak from today backwards
    int streak = 0;
    DateTime checkDate = DateTime.now();
    
    while (streak < 365) { // Limit to prevent infinite loop
      final dateKey = DateFormat('yyyy-MM-dd').format(checkDate);
      if (dailyCompletions.containsKey(dateKey)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        // Allow one day gap for today if no completion yet
        if (streak == 0 && dateKey == DateFormat('yyyy-MM-dd').format(DateTime.now())) {
          checkDate = checkDate.subtract(const Duration(days: 1));
          continue;
        }
        break;
      }
    }
    
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    final statusData = _getTaskStatusData();
    
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
          // Header with search
          Column(
            children: [
                 Text(
                  'Task Status Overview',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: 250,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Table
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Use card layout for mobile, table for larger screens
                if (constraints.maxWidth < 800) {
                  return _buildMobileCardLayout(statusData);
                } else {
                  return _buildDesktopTableLayout(statusData);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
  
  DataRow _buildDataRow(TaskStatusData data) {
    return DataRow(
      onSelectChanged: (_) => widget.onTaskTap(data.task, data.taskEntries),
      cells: [
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                data.task.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (data.task.description != null && data.task.description!.isNotEmpty)
                Text(
                  data.task.description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${data.completionRate.toStringAsFixed(1)}%'),
              const SizedBox(width: 8),
              Container(
                width: 60,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: data.completionRate / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: _getCompletionRateColor(data.completionRate),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        DataCell(Text(data.totalEntries.toString())),
        DataCell(Text(data.completedEntries.toString())),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_fire_department,
                size: 16,
                color: data.currentStreak > 0 ? Colors.orange : Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(data.currentStreak.toString()),
            ],
          ),
        ),
        DataCell(
          Text(
            data.lastCompleted != null
                ? DateFormat('MMM dd, yyyy').format(data.lastCompleted!)
                : 'Never',
            style: TextStyle(
              color: data.lastCompleted != null
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ),
        DataCell(_buildStatusChip(data)),
      ],
    );
  }
  
  Widget _buildStatusChip(TaskStatusData data) {
    Color chipColor;
    String statusText;
    
    if (data.totalEntries == 0) {
      chipColor = Colors.grey;
      statusText = 'No Data';
    } else if (data.completionRate >= 80) {
      chipColor = Colors.green;
      statusText = 'Excellent';
    } else if (data.completionRate >= 60) {
      chipColor = Colors.blue;
      statusText = 'Good';
    } else if (data.completionRate >= 40) {
      chipColor = Colors.orange;
      statusText = 'Fair';
    } else {
      chipColor = Colors.red;
      statusText = 'Needs Work';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  Color _getCompletionRateColor(double rate) {
    if (rate >= 80) return Colors.green;
    if (rate >= 60) return Colors.blue;
    if (rate >= 40) return Colors.orange;
    return Colors.red;
  }
  
  int? _getSortColumnIndex() {
    switch (_sortBy) {
      case 'name': return 0;
      case 'completion_rate': return 1;
      case 'total_entries': return 2;
      case 'current_streak': return 4;
      case 'last_completed': return 5;
      default: return null;
    }
  }
  
  void _sort(String columnName, bool ascending) {
    setState(() {
      _sortBy = columnName;
      _sortAscending = ascending;
    });
  }

  Widget _buildDesktopTableLayout(List<TaskStatusData> statusData) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width - 80,
        ),
        child: DataTable(
          sortColumnIndex: _getSortColumnIndex(),
          sortAscending: _sortAscending,
          headingRowColor: MaterialStateProperty.all(
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
          ),
          columns: [
            DataColumn(
              label: const Text('Task Name'),
              onSort: (columnIndex, ascending) => _sort('name', ascending),
            ),
            DataColumn(
              label: const Text('Completion Rate'),
              numeric: true,
              onSort: (columnIndex, ascending) => _sort('completion_rate', ascending),
            ),
            DataColumn(
              label: const Text('Total Entries'),
              numeric: true,
              onSort: (columnIndex, ascending) => _sort('total_entries', ascending),
            ),
            DataColumn(
              label: const Text('Completed'),
              numeric: true,
            ),
            DataColumn(
              label: const Text('Current Streak'),
              numeric: true,
              onSort: (columnIndex, ascending) => _sort('current_streak', ascending),
            ),
            DataColumn(
              label: const Text('Last Completed'),
              onSort: (columnIndex, ascending) => _sort('last_completed', ascending),
            ),
            const DataColumn(
              label: Text('Status'),
            ),
          ],
          rows: statusData.map((data) => _buildDataRow(data)).toList(),
        ),
      ),
    );
  }

  Widget _buildMobileCardLayout(List<TaskStatusData> statusData) {
    return ListView.builder(
      itemCount: statusData.length,
      itemBuilder: (context, index) {
        final data = statusData[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => widget.onTaskTap(data.task, data.taskEntries),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task name with status chip
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.task.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (data.task.description != null && data.task.description!.isNotEmpty)
                              Text(
                                data.task.description!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      _buildStatusChip(data),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Completion rate with progress bar
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Completion Rate',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${data.completionRate.toStringAsFixed(1)}%',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: double.infinity,
                              height: 6,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: data.completionRate / 100,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    color: _getCompletionRateColor(data.completionRate),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Stats row
                  Row(
                    children: [
                      Expanded(
                        child: _buildMobileStatItem(
                          'Total',
                          '${data.totalEntries}',
                          Icons.assignment,
                        ),
                      ),
                      Expanded(
                        child: _buildMobileStatItem(
                          'Completed',
                          '${data.completedEntries}',
                          Icons.check_circle,
                        ),
                      ),
                      Expanded(
                        child: _buildMobileStatItem(
                          'Streak',
                          '${data.currentStreak}',
                          Icons.local_fire_department,
                          iconColor: data.currentStreak > 0 
                              ? Colors.orange 
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Last completed
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Last completed: ${data.lastCompleted != null ? DateFormat('MMM dd, yyyy').format(data.lastCompleted!) : 'Never'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: data.lastCompleted == null 
                              ? Colors.grey 
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileStatItem(String label, String value, IconData icon, {Color? iconColor}) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: iconColor ?? Colors.grey.shade600,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class TaskStatusData {
  final Task task;
  final List<TaskEntry> taskEntries;
  final int totalEntries;
  final int completedEntries;
  final double completionRate;
  final DateTime? lastCompleted;
  final int currentStreak;
  
  TaskStatusData({
    required this.task,
    required this.taskEntries,
    required this.totalEntries,
    required this.completedEntries,
    required this.completionRate,
    required this.lastCompleted,
    required this.currentStreak,
  });
}