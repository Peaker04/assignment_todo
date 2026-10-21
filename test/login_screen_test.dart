import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:assignment_todo/database_helper.dart';
import 'package:assignment_todo/login_screen.dart';

Widget createTestableWidget(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('vi', 'VN')],
    locale: const Locale('vi', 'VN'),
    home: child,
  );
}

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

  group('LoginScreen Widget Tests', () {
    testWidgets('Renders all required login elements', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestableWidget(LoginScreen(onLoginSuccess: () {})));
      await tester.pumpAndSettle();

      expect(find.text('TaskFlow'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Đăng nhập'), findsWidgets);
      expect(find.text('Tài khoản mẫu (Test nhanh)'), findsOneWidget);
      expect(find.text('Chưa có tài khoản? Đăng ký ngay'), findsOneWidget);
    });

    testWidgets('Quick login button fills admin credentials', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestableWidget(LoginScreen(onLoginSuccess: () {})));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tài khoản mẫu (Test nhanh)'));
      await tester.pumpAndSettle();

      expect(find.text('admin'), findsOneWidget);
      expect(find.text('123456'), findsOneWidget);
    });

    testWidgets('Submitting wrong credentials displays error message', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestableWidget(LoginScreen(onLoginSuccess: () {})));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'unknown_user');
      await tester.enterText(textFields.at(1), 'wrong_pass');

      // Tap login button
      await tester.runAsync(() async {
        await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng nhập'));
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      expect(find.text('Tên đăng nhập hoặc mật khẩu không chính xác'), findsOneWidget);
    });

    testWidgets('Successful login triggers onLoginSuccess callback', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool successCalled = false;
      await tester.pumpWidget(createTestableWidget(LoginScreen(
        onLoginSuccess: () {
          successCalled = true;
        },
      )));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tài khoản mẫu (Test nhanh)'));
      await tester.pumpAndSettle();

      await tester.runAsync(() async {
        await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng nhập'));
        for (int i = 0; i < 50; i++) {
          await Future.delayed(const Duration(milliseconds: 20));
          if (successCalled) break;
        }
      });
      await tester.pumpAndSettle();

      expect(successCalled, isTrue);
    });

    testWidgets('Can switch to registration mode and register successfully', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool successCalled = false;
      await tester.pumpWidget(createTestableWidget(LoginScreen(
        onLoginSuccess: () {
          successCalled = true;
        },
      )));
      await tester.pumpAndSettle();

      // Switch to register mode
      final switchBtn = find.text('Chưa có tài khoản? Đăng ký ngay');
      await tester.ensureVisible(switchBtn);
      await tester.tap(switchBtn);
      await tester.pumpAndSettle();

      expect(find.text('Đăng ký tài khoản mới'), findsOneWidget);

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'new_student');
      await tester.enterText(textFields.at(1), 'pass6789');
      await tester.pumpAndSettle();

      final registerBtn = find.widgetWithText(ElevatedButton, 'Đăng ký');
      await tester.ensureVisible(registerBtn);
      await tester.pumpAndSettle();

      await tester.runAsync(() async {
        await tester.tap(registerBtn);
        for (int i = 0; i < 60; i++) {
          await Future.delayed(const Duration(milliseconds: 50));
          if (successCalled) break;
        }
      });
      await tester.pumpAndSettle();

      expect(successCalled, isTrue);
    });
  });
}
