class TaskEntry {
  final String id;
  final String dailyEntryId;
  final String taskId;
  final Map<String, dynamic> data;
  final bool completed;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const TaskEntry({
    required this.id,
    required this.dailyEntryId,
    required this.taskId,
    required this.data,
    this.completed = false,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory TaskEntry.fromJson(Map<String, dynamic> json) {
    return TaskEntry(
      id: json['id'],
      dailyEntryId: json['daily_entry_id'],
      taskId: json['task_id'],
      data: json['data'] as Map<String, dynamic>,
      completed: json['completed'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'daily_entry_id': dailyEntryId,
      'task_id': taskId,
      'data': data,
      'completed': completed,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (deletedAt != null) 'deleted_at': deletedAt!.toIso8601String(),
    };
  }

  TaskEntry copyWith({
    String? id,
    String? dailyEntryId,
    String? taskId,
    Map<String, dynamic>? data,
    bool? completed,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return TaskEntry(
      id: id ?? this.id,
      dailyEntryId: dailyEntryId ?? this.dailyEntryId,
      taskId: taskId ?? this.taskId,
      data: data ?? this.data,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  // Helper methods to get typed data
  T? getDataValue<T>(String key) {
    return data[key] as T?;
  }

  int? getIntValue(String key) => getDataValue<int>(key);
  String? getStringValue(String key) => getDataValue<String>(key);
  bool? getBoolValue(String key) => getDataValue<bool>(key);
  double? getDoubleValue(String key) => getDataValue<double>(key);
}