class PersonalizationSettings {
  final List<String> taskOrder;
  final Set<String> hiddenTasks;
  final String avoidHabitLabel;
  final bool showAvoidSweets;

  const PersonalizationSettings({
    required this.taskOrder,
    required this.hiddenTasks,
    required this.avoidHabitLabel,
    required this.showAvoidSweets,
  });

  // Default task order
  static const List<String> defaultTaskOrder = [
    'readingBook',
    'stretch',
    'meditation',
    'readingDocs',
    'learningTech',
    'walking',
    'avoidHabit',
    'avoidSweets',
    'workDone',
    'movieSeries',
  ];

  // Default settings
  static const PersonalizationSettings defaultSettings = PersonalizationSettings(
    taskOrder: defaultTaskOrder,
    hiddenTasks: {},
    avoidHabitLabel: 'Avoid X',
    showAvoidSweets: true,
  );

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'taskOrder': taskOrder,
      'hiddenTasks': hiddenTasks.toList(),
      'avoidHabitLabel': avoidHabitLabel,
      'showAvoidSweets': showAvoidSweets,
    };
  }

  // Create from JSON
  factory PersonalizationSettings.fromJson(Map<String, dynamic> json) {
    return PersonalizationSettings(
      taskOrder: List<String>.from(json['taskOrder'] ?? defaultTaskOrder),
      hiddenTasks: Set<String>.from(json['hiddenTasks'] ?? []),
      avoidHabitLabel: json['avoidHabitLabel'] ?? 'Avoid X',
      showAvoidSweets: json['showAvoidSweets'] ?? true,
    );
  }

  // Copy with changes
  PersonalizationSettings copyWith({
    List<String>? taskOrder,
    Set<String>? hiddenTasks,
    String? avoidHabitLabel,
    bool? showAvoidSweets,
  }) {
    return PersonalizationSettings(
      taskOrder: taskOrder ?? this.taskOrder,
      hiddenTasks: hiddenTasks ?? this.hiddenTasks,
      avoidHabitLabel: avoidHabitLabel ?? this.avoidHabitLabel,
      showAvoidSweets: showAvoidSweets ?? this.showAvoidSweets,
    );
  }

  // Get visible tasks in order
  List<String> get visibleTasksInOrder {
    return taskOrder.where((task) => !hiddenTasks.contains(task)).toList();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PersonalizationSettings &&
        other.taskOrder.toString() == taskOrder.toString() &&
        other.hiddenTasks.toString() == hiddenTasks.toString() &&
        other.avoidHabitLabel == avoidHabitLabel &&
        other.showAvoidSweets == showAvoidSweets;
  }

  @override
  int get hashCode {
    return taskOrder.hashCode ^
        hiddenTasks.hashCode ^
        avoidHabitLabel.hashCode ^
        showAvoidSweets.hashCode;
  }
}