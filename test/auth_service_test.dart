import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:assignment_todo/database_helper.dart';
import 'package:assignment_todo/auth_service.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await DatabaseHelper.instance.resetForTesting();
  });

  tearDown(() async {
    await DatabaseHelper.instance.close();
  });

  group('AuthService Tests', () {
    test('Initial state is not logged in', () async {
      final isLoggedIn = await AuthService.instance.isLoggedIn();
      final currentUserId = await AuthService.instance.getCurrentUserId();
      final currentUsername = await AuthService.instance.getCurrentUsername();

      expect(isLoggedIn, isFalse);
      expect(currentUserId, isNull);
      expect(currentUsername, isNull);
    });

    test('Login with empty username or password returns error', () async {
      final result1 = await AuthService.instance.login('', '123456');
      expect(result1.success, isFalse);
      expect(result1.error, isNotNull);

      final result2 = await AuthService.instance.login('admin', '');
      expect(result2.success, isFalse);
      expect(result2.error, isNotNull);
    });

    test('Login with wrong credentials fails', () async {
      final result = await AuthService.instance.login('admin', 'wrong_pass');
      expect(result.success, isFalse);
      expect(result.error, 'Tên đăng nhập hoặc mật khẩu không chính xác');
      expect(await AuthService.instance.isLoggedIn(), isFalse);
    });

    test('Login with default seeded admin succeeds and persists session', () async {
      final result = await AuthService.instance.login('admin', '123456');
      expect(result.success, isTrue);
      expect(result.userId, 'admin_user_01');
      expect(result.error, isNull);

      // Verify persistent session
      expect(await AuthService.instance.isLoggedIn(), isTrue);
      expect(await AuthService.instance.getCurrentUserId(), 'admin_user_01');
      expect(await AuthService.instance.getCurrentUsername(), 'admin');
    });

    test('Register new account and maintain session', () async {
      final regResult = await AuthService.instance.register('user_test', 'pass123');
      expect(regResult.success, isTrue);
      expect(regResult.userId, isNotNull);

      expect(await AuthService.instance.isLoggedIn(), isTrue);
      expect(await AuthService.instance.getCurrentUsername(), 'user_test');

      // Duplicate registration fails
      final dupResult = await AuthService.instance.register('user_test', 'newpass');
      expect(dupResult.success, isFalse);
      expect(dupResult.error, 'Tên đăng nhập đã tồn tại');
    });

    test('Logout clears session completely', () async {
      await AuthService.instance.login('admin', '123456');
      expect(await AuthService.instance.isLoggedIn(), isTrue);

      await AuthService.instance.logout();
      expect(await AuthService.instance.isLoggedIn(), isFalse);
      expect(await AuthService.instance.getCurrentUserId(), isNull);
      expect(await AuthService.instance.getCurrentUsername(), isNull);
    });
  });
}
