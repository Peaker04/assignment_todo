import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';

class AuthService {
  static final AuthService instance = AuthService._internal();

  static const String _keyIsLoggedIn = 'auth_is_logged_in';
  static const String _keyUserId = 'auth_user_id';
  static const String _keyUsername = 'auth_username';

  AuthService._internal();

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  Future<String?> getCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  Future<({bool success, String? error, String? userId})> login(
    String username,
    String password,
  ) async {
    final trimmedUsername = username.trim();
    if (trimmedUsername.isEmpty || password.isEmpty) {
      return (
        success: false,
        error: 'Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu',
        userId: null,
      );
    }

    Map<String, dynamic>? user;
    try {
      user = await DatabaseHelper.instance.getUserByUsername(trimmedUsername);
    } catch (_) {
      return (
        success: false,
        error: 'Tên đăng nhập hoặc mật khẩu không chính xác',
        userId: null,
      );
    }
    if (user == null || user['password'] != password) {
      return (
        success: false,
        error: 'Tên đăng nhập hoặc mật khẩu không chính xác',
        userId: null,
      );
    }

    final userId = user['id'] as String;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyUsername, trimmedUsername);

    return (success: true, error: null, userId: userId);
  }

  Future<({bool success, String? error, String? userId})> register(
    String username,
    String password,
  ) async {
    final trimmedUsername = username.trim();
    if (trimmedUsername.isEmpty || password.isEmpty) {
      return (
        success: false,
        error: 'Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu',
        userId: null,
      );
    }

    if (password.length < 4) {
      return (
        success: false,
        error: 'Mật khẩu phải có ít nhất 4 ký tự',
        userId: null,
      );
    }

    Map<String, dynamic>? existingUser;
    try {
      existingUser = await DatabaseHelper.instance.getUserByUsername(trimmedUsername);
    } catch (_) {
      existingUser = null;
    }
    if (existingUser != null) {
      return (
        success: false,
        error: 'Tên đăng nhập đã tồn tại',
        userId: null,
      );
    }

    final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final nowIso = DateTime.now().toIso8601String();

    await DatabaseHelper.instance.insertUser({
      'id': userId,
      'username': trimmedUsername,
      'password': password,
      'created_at': nowIso,
    });

    // Auto log in newly registered user
    // Auto log in newly registered user
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyUsername, trimmedUsername);

    return (success: true, error: null, userId: userId);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUsername);
  }
}
