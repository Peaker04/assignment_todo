import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:assignment_todo/database_helper.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Reset database for a clean test run
    await DatabaseHelper.instance.resetForTesting();
  });

  tearDown(() async {
    await DatabaseHelper.instance.close();
  });

  group('DatabaseHelper CRUD Tests', () {
    test('Database seeds default admin user on creation', () async {
      final user = await DatabaseHelper.instance.getUserByUsername('admin');
      expect(user, isNotNull);
      expect(user!['username'], 'admin');
      expect(user['password'], '123456');
    });

    test('Can insert new user and retrieve by username', () async {
      final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      await DatabaseHelper.instance.insertUser({
        'id': userId,
        'username': 'john_doe',
        'password': 'password123',
        'created_at': DateTime.now().toIso8601String(),
      });

      final retrieved = await DatabaseHelper.instance.getUserByUsername('john_doe');
      expect(retrieved, isNotNull);
      expect(retrieved!['id'], userId);
      expect(retrieved['username'], 'john_doe');
    });

    test('Can perform CRUD on tasks isolated by user_id', () async {
      final userId1 = 'user_1';
      final userId2 = 'user_2';

      // Insert task for user 1
      await DatabaseHelper.instance.insertTask({
        'id': 'task_1',
        'user_id': userId1,
        'title': 'Học Flutter',
        'content': 'Làm đồ án Todo',
        'date': 'Hôm nay',
        'type': 'Dễ',
        'is_completed': 0,
        'created_at': DateTime.now().toIso8601String(),
        'deadline': null,
      });

      // Insert task for user 2
      await DatabaseHelper.instance.insertTask({
        'id': 'task_2',
        'user_id': userId2,
        'title': 'Viết báo cáo',
        'content': 'Nộp bài tập lớn',
        'date': 'Ngày mai',
        'type': 'Khó',
        'is_completed': 1,
        'created_at': DateTime.now().toIso8601String(),
        'deadline': null,
      });

      // Verify user 1 only sees their task
      final tasksUser1 = await DatabaseHelper.instance.getTasksByUserId(userId1);
      expect(tasksUser1.length, 1);
      expect(tasksUser1.first['title'], 'Học Flutter');

      // Update task for user 1
      await DatabaseHelper.instance.updateTask({
        'id': 'task_1',
        'user_id': userId1,
        'title': 'Học Flutter nâng cao',
        'content': 'Làm đồ án Todo',
        'date': 'Hôm nay',
        'type': 'Trung bình',
        'is_completed': 1,
        'created_at': DateTime.now().toIso8601String(),
        'deadline': null,
      });

      final updatedTasksUser1 = await DatabaseHelper.instance.getTasksByUserId(userId1);
      expect(updatedTasksUser1.first['title'], 'Học Flutter nâng cao');
      expect(updatedTasksUser1.first['is_completed'], 1);

      // Clear completed tasks for user 1
      await DatabaseHelper.instance.clearCompletedTasks(userId1);
      final remainingUser1 = await DatabaseHelper.instance.getTasksByUserId(userId1);
      expect(remainingUser1.isEmpty, isTrue);

      // Verify user 2 tasks are untouched
      final tasksUser2 = await DatabaseHelper.instance.getTasksByUserId(userId2);
      expect(tasksUser2.length, 1);

      // Delete task 2
      await DatabaseHelper.instance.deleteTask('task_2');
      final finalUser2 = await DatabaseHelper.instance.getTasksByUserId(userId2);
      expect(finalUser2.isEmpty, isTrue);
    });
  });
}
