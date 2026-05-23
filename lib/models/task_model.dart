import 'package:flutter/material.dart';

enum PriorityLevel { low, medium, high }

enum ReminderType { fixed, interval }

enum RepeatType { none, daily, weekly, custom }

class TaskModel {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final bool reminderEnabled;
  final TimeOfDay? reminderTime; // For fixed reminder
  final ReminderType reminderType;
  final int? intervalMinutes; // For interval reminder
  final RepeatType repeatType;
  final List<int> customDays; // 1 = Monday, 7 = Sunday
  final PriorityLevel priority;
  final int streakCount;
  final DateTime createdDate;
  final DateTime updatedDate;
  final List<DateTime> completionHistory;
  final DateTime? lastCompletedDate;

  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.reminderEnabled = false,
    this.reminderTime,
    this.reminderType = ReminderType.fixed,
    this.intervalMinutes,
    this.repeatType = RepeatType.none,
    this.customDays = const [],
    this.priority = PriorityLevel.medium,
    this.streakCount = 0,
    required this.createdDate,
    required this.updatedDate,
    this.completionHistory = const [],
    this.lastCompletedDate,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    bool? reminderEnabled,
    TimeOfDay? reminderTime,
    ReminderType? reminderType,
    int? intervalMinutes,
    RepeatType? repeatType,
    List<int>? customDays,
    PriorityLevel? priority,
    int? streakCount,
    DateTime? createdDate,
    DateTime? updatedDate,
    List<DateTime>? completionHistory,
    DateTime? lastCompletedDate,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderType: reminderType ?? this.reminderType,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      repeatType: repeatType ?? this.repeatType,
      customDays: customDays ?? this.customDays,
      priority: priority ?? this.priority,
      streakCount: streakCount ?? this.streakCount,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      completionHistory: completionHistory ?? this.completionHistory,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'reminderEnabled': reminderEnabled,
      'reminderTime': reminderTime != null ? '${reminderTime!.hour}:${reminderTime!.minute}' : null,
      'reminderType': reminderType.name,
      'intervalMinutes': intervalMinutes,
      'intervalHours': intervalMinutes != null ? (intervalMinutes! / 60).round() : null,
      'repeatType': repeatType.name,
      'customDays': customDays,
      'priority': priority.name,
      'streakCount': streakCount,
      'createdDate': createdDate.toIso8601String(),
      'updatedDate': updatedDate.toIso8601String(),
      'completionHistory': completionHistory.map((d) => d.toIso8601String()).toList(),
      'lastCompletedDate': lastCompletedDate?.toIso8601String(),
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    TimeOfDay? parsedTime;
    if (json['reminderTime'] != null) {
      final parts = (json['reminderTime'] as String).split(':');
      parsedTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    final intervalMinutesVal = json['intervalMinutes'] as int? ?? 
        (json['intervalHours'] != null ? (json['intervalHours'] as int) * 60 : null);

    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      reminderEnabled: json['reminderEnabled'] as bool? ?? false,
      reminderTime: parsedTime,
      reminderType: ReminderType.values.firstWhere(
        (e) => e.name == json['reminderType'],
        orElse: () => ReminderType.fixed,
      ),
      intervalMinutes: intervalMinutesVal,
      repeatType: RepeatType.values.firstWhere(
        (e) => e.name == json['repeatType'],
        orElse: () => RepeatType.none,
      ),
      customDays: List<int>.from(json['customDays'] ?? const []),
      priority: PriorityLevel.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => PriorityLevel.medium,
      ),
      streakCount: json['streakCount'] as int? ?? 0,
      createdDate: DateTime.parse(json['createdDate'] as String),
      updatedDate: DateTime.parse(json['updatedDate'] as String),
      completionHistory: (json['completionHistory'] as List?)
              ?.map((d) => DateTime.parse(d as String))
              .toList() ??
          const [],
      lastCompletedDate: json['lastCompletedDate'] != null
          ? DateTime.parse(json['lastCompletedDate'] as String)
          : null,
    );
  }
}
