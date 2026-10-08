# Ứng Dụng Quản Lý Công Việc (TODOLIST - Task Manager)

Dự án Flutter xây dựng ứng dụng Quản lý công việc (Todo List / Task Manager) cao cấp, được đồng bộ **100% ngôn ngữ Tiếng Việt thuần** (đã loại bỏ toàn bộ các phụ chú tiếng Anh thừa thãi), tích hợp đầy đủ hệ thống **FR (Yêu cầu Chức năng)** và **NFR (Yêu cầu Phi chức năng)** chọn lọc, sửa triệt để lỗi tràn pixel và hỗ trợ lịch chọn ngày Tiếng Việt hoàn toàn.

---

## 🌟 Kiến Trúc & Tiêu Chuẩn Thiết Kế

Dự án được triển khai dựa trên 3 trụ cột thiết kế và chất lượng phần mềm:

1. **UI/UX Pro Max (Hệ thống Thiết kế Chính - Primary Design System)**:
   - Phân cấp thị giác chặt chẽ (Visual Hierarchy): Header $\rightarrow$ Thống kê tiến độ $\rightarrow$ Form nhập liệu $\rightarrow$ Thanh tìm kiếm $\rightarrow$ Bộ lọc trạng thái $\rightarrow$ Danh sách việc.
   - Quy chuẩn khoảng cách theo thang đo 8pt/4pt đồng nhất (`16.0`, `12.0`, `8.0`).
   - Bo tròn viền mềm mại (`BorderRadius.circular(14.0 - 20.0)`).
   - Độ đổ bóng mờ nhẹ (`elevation`, `boxShadow` mềm), tăng chiều sâu thị giác.
   - Tối ưu kích thước cảm ứng (Touch Target $\ge 48\times 48$ dp) đảm bảo chuẩn trợ năng WCAG AA.

2. **Taste Skill (Lớp Nghệ Thuật & Trải Nghiệm - Secondary Design Layer)**:
   - Phong cách hiện đại, thanh lịch (Modern Minimalist / Soft Surfaces), triệt để loại bỏ giao diện AI thô sơ hoặc gradient lòe loẹt.
   - Phân loại màu sắc theo mức độ ưu tiên (Dễ: Xanh lá, Trung bình: Cam, Khó: Đỏ).
   - Hiệu ứng chuyển động vi mô (Micro-interactions) mượt mà với `AnimatedContainer`, `Curves.easeOutCubic`.
   - Bố cục thông thoáng, màu nền trung tính tương phản sắc nét với thẻ card.

3. **Front-End Quality Gate (Kiểm Thử & Xử Lý Biên - Quality & Edge Cases)**:
   - **Xử lý bàn phím**: Bọc toàn bộ màn hình trong `GestureDetector(onTap: () => FocusScope.of(context).unfocus())` giúp chạm ra ngoài tự động ẩn bàn phím.
   - **Chống tràn màn hình (Zero Overflow Guarantee)**: Đã khắc phục triệt để lỗi `RenderFlex overflow 1.9px` trên trường Mức độ bằng `isExpanded: true` và tinh chỉnh `contentPadding` linh hoạt; sử dụng `CustomScrollView` kết hợp `SliverList` loại bỏ hoàn toàn lỗi tràn layout khi mở bàn phím ảo.
   - **Vùng an toàn (SafeArea)**: Đảm bảo giao diện hiển thị hoàn hảo trên các thiết bị có tai thỏ (Notch), Dynamic Island hay phím điều hướng hệ thống.
   - **Ngăn ngừa rò rỉ bộ nhớ (Memory Leak)**: Toàn bộ `TextEditingController` và `FocusNode` được thu hồi tài nguyên đầy đủ trong hàm `dispose()`.
   - **Validation chặt chẽ**: Kiểm tra chuỗi rỗng và khoảng trắng (`trim().isEmpty`), ngăn chặn dữ liệu không hợp lệ.

---

## 🎨 Hệ Màu Chuẩn (Design Tokens - `AppColors`)

| Tên Hằng Số | Mã Hex | Vai Trò & Vị Trí Áp Dụng |
| :--- | :--- | :--- |
| `deepNavy` | `#03045E` | Tiêu đề AppBar, nhãn form, text việc chưa làm, nền SnackBar |
| `primaryBlue` | `#0077B6` | Nút "THÊM CÔNG VIỆC", nền thẻ tiến độ, chip lọc đang chọn |
| `vibrantOcean` | `#00B4D8` | Icon checkbox khi hoàn thành, thanh tiến độ (Progress Bar), nút Hoàn tác |
| `softSky` | `#90E0EF` | Viền các thẻ card, viền input field, viền chip lọc chưa chọn |
| `iceBlueTint` | `#CAF0F8` | Nền thẻ task đã xong, nền input field, badge đếm số lượng |
| `pureWhite` | `#FFFFFF` | Nền các thẻ việc chưa làm, text trên nền màu đậm |
| `background` | `#F7FAFC` | Nền Scaffold tổng thể tạo độ tương phản êm dịu |
| `editGreen` | `#2A9D8F` | Nút Sửa công việc (Bút chì xanh) & thông báo thành công |
| `deleteRed` | `#E63946` | Nút Xóa công việc (Dấu hủy đỏ) & thông báo cảnh báo |
| `priorityEasyBg/Text` | `#E8F5E9` / `#2E7D32` | Huy hiệu Mức độ Dễ (Xanh lá cây nhạt/đậm) |
| `priorityMediumBg/Text` | `#FFF3E0` / `#E65100` | Huy hiệu Mức độ Trung bình (Cam nhạt/đậm) |
| `priorityHardBg/Text` | `#FFEBEE` / `#C62828` | Huy hiệu Mức độ Khó (Đỏ hồng nhạt/đậm) |

---

## 📌 Danh Mục Yêu Cầu Chọn Lọc (FR & NFR)

### A. Yêu Cầu Chức Năng (Functional Requirements - FR)
- **FR-01: Quản lý Vòng đời Công việc (Task CRUD Lifecycle)**:
  - Thêm mới công việc với Tiêu đề (bắt buộc), Nội dung chi tiết (tùy chọn), Ngày thực hiện (chọn qua lịch), Mức độ ưu tiên.
  - Chuyển đổi trạng thái (chưa làm $\leftrightarrow$ hoàn thành) bằng Checkbox trực quan; khi hoàn thành gạch ngang chữ và làm mờ thẻ.
  - Chỉnh sửa công việc (Edit Modal BottomSheet) cập nhật toàn bộ trường thông tin.
  - Xóa công việc kèm tính năng **Hoàn tác (Undo)** trong vòng 4 giây qua SnackBar.
- **FR-02: Thống kê Tiến độ (Progress Summary Card)**:
  - Hiển thị tỷ lệ hoàn thành `$completed / $total việc hoàn thành` cùng phần trăm `%` và thanh tiến độ `LinearProgressIndicator` động.
- **FR-03: Bộ lọc Trạng thái (Status Filter Chips)**:
  - 3 tab lọc: "Tất cả", "Đang làm", "Đã xong" kèm huy hiệu đếm số lượng việc theo thời gian thực.
- **FR-04: Tìm kiếm theo Từ khóa (Real-time Search Bar)**:
  - Thanh tìm kiếm tức thời cho phép tra cứu công việc theo Tiêu đề hoặc Nội dung; có nút xóa nhanh từ khóa (Clear search).
- **FR-05: Dọn dẹp Hàng loạt (Bulk Clear Completed Tasks)**:
  - Nút dọn dẹp trên AppBar (icon `delete_sweep`) giúp xóa toàn bộ các việc đã hoàn thành, có hộp thoại xác nhận (Confirmation Dialog) bảo vệ người dùng.
- **FR-06: Phân loại Thị giác theo Mức độ (Visual Priority Badges)**:
  - Màu sắc ngữ nghĩa trực quan cho từng mức độ: Dễ (Xanh lá), Trung bình (Cam), Khó (Đỏ).

### B. Yêu Cầu Phi Chức Năng (Non-Functional Requirements - NFR)
- **NFR-01: Ngôn ngữ & Bản địa hóa Hoàn chỉnh (100% Vietnamese Localization)**:
  - Toàn bộ giao diện là tiếng Việt chuẩn mực, loại bỏ các nhãn tiếng Anh thừa thãi như `(Title)`, `(Content)`, `(Date)`, `(Type)`, `(ADD)`.
  - Tích hợp `flutter_localizations` chuẩn SDK: Hộp thoại lịch chọn ngày (`showDatePicker`) hiển thị Thứ trong tuần (T2 - CN), Tháng tiếng Việt ("Tháng 10 năm 2026") và tiêu đề ngày chuẩn tiếng Việt.
- **NFR-02: Chuẩn UI/UX & Trợ năng (Accessibility WCAG AA)**:
  - Vùng chạm tối thiểu $48 \times 48$ dp.
  - Tỷ lệ tương phản màu nền và chữ $\ge 4.5:1$ đạt chuẩn WCAG AA.
- **NFR-03: Độ tin cậy & Chống lỗi Giao diện (Zero Overflow Guarantee)**:
  - Triệt tiêu hoàn toàn lỗi RenderFlex overflow (sửa lỗi 1.9px bằng `isExpanded: true` và co giãn linh hoạt).
  - Tự động ẩn bàn phím khi bấm ra ngoài; chống tràn màn hình khi bàn phím xuất hiện với `CustomScrollView`.
- **NFR-04: Hiệu năng Mượt mà (60/120 FPS Fluidity)**:
  - Tối ưu hóa render qua `const` constructors và local state tinh gọn.
  - Phản hồi thao tác tức thì $< 16$ ms.
- **NFR-05: Quản lý Tài nguyên & Bộ nhớ (Memory Safety & Maintainability)**:
  - Toàn bộ controllers (`TextEditingController`, `FocusNode`) được thu hồi tài nguyên đầy đủ trong `dispose()`.
  - Đóng gói trọn vẹn trong 01 file `lib/main.dart` duy nhất.
  - Kiểm tra tĩnh `flutter analyze` đạt 0 lỗi, 0 cảnh báo.
  - Bộ kiểm thử tự động `flutter test` đạt 100% Pass.

---

## 🚀 Hướng Dẫn Chạy & Kiểm Thử

### Yêu Cầu Môi Trường
- Flutter SDK $\ge 3.24.0$ (Đã kiểm thử tương thích hoàn hảo trên Flutter 3.47.4 / Dart 3.13.3).

### 1. Khởi Chạy Ứng Dụng
```bash
flutter run
```

### 2. Chạy Bộ Kiểm Thử (Widget Tests)
```bash
flutter test
```
*(Đầy đủ các ca kiểm thử: Thêm, Sửa, Xóa, Hoàn tác, Tìm kiếm từ khóa, Lọc trạng thái, Dọn dẹp việc đã xong và DatePicker Tiếng Việt).*

### 3. Kiểm Tra Mã Nguồn (Static Analysis)
```bash
flutter analyze
```
*(Kết quả mong đợi: `No issues found!`)*
