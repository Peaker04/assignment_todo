# Login, Session Persistence & SQLite Storage Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Thêm tính năng Đăng nhập / Đăng ký, duy trì phiên đăng nhập (session persistence) qua `shared_preferences`, và lưu trữ dữ liệu bền vững qua SQLite (`sqflite`) cho ứng dụng TaskFlow.

**Architecture:** Sử dụng kiến trúc module tinh gọn với 3 thành phần chính: `DatabaseHelper` quản lý cơ sở dữ liệu SQLite (`users`, `tasks`) có hỗ trợ đa nền tảng (iOS gốc & Web FFI fallback); `AuthService` quản lý phiên đăng nhập và giao tiếp với SQLite; `LoginScreen` cung cấp giao diện xác thực người dùng đồng bộ thiết kế Soft Modern của app; `main.dart` kiểm tra phiên khi khởi động và liên kết CRUD công việc với SQLite theo từng người dùng.

**Tech Stack:** Flutter, Dart, `sqflite`, `path`, `shared_preferences`, `sqflite_common_ffi_web` (hoặc memory fallback cho web test), `flutter_test`.

**Spec:** `docs/superpowers/specs/2026-10-21-auth-sqlite-persistence-design.md`

## Global Constraints

- Platform targets: iOS (primary native target) và Web Chrome (secondary UI test).
- Ngôn ngữ giao diện và thông báo: 100% tiếng Việt, đồng bộ phong cách Soft Modern của `AppColors`.
- Phiên đăng nhập: Lưu trữ bền vững qua `shared_preferences`, không mất phiên khi đóng app, chỉ đăng xuất khi người dùng chủ động bấm Đăng xuất.
- Cơ sở dữ liệu SQLite: Gồm 2 bảng `users` và `tasks`, mỗi task liên kết với `user_id`. Tự động seed tài khoản `admin` / `123456`.
- Không thêm tính năng dư thừa ngoài yêu cầu (YAGNI & Ponytail principle).

## Review Focus

- Đăng nhập sai mật khẩu hoặc tên đăng nhập không tồn tại: hiển thị thông báo lỗi rõ ràng bằng tiếng Việt, không làm crash app.
- Đăng ký tên đăng nhập đã tồn tại: từ chối và báo "Tên đăng nhập đã được sử dụng".
- Mở lại app khi phiên đã lưu: khởi động chuyển thẳng vào màn hình chính `TaskFlowHomeScreen` mà không nháy màn hình đăng nhập.
- Đăng xuất chủ động: xóa cờ phiên trong `shared_preferences`, điều hướng về `LoginScreen` và xóa sạch dữ liệu người dùng cũ trong bộ nhớ.
- Dữ liệu task độc lập theo người dùng: Người dùng A đăng nhập chỉ thấy các task của người dùng A; người dùng B đăng nhập chỉ thấy task của B.

---

### Task 1: Cấu hình dependencies & Xây dựng DatabaseHelper (SQLite)

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/database_helper.dart`
- Test: `test/database_helper_test.dart`

**Interfaces:**
- Consumes: `sqflite`, `path`, `sqflite_common_ffi_web`, `flutter/foundation.dart`
- Produces:
  ```dart
  class DatabaseHelper {
    static final DatabaseHelper instance;
    Future<Database> get database;
    Future<int> insertUser(Map<String, dynamic> row);
    Future<Map<String, dynamic>?> getUserByUsername(String username);
    Future<int> insertTask(Map<String, dynamic> row);
    Future<List<Map<String, dynamic>>> getTasksByUserId(String userId);
    Future<int> updateTask(Map<String, dynamic> row);
    Future<int> deleteTask(String id);
    Future<int> clearCompletedTasks(String userId);
  }
  ```

- [ ] **Step 1: Cập nhật `pubspec.yaml` và chạy `flutter pub get`**
  Thêm `sqflite: ^2.4.1`, `path: ^1.9.0`, `shared_preferences: ^2.3.5`, `sqflite_common_ffi: ^2.3.4+4`, `sqflite_common_ffi_web: ^0.4.3+3` vào `pubspec.yaml`.
  Chạy lệnh: `flutter pub get`
  Kỳ vọng: dependencies được tải thành công mà không có xung đột phiên bản.

- [ ] **Step 2: Viết test thất bại cho DatabaseHelper**
  Tạo `test/database_helper_test.dart` kiểm tra khởi tạo bảng, chèn user, lấy user theo username, chèn task, lấy task theo userId, và xóa completed tasks.
  Chạy: `flutter test test/database_helper_test.dart`
  Kỳ vọng: FAIL (vì chưa có `lib/database_helper.dart`).

- [ ] **Step 3: Triển khai `DatabaseHelper` trong `lib/database_helper.dart`**
  Triển khai singleton `DatabaseHelper` với:
  - Khởi tạo database đa nền tảng (nếu `kIsWeb`, sử dụng `databaseFactoryFfiWeb`; trên mobile/desktop sử dụng native `openDatabase`).
  - Schema:
    - Bảng `users`: `id TEXT PRIMARY KEY, username TEXT UNIQUE, password TEXT, created_at TEXT`.
    - Bảng `tasks`: `id TEXT PRIMARY KEY, user_id TEXT, title TEXT, content TEXT, date TEXT, type TEXT, is_completed INTEGER, created_at TEXT, deadline TEXT`.
  - Hàm seed tài khoản mặc định `admin` / `123456` và các task mẫu ban đầu cho `admin`.
  - Các hàm CRUD: `insertUser`, `getUserByUsername`, `insertTask`, `getTasksByUserId`, `updateTask`, `deleteTask`, `clearCompletedTasks`.

- [ ] **Step 4: Chạy test kiểm tra DatabaseHelper**
  Chạy: `flutter test test/database_helper_test.dart`
  Kỳ vọng: PASS toàn bộ test.

- [ ] **Step 5: Commit**
  ```bash
  git add pubspec.yaml pubspec.lock lib/database_helper.dart test/database_helper_test.dart
  git commit -m "feat: add sqlite database helper with users and tasks schema"
  ```

---

### Task 2: Xây dựng AuthService & Duy trì phiên đăng nhập

**Files:**
- Create: `lib/auth_service.dart`
- Test: `test/auth_service_test.dart`

**Interfaces:**
- Consumes: `lib/database_helper.dart`, `shared_preferences`
- Produces:
  ```dart
  class AuthService {
    static final AuthService instance;
    Future<bool> isLoggedIn();
    Future<String?> getCurrentUserId();
    Future<String?> getCurrentUsername();
    Future<({bool success, String? error, String? userId})> login(String username, String password);
    Future<({bool success, String? error, String? userId})> register(String username, String password);
    Future<void> logout();
  }
  ```

- [ ] **Step 1: Viết test thất bại cho AuthService**
  Tạo `test/auth_service_test.dart` (sử dụng `SharedPreferences.setMockInitialValues`):
  - Kiểm tra trạng thái ban đầu `isLoggedIn() == false`.
  - Đăng nhập thất bại khi sai thông tin.
  - Đăng nhập thành công với tài khoản mẫu `admin` / `123456` -> `isLoggedIn() == true`, `getCurrentUsername() == 'admin'`.
  - Đăng xuất -> `isLoggedIn() == false`.
  - Đăng ký tài khoản mới và đăng nhập lại bằng tài khoản đó.
  Chạy: `flutter test test/auth_service_test.dart`
  Kỳ vọng: FAIL (vì chưa có `lib/auth_service.dart`).

- [ ] **Step 2: Triển khai `AuthService` trong `lib/auth_service.dart`**
  Triển khai:
  - `login(username, password)`: kiểm tra username/password từ `DatabaseHelper`. Nếu khớp, lưu `auth_is_logged_in = true`, `auth_user_id`, `auth_username` vào `SharedPreferences`.
  - `register(username, password)`: kiểm tra username đã tồn tại chưa; nếu chưa, tạo user mới với UUID/timestamp id, lưu vào database và tự động đăng nhập.
  - `logout()`: xóa các key xác thực trong `SharedPreferences`.
  - `isLoggedIn()`, `getCurrentUserId()`, `getCurrentUsername()`.

- [ ] **Step 3: Chạy test xác nhận AuthService**
  Chạy: `flutter test test/auth_service_test.dart`
  Kỳ vọng: PASS toàn bộ test.

- [ ] **Step 4: Commit**
  ```bash
  git add lib/auth_service.dart test/auth_service_test.dart
  git commit -m "feat: implement auth service with persistent session management"
  ```

---

### Task 3: Xây dựng màn hình Đăng nhập & Đăng ký (LoginScreen)

**Files:**
- Create: `lib/login_screen.dart`
- Test: `test/login_screen_test.dart`

**Interfaces:**
- Consumes: `lib/auth_service.dart`, `AppColors` từ `lib/main.dart`
- Produces:
  ```dart
  class LoginScreen extends StatefulWidget {
    final VoidCallback onLoginSuccess;
    const LoginScreen({super.key, required this.onLoginSuccess});
  }
  ```

- [ ] **Step 1: Viết test thất bại cho LoginScreen**
  Tạo `test/login_screen_test.dart`:
  - Test hiển thị các trường nhập Tên đăng nhập, Mật khẩu, nút Đăng nhập, nút Đăng ký, nút "Tài khoản mẫu".
  - Test bấm nút "Tài khoản mẫu" tự động điền `admin` và `123456`.
  - Test đăng nhập thất bại hiển thị SnackBar lỗi.
  - Test đăng nhập thành công gọi callback `onLoginSuccess`.
  Chạy: `flutter test test/login_screen_test.dart`
  Kỳ vọng: FAIL (vì chưa có `lib/login_screen.dart`).

- [ ] **Step 2: Triển khai `LoginScreen` trong `lib/login_screen.dart`**
  Thiết kế giao diện Soft Modern:
  - Header với biểu tượng và tiêu đề TaskFlow.
  - Toggle chế độ Đăng nhập / Đăng ký.
  - Trường Tên đăng nhập và Mật khẩu (ẩn/hiển thị mật khẩu).
  - Nút "Đăng nhập" (gradient button).
  - Nút "Tài khoản mẫu (Test nhanh)" tiện lợi cho người chấm thi / test.
  - Xử lý thông báo lỗi bằng tiếng Việt rõ ràng.
  - Gọi `onLoginSuccess()` khi hoàn tất xác thực.

- [ ] **Step 3: Chạy test kiểm tra LoginScreen**
  Chạy: `flutter test test/login_screen_test.dart`
  Kỳ vọng: PASS toàn bộ test.

- [ ] **Step 4: Commit**
  ```bash
  git add lib/login_screen.dart test/login_screen_test.dart
  git commit -m "feat: implement login and register screen with soft modern UI"
  ```

---

### Task 4: Tích hợp vào `main.dart` (Session Router, Logout & SQLite CRUD)

**Files:**
- Modify: `lib/main.dart`
- Modify: `test/widget_test.dart`

**Interfaces:**
- Consumes: `lib/database_helper.dart`, `lib/auth_service.dart`, `lib/login_screen.dart`
- Produces: Hoàn thiện toàn bộ ứng dụng từ khởi động kiểm tra phiên, đăng nhập, nạp/lưu tasks từ SQLite, đến đăng xuất.

- [ ] **Step 1: Cập nhật `TaskFlowApp` để kiểm tra phiên khi khởi động**
  Trong `lib/main.dart`:
  - Khởi tạo `DatabaseHelper` và `AuthService` trong `main()`.
  - `TaskFlowApp` kiểm tra trạng thái `isLoggedIn`:
    - Nếu đã đăng nhập: hiển thị `TaskFlowHomeScreen(userId: currentUserId, username: currentUsername)`.
    - Nếu chưa đăng nhập: hiển thị `LoginScreen(onLoginSuccess: ...)`.

- [ ] **Step 2: Thêm nút Đăng xuất trên AppBar màn hình chính**
  - Thêm icon button Đăng xuất (Logout) kèm dialog xác nhận "Bạn có chắc chắn muốn đăng xuất?".
  - Khi xác nhận: gọi `AuthService.instance.logout()`, reset danh sách task trong RAM và chuyển về `LoginScreen`.

- [ ] **Step 3: Chuyển đổi toàn bộ thao tác TodoItem sang lưu trữ SQLite**
  - Khi mở `TaskFlowHomeScreen`: gọi `DatabaseHelper.instance.getTasksByUserId(userId)` nạp danh sách công việc.
  - Khi Thêm task: lưu vào SQLite qua `insertTask`, sau đó cập nhật UI.
  - Khi Sửa task: cập nhật SQLite qua `updateTask`.
  - Khi Xóa task: xóa khỏi SQLite qua `deleteTask` (hỗ trợ Undo: nếu bấm Hoàn tác thì `insertTask` lại).
  - Khi Đổi trạng thái hoàn thành: cập nhật `is_completed` vào SQLite.
  - Khi "Xóa tất cả việc đã hoàn thành": gọi `clearCompletedTasks(userId)`.

- [ ] **Step 4: Cập nhật và chạy toàn bộ test trong `test/widget_test.dart`**
  Đảm bảo các test cũ và test mới cho luồng đăng nhập, duy trì session và CRUD SQLite đều pass.
  Chạy: `flutter test`
  Kỳ vọng: Toàn bộ test pass 100%.

- [ ] **Step 5: Kiểm tra phân tích tĩnh (`flutter analyze`)**
  Chạy: `flutter analyze`
  Kỳ vọng: `No issues found!`.

- [ ] **Step 6: Commit**
  ```bash
  git add lib/main.dart test/widget_test.dart
  git commit -m "feat: integrate auth session routing, sqlite persistence and logout"
  ```
