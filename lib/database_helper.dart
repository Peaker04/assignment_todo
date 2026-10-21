import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase([String dbName = 'taskflow.db']) async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        deadline TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Seed default admin account
    const defaultUserId = 'admin_user_01';
    final nowIso = DateTime.now().toIso8601String();

    await db.insert('users', {
      'id': defaultUserId,
      'username': 'admin',
      'password': '123456',
      'created_at': nowIso,
    });

    // Seed default sample tasks for admin
    await db.insert('tasks', {
      'id': 'seed_task_01',
      'user_id': defaultUserId,
      'title': 'Hoàn thành bài tập lớn Flutter',
      'content': 'Triển khai Đăng nhập, Session Persistence và SQLite',
      'date': 'Hôm nay',
      'type': 'Khó',
      'is_completed': 0,
      'created_at': nowIso,
      'deadline': null,
    });

    await db.insert('tasks', {
      'id': 'seed_task_02',
      'user_id': defaultUserId,
      'title': 'Thiết kế giao diện Soft Modern',
      'content': 'Tối ưu độ tương phản, bo góc mềm mại và bảng màu thư thái',
      'date': 'Hôm nay',
      'type': 'Trung bình',
      'is_completed': 1,
      'created_at': nowIso,
      'deadline': null,
    });

    await db.insert('tasks', {
      'id': 'seed_task_03',
      'user_id': defaultUserId,
      'title': 'Kiểm thử ứng dụng trên iOS & Web',
      'content': 'Đảm bảo không lỗi trên Chrome và chạy mượt mà trên iPhone',
      'date': 'Ngày mai',
      'type': 'Dễ',
      'is_completed': 0,
      'created_at': nowIso,
      'deadline': null,
    });
  }

  // User Operations
  Future<int> insertUser(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('users', row, conflictAlgorithm: ConflictAlgorithm.fail);
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  // Task Operations
  Future<int> insertTask(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('tasks', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getTasksByUserId(String userId) async {
    final db = await database;
    return await db.query(
      'tasks',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  Future<int> updateTask(Map<String, dynamic> row) async {
    final db = await database;
    final id = row['id'];
    return await db.update(
      'tasks',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTask(String id) async {
    final db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> clearCompletedTasks(String userId) async {
    final db = await database;
    return await db.delete(
      'tasks',
      where: 'user_id = ? AND is_completed = 1',
      whereArgs: [userId],
    );
  }

  // Testing Support
  Future<void> resetForTesting([String? dbName]) async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
    }
    final targetPath = dbName ?? inMemoryDatabasePath;
    _database = await openDatabase(
      targetPath,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }
}
