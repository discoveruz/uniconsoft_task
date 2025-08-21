import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  // Private constructor
  DatabaseHelper._internal();
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'tasks.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<int> getTaskCount() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT COUNT(*) FROM tasks');
    return Sqflite.firstIntValue(maps) ?? 0;
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        status INTEGER,
        created_at INTEGER,
        finished_at INTEGER
      )
    ''');
  }

  Future<List<Map<String, dynamic>>> getTasks() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return maps;
  }

  Future<int> insertTask(Map<String, dynamic> task) async {
    Database db = await instance.database;
    return await db.insert('tasks', task);
  }

  Future<int> updateTask(Map<String, dynamic> task) async {
    Database db = await instance.database;
    return await db.update('tasks', task, where: 'id = ?', whereArgs: [task['id']]);
  }

  Future<int> deleteTask(int id) async {
    Database db = await instance.database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearTasks() async {
    Database db = await instance.database;
    await db.delete('tasks');
  }

  Future<void> closeDatabase() async {
    Database db = await instance.database;
    await db.close();
  }
}
