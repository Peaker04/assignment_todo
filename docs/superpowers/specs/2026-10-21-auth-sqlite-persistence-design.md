# Design Specification: Login, Session Persistence & SQLite Data Storage

**Date:** 2026-10-21  
**Project:** TaskFlow (assignment_todo)  
**Status:** Pending Approval  

---

## 1. Intent & The Why

Ứng dụng quản lý công việc hiện tại (TaskFlow) chỉ lưu trữ trạng thái tạm thời trong RAM (in-memory local state). Khi khởi động lại ứng dụng, toàn bộ công việc bị reset về danh sách mẫu ban đầu và bất kỳ ai mở ứng dụng cũng vào thẳng danh sách việc mà không có lớp bảo vệ tài khoản hay phân tách công việc.

Mục tiêu của thiết kế này là đáp ứng 2 yêu cầu nghiệp vụ cốt lõi:
1. **Đăng nhập & Duy trì trạng thái đăng nhập (Login & Session Persistence):** Cung cấp màn hình đăng nhập, lưu lại trạng thái phiên để các lần mở ứng dụng tiếp theo không cần đăng nhập lại (giống trải nghiệm Zalo, Facebook), và hỗ trợ nút Đăng xuất chủ động.
2. **Lưu trữ dữ liệu bền vững (Data Persistence qua SQLite):** Lưu toàn bộ công việc và thông tin xác thực vào cơ sở dữ liệu SQLite trên thiết bị (ưu tiên hàng đầu là iOS, tương thích khi test giao diện trên Web), đảm bảo các thao tác Thêm, Sửa, Xóa, Đổi trạng thái hoàn thành được lưu vĩnh viễn qua các lần tắt/mở ứng dụng.

---

## 2. Goals, Non-Goals, and Anti-Goals

### Goals
- **Màn hình Đăng nhập (Login Screen):** Giao diện sạch sẽ, đồng bộ phong cách Soft Modern của app. Có trường Tên đăng nhập và Mật khẩu. Hỗ trợ nút đăng nhập và chuyển sang Đăng ký tài khoản mới.
- **Duy trì phiên đăng nhập (Session Persistence):**
  - Sử dụng `shared_preferences` lưu `isLoggedIn` và `currentUserId`/`username`.
  - Khởi động app: Nếu đã đăng nhập -> chuyển thẳng vào `TaskFlowHomeScreen`. Nếu chưa -> hiển thị `LoginScreen`.
  - Đăng xuất: Bấm nút Đăng xuất trên AppBar màn hình chính -> xóa session -> chuyển về `LoginScreen`.
- **Lưu trữ dữ liệu SQLite (Data Persistence):**
  - Tạo cơ sở dữ liệu SQLite cục bộ gồm 2 bảng: `users` và `tasks`.
  - Bảng `tasks` lưu đầy đủ các trường: `id`, `user_id`, `title`, `content`, `date`, `type`, `is_completed`, `created_at`, `deadline`.
  - Thao tác CRUD (Create, Read, Update, Delete, Toggle Complete, Clear Completed) đọc/ghi trực tiếp vào SQLite.
  - Hỗ trợ nền tảng chính: iOS (native `sqflite`) và hỗ trợ khởi chạy test trên Web (`sqflite_common_ffi_web`).
- **Tập trung & Tinh gọn (Ponytail / YAGNI):** Đúng yêu cầu, không thêm tính năng thừa.

### Non-Goals
- Không tích hợp xác thực qua bên thứ ba (Google OAuth, Apple Sign-in, Facebook Login).
- Không yêu cầu gửi mã OTP qua SMS hay xác nhận email.
- Không xây dựng cloud backend hay REST API server (vì đã chọn phương án SQLite).
- Không đồng bộ dữ liệu đa thiết bị qua internet.

### Anti-Goals
- Tránh làm phức tạp luồng đăng nhập bằng các quy tắc mật khẩu rườm rà không có trong yêu cầu (như bắt buộc ký tự đặc biệt, số điện thoại hợp lệ).
- Tránh kiến trúc phân tầng quá mức (không lạm dụng Clean Architecture nhiều tầng phức tạp, giữ code rõ ràng, dễ bảo trì, đúng cấu trúc Flutter chuẩn).

---

## 3. Constraints

- **Môi trường & Nền tảng:**
  - Nền tảng chính: iOS.
  - Nền tảng test giao diện sơ bộ: Web (Chrome).
  - SDK: Flutter / Dart 3.x.
- **Packages sử dụng:**
  - `sqflite` & `path`: SQLite chuẩn cho Flutter.
  - `sqflite_common_ffi_web`: Cung cấp database factory cho Flutter Web khi chạy `flutter run -d chrome`.
  - `shared_preferences`: Lưu cờ phiên đăng nhập nhẹ nhàng, tin cậy.
- **Bản địa hóa (Localization):**
  - Toàn bộ giao diện và thông báo (tiếng Việt), đồng bộ với tiêu chuẩn có sẵn trong `TaskFlowApp`.

---

## 4. How It Gets Made (Decisions Made)

1. **Kiến trúc dữ liệu SQLite:**
   - Database name: `taskflow.db`.
   - Bảng `users`:
     - `id TEXT PRIMARY KEY`
     - `username TEXT UNIQUE`
     - `password TEXT`
     - `created_at TEXT`
   - Bảng `tasks`:
     - `id TEXT PRIMARY KEY`
     - `user_id TEXT` (Foreign key trỏ tới `users.id`)
     - `title TEXT`
     - `content TEXT`
     - `date TEXT`
     - `type TEXT`
     - `is_completed INTEGER` (0 hoặc 1)
     - `created_at TEXT`
     - `deadline TEXT` (Nullable)
   - Khởi tạo mặc định: Seed sẵn 1 tài khoản mẫu `admin` / `123456` để người dùng có thể test nhanh hoặc chấm bài chỉ với 1 click.

2. **Duy trì phiên đăng nhập (Session Flow):**
   - Khi `main()` chạy: khởi tạo `SharedPreferences` và DatabaseService.
   - App Widget (`TaskFlowApp`) xác định màn hình ban đầu (`initialScreen`):
     - Nếu `isLoggedIn == true` và có `currentUserId`: hiển thị `TaskFlowHomeScreen`.
     - Ngược lại: hiển thị `LoginScreen`.
   - Tại `LoginScreen`:
     - Nhập username/password -> kiểm tra trong bảng `users`.
     - Nếu đúng: lưu `isLoggedIn = true`, `currentUserId`, `username` vào `shared_preferences` -> điều hướng thay thế (`pushReplacement`) vào `TaskFlowHomeScreen`.
     - Nếu sai: hiển thị SnackBar thông báo lỗi bằng tiếng Việt.
     - Nút "Đăng ký": Chuyển sang form tạo tài khoản mới -> lưu vào SQLite -> tự động đăng nhập hoặc báo thành công.
     - Nút "Tài khoản mẫu (Test nhanh)": Tự điền `admin` / `123456`.
   - Tại `TaskFlowHomeScreen`:
     - Thêm icon button Đăng xuất ở AppBar.
     - Khi bấm Đăng xuất: Hiển thị dialog xác nhận -> Xóa trạng thái trong `shared_preferences` -> Điều hướng về `LoginScreen`.

3. **Cơ chế tải dữ liệu công việc:**
   - Mỗi người dùng chỉ thấy các công việc gắn với `user_id` của họ (`SELECT * FROM tasks WHERE user_id = ?`).
   - Mọi thao tác Thêm, Sửa, Xóa, Toggle hoàn thành đều gọi hàm cập nhật SQLite tương ứng và cập nhật state hiển thị.

---

## 5. What's Left to the Builder

- Tổ chức các lớp helper (`DatabaseHelper` / `AuthService`) gọn gàng, tách biệt hoặc đặt trong thư mục `lib/` theo cấu trúc sạch sẽ.
- Xử lý mượt mà animation chuyển trang giữa màn hình đăng nhập và màn hình chính.
- Viết unit / widget test xác thực luồng đăng nhập, duy trì session và thao tác SQLite.
