// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_checkin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyCheckin _$DailyCheckinFromJson(Map<String, dynamic> json) => DailyCheckin(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      mood: (json['mood'] as num).toInt(),
      energy: (json['energy'] as num).toInt(),
      stress: (json['stress'] as num).toInt(),
      notes: json['notes'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      needsSync: json['needsSync'] as bool? ?? true,
      lastSyncAt: json['lastSyncAt'] == null
          ? null
          : DateTime.parse(json['lastSyncAt'] as String),
    );

Map<String, dynamic> _$DailyCheckinToJson(DailyCheckin instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'mood': instance.mood,
      'energy': instance.energy,
      'stress': instance.stress,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'needsSync': instance.needsSync,
      'lastSyncAt': instance.lastSyncAt?.toIso8601String(),
    };
