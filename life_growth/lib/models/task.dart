class Task {
  final String id;
  final String userId;
  final String taskTypeId;
  final String name;
  final String? description;
  final Map<String, dynamic>? customSchema;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const Task({
    required this.id,
    required this.userId,
    required this.taskTypeId,
    required this.name,
    this.description,
    this.customSchema,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      userId: json['user_id'],
      taskTypeId: json['task_type_id'],
      name: json['name'],
      description: json['description'],
      customSchema: json['custom_schema'] as Map<String, dynamic>?,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'task_type_id': taskTypeId,
      'name': name,
      if (description != null) 'description': description,
      if (customSchema != null) 'custom_schema': customSchema,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (deletedAt != null) 'deleted_at': deletedAt!.toIso8601String(),
    };
  }

  Task copyWith({
    String? id,
    String? userId,
    String? taskTypeId,
    String? name,
    String? description,
    Map<String, dynamic>? customSchema,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      taskTypeId: taskTypeId ?? this.taskTypeId,
      name: name ?? this.name,
      description: description ?? this.description,
      customSchema: customSchema ?? this.customSchema,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}