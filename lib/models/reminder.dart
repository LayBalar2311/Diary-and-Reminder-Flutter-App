import 'package:flutter/material.dart';

class Reminder {
  int? id;
  String title;
  String description;
  DateTime createdAt;
  DateTime? reminderDate;
  TimeOfDay? reminderTime;

  Reminder({
    this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.reminderDate,
    this.reminderTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'reminderDate': reminderDate?.toIso8601String(),
      'reminderTime': reminderTime != null
          ? '${reminderTime!.hour.toString().padLeft(2, '0')}:${reminderTime!.minute.toString().padLeft(2, '0')}'
          : null,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      createdAt: DateTime.parse(map['createdAt']),
      reminderDate: map['reminderDate'] != null
          ? DateTime.parse(map['reminderDate'])
          : null,
      reminderTime: map['reminderTime'] != null
          ? TimeOfDay(
              hour: int.parse(map['reminderTime'].split(':')[0]),
              minute: int.parse(map['reminderTime'].split(':')[1]),
            )
          : null,
    );
  }
}
