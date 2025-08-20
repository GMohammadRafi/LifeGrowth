class CustomReminder {
  final String? id;
  final String? userId;
  final String title;
  final String? description;
  final DateTime reminderTime;
  final bool isRecurring;
  final String? recurrencePattern; // 'daily', 'weekly', 'monthly', etc.
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CustomReminder({
    this.id,
    this.userId,
    required this.title,
    this.description,
    required this.reminderTime,
    this.isRecurring = false,
    this.recurrencePattern,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  // Copy with method for immutable updates
  CustomReminder copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? reminderTime,
    bool? isRecurring,
    String? recurrencePattern,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomReminder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      reminderTime: reminderTime ?? this.reminderTime,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'title': title,
      if (description != null) 'description': description,
      'reminder_time': reminderTime.toIso8601String(),
      'is_recurring': isRecurring,
      if (recurrencePattern != null) 'recurrence_pattern': recurrencePattern,
      'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  // JSON deserialization
  factory CustomReminder.fromJson(Map<String, dynamic> json) {
    return CustomReminder(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      reminderTime: DateTime.parse(json['reminder_time']),
      isRecurring: json['is_recurring'] ?? false,
      recurrencePattern: json['recurrence_pattern'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomReminder &&
        other.id == id &&
        other.userId == userId &&
        other.title == title;
  }

  @override
  int get hashCode => Object.hash(id, userId, title);

  @override
  String toString() {
    return 'CustomReminder(id: $id, title: $title, reminderTime: $reminderTime, isActive: $isActive)';
  }
}