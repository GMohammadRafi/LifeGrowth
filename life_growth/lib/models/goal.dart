import 'package:json_annotation/json_annotation.dart';

part 'goal.g.dart';

enum GoalCategory {
  personal,
  professional,
  health,
  education,
  financial,
  relationships,
  hobbies,
  other,
}

enum GoalPriority {
  low,
  medium,
  high,
  urgent,
}

@JsonSerializable()
class Goal {
  final String id;
  final String title;
  final String description;
  final GoalCategory category;
  final GoalPriority priority;
  final DateTime targetDate;
  final bool isCompleted;
  final DateTime? completedAt;
  final int progress; // 0-100 percentage
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool needsSync;
  final DateTime? lastSyncAt;
  
  const Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.priority = GoalPriority.medium,
    required this.targetDate,
    this.isCompleted = false,
    this.completedAt,
    this.progress = 0,
    required this.createdAt,
    required this.updatedAt,
    this.needsSync = true,
    this.lastSyncAt,
  });
  
  factory Goal.fromJson(Map<String, dynamic> json) => _$GoalFromJson(json);
  Map<String, dynamic> toJson() => _$GoalToJson(this);
  
  Goal copyWith({
    String? id,
    String? title,
    String? description,
    GoalCategory? category,
    GoalPriority? priority,
    DateTime? targetDate,
    bool? isCompleted,
    DateTime? completedAt,
    int? progress,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? needsSync,
    DateTime? lastSyncAt,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      targetDate: targetDate ?? this.targetDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      progress: progress ?? this.progress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      needsSync: needsSync ?? this.needsSync,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Goal && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return 'Goal(id: $id, title: $title, category: $category, isCompleted: $isCompleted, progress: $progress%)';
  }
}