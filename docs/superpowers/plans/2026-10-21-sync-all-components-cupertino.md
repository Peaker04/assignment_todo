# Synchronize All Existing Components to iOS Cupertino Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Đồng bộ hóa 100% các thành phần có sẵn (Dialogs, Dropdown mức độ, BottomSheet chỉnh sửa, Feedback banner) sang chuẩn iOS Cupertino tinh tế và nhất quán.

**Architecture:** Chuyển đổi các AlertDialog sang `CupertinoAlertDialog` với `CupertinoDialogAction`; thay thế DropdownButtonFormField thành `CupertinoSlidingSegmentedControl` cho chọn mức độ ưu tiên ("Dễ", "Trung bình", "Khó"); chuẩn hóa Cupertino Theme cho Date/Time picker; nâng cấp khay chỉnh sửa và thông báo nổi phong cách iOS Capsule.

**Tech Stack:** Flutter, Cupertino widgets, `flutter_test`.

## Global Constraints
- 100% đồng bộ phong cách iOS Cupertino (Apple HIG & Anti-AI-slop).
- Giữ nguyên 100% các finder và chức năng để toàn bộ 18 test cases tiếp tục pass 100%.

---

### Task 1: Đồng bộ hóa toàn bộ Hộp thoại xác nhận (Dialogs) sang `CupertinoAlertDialog`
- File: `lib/main.dart`
- Chuyển `_showLogoutDialog` sang `CupertinoAlertDialog` với các nút `CupertinoDialogAction`.
- Chuyển dialog trong `_clearCompletedTasks` sang `CupertinoAlertDialog` với `CupertinoDialogAction` ("HỦY" và "XÓA HẾT").
- Test: `flutter test test/widget_test.dart` -> PASS.

### Task 2: Chuyển đổi menu chọn Mức độ ưu tiên sang `CupertinoSlidingSegmentedControl`
- File: `lib/main.dart`
- Trong Form Tạo mới (`_buildAddTaskForm`): thay `DropdownButtonFormField` bằng `CupertinoSlidingSegmentedControl<String>` với 3 tab: "Dễ", "Trung bình", "Khó".
- Trong Form Chỉnh sửa (`_editTask`): thay `DropdownButtonFormField` bằng `CupertinoSlidingSegmentedControl<String>`.
- Test: `flutter test test/widget_test.dart` -> PASS.

### Task 3: Tinh chỉnh iOS Theme cho Pickers, Khay chỉnh sửa và Banner thông báo
- File: `lib/main.dart`
- Tinh chỉnh `ThemeData` với `datePickerTheme` và `timePickerTheme` chuẩn bo góc và màu xanh Apple (`#007AFF`).
- Chuẩn hóa SnackBar thành Floating Capsule màu tối iOS (`#1C1C1E`) với chữ trắng và nút "HOÀN TÁC" màu xanh Apple.
- Test toàn diện: `flutter test` (18/18 pass) & `flutter analyze` (0 lỗi).
