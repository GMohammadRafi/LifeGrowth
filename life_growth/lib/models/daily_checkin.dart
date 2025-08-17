import 'package:json_annotation/json_annotation.dart';

part 'daily_checkin.g.dart';

@JsonSerializable()
class DailyCheckin {
  final String id;
  final DateTime date;
  final int mood; // 1-10 scale
  final int energy; // 1-10 scale
  final int stress; // 1-10 scale
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool needsSync;
  final DateTime? lastSyncAt;
  
  const DailyCheckin({
    required this.id,
    required this.date,
    required this.mood,
    required this.energy,
    required this.stress,
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
    this.needsSync = true,
    this.lastSyncAt,
  });
  
  factory DailyCheckin.fromJson(Map<String, dynamic> json) => _$DailyCheckinFromJson(json);
  Map<String, dynamic> toJson() => _$DailyCheckinToJson(this);
  
  DailyCheckin copyWith({
    String? id,
    DateTime? date,
    int? mood,
    int? energy,
    int? stress,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? needsSync,
    DateTime? lastSyncAt,
  }) {
    return DailyCheckin(
      id: id ?? this.id,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      energy: energy ?? this.energy,
      stress: stress ?? this.stress,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      needsSync: needsSync ?? this.needsSync,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyCheckin && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return 'DailyCheckin(id: $id, date: $date, mood: $mood, energy: $energy, stress: $stress)';
  }
}