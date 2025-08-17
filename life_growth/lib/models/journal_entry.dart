import 'package:json_annotation/json_annotation.dart';

part 'journal_entry.g.dart';

@JsonSerializable()
class JournalEntry {
  final String id;
  final String title;
  final String content;
  final int mood; // 1-10 scale
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool needsSync;
  final DateTime? lastSyncAt;
  
  const JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    this.mood = 5,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
    this.needsSync = true,
    this.lastSyncAt,
  });
  
  factory JournalEntry.fromJson(Map<String, dynamic> json) => _$JournalEntryFromJson(json);
  Map<String, dynamic> toJson() => _$JournalEntryToJson(this);
  
  JournalEntry copyWith({
    String? id,
    String? title,
    String? content,
    int? mood,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? needsSync,
    DateTime? lastSyncAt,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      needsSync: needsSync ?? this.needsSync,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JournalEntry && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return 'JournalEntry(id: $id, title: $title, mood: $mood, tags: $tags)';
  }
}