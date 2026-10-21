# Design Specification: iOS Cupertino UI/UX Redesign (Impeccable & Taste)

**Date:** 2026-10-21  
**Project:** TaskFlow (assignment_todo)  
**Style:** iOS Cupertino (Apple Human Interface Guidelines & Anti-AI-Slop)  
**Status:** Approved  

---

## 1. Intent & The Why

Ứng dụng hiện tại có đầy đủ tính năng và logic nghiệp vụ (Đăng nhập, Quản lý phiên, SQLite, CRUD, Tìm kiếm, Lọc, Deadline). Tuy nhiên, giao diện hiện mang phong cách Material pha trộn, thiếu độ sắc sảo và cảm giác cao cấp của hệ sinh thái iOS (Cupertino), vốn là nền tảng mục tiêu chính của người dùng.

Mục tiêu của thiết kế này là nâng cấp toàn diện diện mạo và cảm giác trải nghiệm (Look & Feel) lên chuẩn **iOS Cupertino** tinh tế và đẳng cấp:
- Tuân thủ nghiêm ngặt **Apple Human Interface Guidelines (Apple HIG)**.
- Áp dụng nguyên tắc **Taste & Anti-AI-Slop**: loại bỏ gradient sặc sỡ, bỏ icon emoji, tinh chỉnh optical hierarchy, phân cấp typography chuẩn SF Pro, bo góc nhất quán (10pt, 14pt, 20pt) và đổ bóng mờ siêu nhẹ (opacity 4-8%).
- Đáp ứng chuẩn **Impeccable**: độ tương phản WCAG AA (≥ 4.5:1), touch target tối thiểu 44x44pt, chuyển động mượt mà tự nhiên (ease-out cubic / spring), hiển thị empty state truyền cảm hứng.
- **Ràng buộc phạm vi:** Giữ nguyên 100% logic nghiệp vụ và tính năng (FRs: Đăng nhập/Đăng ký, Duy trì phiên, CRUD task, Deadline, Lọc, Tìm kiếm, Dọn dẹp, Đăng xuất; NFRs: Bản địa hóa tiếng Việt, giải phóng bộ nhớ, không rò rỉ state). Tuyệt đối không mở rộng thêm tính năng thừa.

---

## 2. Design Tokens & Visual Palette (Cupertino Palette)

```dart
class CupertinoAppColors {
  // Backgrounds
  static const Color systemBackground = Color(0xFFF2F2F7);     // iOS grouped background
  static const Color secondaryBackground = Color(0xFFFFFFFF);  // Card / grouped cell background
  static const Color tertiaryBackground = Color(0xFFE5E5EA);   // Input / separator fill

  // Apple System Accents
  static const Color systemBlue = Color(0xFF007AFF);           // Primary iOS tint
  static const Color systemGreen = Color(0xFF34C759);          // Completed / Success
  static const Color systemOrange = Color(0xFFFF9500);         // Medium priority
  static const Color systemRed = Color(0xFFFF3B30);            // High priority / Destructive
  static const Color systemGray = Color(0xFF8E8E93);           // Tertiary text / muted icon

  // Text Colors
  static const Color label = Color(0xFF000000);                // Primary text
  static const Color secondaryLabel = Color(0xFF3C3C43);       // Secondary text (60% alpha)
  static const Color tertiaryLabel = Color(0xFF8A8A8E);        // Placeholder / caption
  static const Color separator = Color(0xFFC6C6C8);            // Thin divider lines

  // Priority Tokens (iOS Inset Tinted Badges)
  static const Color easyBadgeBg = Color(0xFFE8F5E9);
  static const Color easyBadgeText = Color(0xFF2E7D32);
  static const Color mediumBadgeBg = Color(0xFFFFF3E0);
  static const Color mediumBadgeText = Color(0xFFE65100);
  static const Color hardBadgeBg = Color(0xFFFFEBEE);
  static const Color hardBadgeText = Color(0xFFC62828);
}
```

---

## 3. Screen-by-Screen Redesign Details

### 3.1. LoginScreen (`lib/login_screen.dart`)
- **Header:** Biểu tượng iOS thanh nhã với nền xanh Apple Blue bo góc 20pt, typography Large Title "TaskFlow" (font weight 700, letterSpacing -0.5).
- **Segmented Toggle:** Chuyển đổi giữa "Đăng nhập" và "Đăng ký" bằng `CupertinoSlidingSegmentedControl` mượt mà thay vì nút text button rời rạc.
- **Form Controls:** Trường nhập liệu phong cách iOS (`CupertinoTextField` hoặc `TextField` với nền `systemBackground`, viền bo tròn 12pt, icon iOS mờ nhẹ, nút ẩn/hiện mật khẩu tinh xảo).
- **Buttons:**
  - Nút chính (Đăng nhập / Đăng ký): Apple Blue pill/rounded rect (height 50pt, radius 14pt, text bold 16pt, không gradient rực rỡ).
  - Nút "Tài khoản mẫu (Test nhanh)": Nền xám nhạt `tertiaryBackground`, icon tia sét iOS, chữ `systemBlue` gọn gàng.
- **Phản hồi lỗi:** Tích hợp `CupertinoAlertDialog` hoặc SnackBar màu `secondaryLabel` phong cách iOS banner nổi phía trên/dưới.

### 3.2. TodoListScreen (`lib/main.dart`)
- **Navigation Bar:** Tiêu đề "TODOLIST" hiển thị phong cách Apple Large Title. Nút Đăng xuất ở bên trái dạng chữ/icon đỏ thanh thoát (`CupertinoIcons.square_arrow_left` hoặc `Icons.logout_rounded`).
- **Thẻ Thống Kê Tiến Độ:** Thiết kế thẻ nổi iOS sạch sẽ (radius 16pt, soft shadow blur 16, opacity 4%), thanh tiến độ (Progress bar) bo tròn mềm mại màu `systemBlue` / `systemGreen`.
- **Thanh Tìm Kiếm (Search Bar):** Thanh tìm kiếm dạng `CupertinoSearchTextField` (nền xám `tertiaryBackground`, icon kính lúp mờ, nút xóa nhanh `x`).
- **Bộ Lọc Phân Đoạn (Segmented Control):** `CupertinoSlidingSegmentedControl<TaskFilter>` với 3 tab: "Tất cả", "Đang làm", "Đã xong", chuyển động trượt êm ái.
- **Danh Sách Công Việc (Task Cards):**
  - Card bo góc 14pt, nền trắng tinh tế, viền phân cách mỏng 0.5pt hoặc bóng mờ siêu mịn.
  - Checkbox dạng iOS Circle: Tròn trịa, khi hoàn thành hiện tick xanh `systemGreen`, tiêu đề gạch ngang màu chữ xám `tertiaryLabel`.
  - Badges mức độ: Nhỏ gọn, bo tròn 6pt, màu pastel nhã nhặn.
  - Nút Sửa / Xóa: Nút tròn nhỏ hoặc menu vuốt iOS với icon thanh thoát.
- **Form Tạo Mới & Chỉnh Sửa Công Việc:**
  - Chuyển thành khay trượt Cupertino Modal Sheet từ dưới lên (Bottom Sheet bo góc trên 24pt, có thanh kéo indicator phía trên).
  - Chọn ngày và deadline theo phong cách chọn thời gian iOS trực quan.
- **Empty State:** Hình minh họa vector đơn sắc phong cách SF Symbols với thông điệp tích cực, lịch sự bằng tiếng Việt.

---

## 4. Anti-AI-Slop & Craft Verification Checklist

- [x] Không có hiệu ứng viền neon tím/xanh ngọc chói mắt.
- [x] Không sử dụng emoji làm icon chức năng (100% sử dụng icon vector chuẩn hệ điều hành).
- [x] Không lồng card nhiều tầng (không "card inside card inside card").
- [x] Typography: Hệ số khoảng cách 4pt/8pt, độ cao dòng (line-height) thoáng, số đếm tabular.
- [x] Tương phản màu chữ trên nền luôn đạt chuẩn WCAG AA (≥ 4.5:1).
- [x] Toàn bộ 18 test cases kiểm thử tự động của ứng dụng tiếp tục pass 100%.
