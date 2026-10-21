# iOS Cupertino UI/UX Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign toàn diện giao diện TaskFlow theo phong cách iOS Cupertino (Apple Human Interface Guidelines & Anti-AI-Slop) trong khi bảo toàn 100% chức năng (FRs, NFRs) và không mở rộng phạm vi bài tập.

**Architecture:** Nâng cấp hệ thống Design Tokens (`AppColors`) sang bảng màu iOS chuẩn (`systemBackground`, `systemBlue`, `secondaryBackground`), chuẩn hóa typography và bo góc (Apple HIG); chuyển đổi `LoginScreen` sang `CupertinoSlidingSegmentedControl` và trường nhập liệu phong cách iOS; tái cấu trúc `TodoListScreen` với Navigation Bar tiêu đề lớn, thanh tìm kiếm bo tròn, bộ lọc phân đoạn trượt và modal sheet tạo/sửa công việc từ cạnh dưới.

**Tech Stack:** Flutter, Dart, `cupertino_icons`, `flutter_localizations`, `flutter_test`.

**Spec:** `docs/superpowers/specs/2026-10-21-ios-cupertino-redesign.md`

## Global Constraints

- Phong cách chủ đạo: **iOS Cupertino** thanh lịch, chuẩn mực, đẳng cấp.
- Tuân thủ nguyên tắc **Taste & Anti-AI-Slop**: không neon glow, không emoji icon, không lồng card vô lý, shadow mờ mịn đa tầng.
- Bảo toàn trọn vẹn mọi yêu cầu chức năng (FRs: Login, Session persistence, Task CRUD, Search, Filter, Deadline, Logout) và phi chức năng (NFRs: Tiếng Việt, responsive, giải phóng controller).
- Toàn bộ 18 test cases tự động tiếp tục pass 100%.

## Review Focus

- Giao diện LoginScreen: Chuyển đổi mượt mà giữa Đăng nhập và Đăng ký bằng segmented control, không nháy giật layout.
- Bộ lọc phân đoạn trên màn hình chính: Lướt chuyển giữa "Tất cả", "Đang làm", "Đã xong" chính xác, cập nhật danh sách tức thì.
- Thẻ công việc: Checkbox tròn chuẩn iOS, hiển thị rõ ràng tiêu đề, nội dung, ngày thực hiện, deadline và mức độ ưu tiên.
- Khay trượt tạo mới/sửa: Trượt êm ái từ dưới lên (Modal sheet), có thanh kéo indicator và các nút bấm rõ ràng.
- Đăng xuất: Nút đăng xuất tinh tế, hộp thoại xác nhận phong cách iOS cảnh báo an toàn.

---

### Task 1: Cập nhật Design Tokens & Redesign màn hình Đăng nhập (LoginScreen)

**Files:**
- Modify: `lib/login_screen.dart`
- Test: `test/login_screen_test.dart`

**Interfaces:**
- Consumes: `lib/auth_service.dart`, `AppColors`
- Produces: `LoginScreen` với giao diện iOS Cupertino tinh xảo.

- [ ] **Step 1: Viết/kiểm tra test cho LoginScreen**
  Đảm bảo `test/login_screen_test.dart` tiếp tục kiểm tra đầy đủ các thành phần nhập liệu, nút bấm, chế độ chuyển đổi và callback.
  Chạy: `flutter test test/login_screen_test.dart`
  Kỳ vọng: PASS.

- [ ] **Step 2: Triển khai giao diện iOS Cupertino cho `LoginScreen`**
  Trong `lib/login_screen.dart`:
  - Nền toàn màn hình: `Color(0xFFF2F2F7)` (iOS Grouped Background).
  - Khung nội dung trung tâm: Bo góc 20pt, màu trắng tinh khiết, bóng đổ siêu nhẹ đa tầng (`BoxShadow` với alpha 0.04, blur 20).
  - Header: Logo icon iOS bo góc 18pt với gradient xanh Apple nhẹ nhàng, tiêu đề "TaskFlow" SF Pro font weight 700.
  - Bộ chuyển chế độ: `CupertinoSlidingSegmentedControl` chia 2 tab: "Đăng nhập" và "Đăng ký".
  - Trường nhập liệu: Nền `Color(0xFFEFEFF4)` bo góc 12pt, viền ẩn hoặc siêu mỏng, placeholder mờ thanh lịch, nút ẩn/hiện mật khẩu rõ ràng.
  - Nút chính (Đăng nhập / Đăng ký): Nền Apple System Blue (`Color(0xFF007AFF)`), bo góc 14pt, chiều cao 48pt.
  - Nút "Tài khoản mẫu (Test nhanh)": Nút phụ màu `Color(0xFFE5E5EA)` với icon tia sét `CupertinoIcons.bolt_fill`, text `Color(0xFF007AFF)`.
  - Giữ nguyên toàn bộ logic xử lý `_submit`, `_fillDemoAccount`, và bọc an toàn `try ... finally`.

- [ ] **Step 3: Chạy test kiểm tra lại LoginScreen**
  Chạy: `flutter test test/login_screen_test.dart`
  Kỳ vọng: PASS toàn bộ 5/5 test.

- [ ] **Step 4: Commit**
  ```bash
  git add lib/login_screen.dart test/login_screen_test.dart
  git commit -m "feat(ui): redesign LoginScreen with iOS Cupertino aesthetic"
  ```

---

### Task 2: Redesign thanh điều hướng, thẻ thống kê và bộ lọc phân đoạn trên `main.dart`

**Files:**
- Modify: `lib/main.dart`
- Test: `test/widget_test.dart`

**Interfaces:**
- Consumes: `lib/database_helper.dart`, `lib/auth_service.dart`, `lib/login_screen.dart`
- Produces: Màn hình chính mang đậm phong cách iOS Cupertino (AppBar, Stats card, Search Bar, Segmented Control).

- [ ] **Step 1: Cập nhật `AppColors` chuẩn bảng màu iOS**
  Chuyển đổi bảng màu trong `lib/main.dart` sang các token màu Apple:
  - `systemBackground`: `0xFFF2F2F7`
  - `secondaryBackground`: `0xFFFFFFFF`
  - `primaryBlue`: `0xFF007AFF` (Apple System Blue)
  - `systemGreen`: `0xFF34C759`
  - `systemOrange`: `0xFFFF9500`
  - `systemRed`: `0xFFFF3B30`
  - `systemGray`: `0xFF8E8E93`
  - `separator`: `0xFFC6C6C8`

- [ ] **Step 2: Nâng cấp AppBar phong cách Apple Large Title & nút Đăng xuất iOS**
  - AppBar với nền mờ trong suốt nhẹ nhàng, tiêu đề "TODOLIST" lớn và sắc nét.
  - Nút Đăng xuất ở góc trái: Icon `Icons.logout_rounded` màu đỏ iOS thanh mảnh kèm nhãn văn bản tinh tế.
  - Nút Dọn dẹp việc đã xong: Icon `CupertinoIcons.trash` màu đỏ khi có task hoàn thành.

- [ ] **Step 3: Redesign Thẻ Thống Kê & Thanh Tìm Kiếm**
  - Thẻ thống kê: Nền trắng bo góc 16pt, viền phân cách mỏng, thanh tiến độ bo tròn hai đầu màu `systemBlue` và `systemGreen`, hiển thị số lượng trực quan.
  - Thanh tìm kiếm: Phong cách `CupertinoSearchTextField` với nền xám nhạt `0xFFE5E5EA`, icon kính lúp mờ và nút xóa chữ `x`.

- [ ] **Step 4: Chuyển đổi bộ lọc trạng thái sang `CupertinoSlidingSegmentedControl`**
  - Thay thế các chip lọc cũ bằng thanh trượt phân đoạn 3 tab: "Tất cả", "Đang làm", "Đã xong" chuẩn iOS.

- [ ] **Step 5: Chạy test xác nhận không vỡ layout**
  Chạy: `flutter test test/widget_test.dart`
  Kỳ vọng: PASS.

- [ ] **Step 6: Commit**
  ```bash
  git add lib/main.dart
  git commit -m "feat(ui): implement iOS Cupertino navigation bar, search and segmented filters"
  ```

---

### Task 3: Redesign danh sách công việc & Khay trượt tạo mới/chỉnh sửa (Cupertino Modal Sheet)

**Files:**
- Modify: `lib/main.dart`
- Test: `test/widget_test.dart`

**Interfaces:**
- Consumes: `TodoItem`, `DatabaseHelper`
- Produces: Danh sách task Inset Grouped và Modal Sheet tạo/sửa chuẩn iOS.

- [ ] **Step 1: Redesign thẻ công việc (Task Card)**
  - Thẻ công việc: Nền trắng bo góc 14pt, bóng mờ siêu nhẹ (blur 12, alpha 0.04), khoảng cách giữa các thẻ 10pt.
  - Checkbox tròn phong cách iOS: Tròn trịa, khi tick hiển thị nền xanh lá `systemGreen` với icon check trắng; khi chưa tick hiển thị vòng tròn viền xám mỏng.
  - Mức độ ưu tiên: Badge pastel bo góc 6pt (`Dễ` màu xanh lá dịu, `Trung bình` màu cam nhạt, `Khó` màu đỏ hồng nhẹ).
  - Nút sửa/xóa: Nút tròn nhỏ thanh mảnh màu xám nhạt với icon sắc nét.

- [ ] **Step 2: Redesign khay trượt Tạo mới & Chỉnh sửa công việc (Modal Sheet)**
  - Khi bấm "Tạo công việc" hoặc nút chỉnh sửa: Mở BottomSheet bo góc trên 24pt, có thanh kéo indicator ở trên cùng (`Cupertino bottom sheet`).
  - Trường nhập liệu: Gọn gàng với nhãn tiêu đề nhỏ, nền xám nhạt `0xFFF2F2F7`, bo góc 12pt.
  - Chọn ngày & hạn chót (Deadline): Bộ chọn ngày giờ với nút chọn rõ ràng, hiển thị tag hạn chót phong cách iOS.
  - Nút hành động chính: Nút Apple Blue nổi bật ở cuối khay trượt.

- [ ] **Step 3: Chạy toàn bộ test suites**
  Chạy: `flutter test`
  Kỳ vọng: Toàn bộ 18/18 test case pass 100%.

- [ ] **Step 4: Phân tích tĩnh (`flutter analyze`)**
  Chạy: `flutter analyze`
  Kỳ vọng: `No issues found!`.

- [ ] **Step 5: Commit**
  ```bash
  git add lib/main.dart test/widget_test.dart
  git commit -m "feat(ui): redesign task cards and modal sheet with iOS Cupertino patterns"
  ```
