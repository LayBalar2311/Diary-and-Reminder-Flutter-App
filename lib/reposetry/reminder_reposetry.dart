import 'dart:async';
import 'package:diary/models/reminder.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class ReminderRepository {
  static const _dbName = 'reminder_db.db';
  static const _tableName = 'reminders';

  static Future<Database> _database() async {
    final database = await openDatabase(
      join(await getDatabasesPath(), _dbName),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE $_tableName (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, description TEXT, createdAt TEXT, reminderDate TEXT, reminderTime TEXT)',
        );
      },
      version: 1,
    );
    return database;
  }

  static Future<List<Reminder>> getReminders() async {
    final db = await _database();
    final List<Map<String, dynamic>> reminderMaps = await db.query(
      _tableName,
      orderBy: 'createdAt DESC',
    );
    print('Reminders fetched from database: $reminderMaps');
    final List<Reminder> reminders =
        reminderMaps.map((map) => Reminder.fromMap(map)).toList();
    final List<Reminder> futureReminders = reminders.where((reminder) {
      if (reminder.reminderDate != null) {
        return true; // No need to filter out expired reminders
      }
      return false;
    }).toList();
    print('Filtered future reminders: $futureReminders');
    return futureReminders;
  }

  static bool _isFutureDateTime(DateTime date, TimeOfDay? time) {
    final DateTime now = DateTime.now();
    DateTime dateTime;

    if (time != null) {
      dateTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    } else {
      dateTime = DateTime(date.year, date.month, date.day);
    }

    print('Checking if $dateTime is after $now');
    return dateTime.isAfter(now);
  }

  static Future<int> insert(Reminder reminder) async {
    final db = await _database();
    try {
      int id = await db.insert(
        _tableName,
        reminder.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      reminder.id = id;
      print('Reminder inserted successfully: ${reminder.toMap()}');

      return id;
    } catch (e) {
      print('Error inserting reminder: $e');
      throw e;
    }
  }

  static Future<void> update(Reminder reminder) async {
    final db = await _database();
    try {
      await db.update(
        _tableName,
        reminder.toMap(),
        where: 'id = ?',
        whereArgs: [reminder.id],
      );
    } catch (e) {
      print('Error updating reminder: $e');
      throw e;
    }
  }

  static Future<void> delete(int? id) async {
    final db = await _database();
    try {
      await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting reminder: $e');
      throw e;
    }
  }

  static Future<void> deleteAllReminders() async {
    final db = await _database();
    try {
      await db.delete(_tableName);
    } catch (e) {
      print('Error deleting all reminders: $e');
      throw e;
    }
  }
}
