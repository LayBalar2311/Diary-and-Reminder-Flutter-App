import 'dart:async';
import 'package:diary/models/notes.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class NotesRepository {
  static const _dbName = 'notes_db.db';
  static const _tableName = 'notes';

  static Future<Database> _database() async {
    final database = await openDatabase(
      join(await getDatabasesPath(), _dbName),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE $_tableName(id INTEGER PRIMARY KEY, title TEXT, description TEXT, createdAt TEXT)',
        );
      },
      version: 1,
    );
    return database;
  }

  static Future<int> insert({required Notes notes}) async {
    final db = await _database();
    try {
      int id = await db.insert(
        _tableName,
        notes.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Note inserted successfully: ${notes.toMap()} with id: $id');
      return id;
    } catch (e) {
      print('Error inserting note: $e');
      rethrow; // Rethrow the error after logging it
    }
  }

  static Future<List<Notes>> getNotes() async {
    final db = await _database();

    final List<Map<String, dynamic>> noteMaps = await db.query(
      _tableName,
      orderBy: 'createdAt DESC',
    );

    return List.generate(noteMaps.length, (i) {
      final Map<String, dynamic> map = noteMaps[i];
      return Notes(
        id: map['id'] as int?,
        title: map['title'] as String,
        description: map['description'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
    });
  }

  static Future<void> deleteAllNotes() async {
    final Database db = await _database();

    // Execute the delete query
    await db.delete('notes');
  }

  static Future<void> update({required Notes notes}) async {
    final db = await _database();

    await db.update(
      _tableName,
      notes.toMap(),
      where: 'id = ?',
      whereArgs: [notes.id],
    );
  }

  static Future<void> deleteNotes({required Notes notes}) async {
    final db = await _database();

    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [notes.id],
    );
  }
}
