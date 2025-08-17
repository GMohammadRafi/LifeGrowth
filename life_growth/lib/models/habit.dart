import 'package:json_annotation/json_annotation.dart';

part 'habit.g.dart';

enum HabitFrequency {
  daily,
  weekly,
  monthly,
}

@JsonSerializable()
class Habit {
  final String id;
  final String name;
  final String description;
  final HabitFrequency frequency;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool needsSync;
  final DateTime? lastSyncAt;
  
  const Habit({
    required this.id,
    required this.name,
    required this.description,
    required this.frequency,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.needsSync = true,
    this.lastSyncAt,
  });
  
  factory Habit.fromJson(Map<String, dynamic> json) => _$HabitFromJson(json);
  Map<String, dynamic> toJson() => _$HabitToJson(this);
  
  Habit copyWith({
    String? id,
    String? name,
    String? description,
    HabitFrequency? frequency,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? needsSync,
    DateTime? lastSyncAt,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      needsSync: needsSync ?? this.needsSync,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Habit && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return 'Habit(id: $id, name: $name, frequency: $frequency, isActive: $isActive)';
  }
}