import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:assignment_todo/main.dart';

void main() {
  testWidgets('TaskFlow App full assignment test - Pure Vietnamese localization & FRs', (WidgetTester tester) async {
    // Thiết lập kích thước màn hình điện thoại thực tế (Pixel 7 / iPhone 15)
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Khởi chạy ứng dụng
    await tester.pumpWidget(const TaskFlowApp());
    await tester.pumpAndSettle();

    // 1. Kiểm tra Tiêu đề & Header Tiếng Việt chuẩn (không chêm tiếng Anh)
    expect(find.text('TODOLIST'), findsOneWidget);
    expect(find.text('TIẾN ĐỘ CÔNG VIỆC'), findsOneWidget);
    expect(find.text('THÊM CÔNG VIỆC'), findsOneWidget);

    // 2. Kiểm tra Nhãn Form Nhập liệu Tiếng Việt thuần
    expect(find.text('Tiêu đề'), findsOneWidget);
    expect(find.text('Nội dung'), findsOneWidget);
    expect(find.text('Ngày thực hiện'), findsOneWidget);
    expect(find.text('Mức độ'), findsOneWidget);

    // 3. Kiểm tra Danh sách công việc mẫu ban đầu
    expect(find.text('Học Java'), findsOneWidget);
    expect(find.text('Học React Native'), findsOneWidget);
    expect(find.text('Học Kotlin'), findsOneWidget);

    // 4. Kiểm tra Validation khi bỏ trống Tiêu đề
    await tester.tap(find.text('THÊM CÔNG VIỆC'));
    await tester.pumpAndSettle();
    expect(find.text('Vui lòng nhập tiêu đề công việc!'), findsOneWidget);

    // 5. Thêm công việc mới với Tiêu đề và Nội dung
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nhập tên công việc...'),
      'Học Flutter UI',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nhập mô tả chi tiết công việc...'),
      'Nâng cao kỹ năng',
    );
    await tester.tap(find.text('THÊM CÔNG VIỆC'));
    await tester.pumpAndSettle();

    // Xác minh công việc mới xuất hiện trên đầu danh sách
    expect(find.text('Học Flutter UI'), findsOneWidget);
    expect(find.text('Nâng cao kỹ năng'), findsOneWidget);

    // 6. Kiểm tra chuyển đổi trạng thái hoàn thành (Toggle Status)
    final checkFinder = find.byTooltip('Đánh dấu hoàn thành').first;
    await tester.ensureVisible(checkFinder);
    await tester.tap(checkFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Đã cập nhật trạng thái thành công'), findsWidgets);
    await tester.pumpAndSettle();

    // 7. Kiểm tra Tính năng Tìm kiếm (FR-04)
    final searchFinder = find.widgetWithText(TextField, 'Tìm kiếm công việc theo từ khóa...');
    expect(searchFinder, findsOneWidget);
    await tester.enterText(searchFinder, 'Kotlin');
    await tester.pumpAndSettle();

    // Chỉ còn task Học Kotlin
    expect(find.text('Học Kotlin'), findsOneWidget);
    expect(find.text('Học Java'), findsNothing);

    // Xóa tìm kiếm
    await tester.tap(find.byTooltip('Xóa tìm kiếm'));
    await tester.pumpAndSettle();
    expect(find.text('Học Java'), findsOneWidget);

    // 8. Kiểm tra Bộ lọc trạng thái (Filter Chips)
    // Chuyển sang "Đang làm"
    await tester.tap(find.text('Đang làm'));
    await tester.pumpAndSettle();
    expect(find.text('Đang làm'), findsOneWidget);

    // Chuyển sang "Đã xong"
    await tester.tap(find.text('Đã xong'));
    await tester.pumpAndSettle();
    expect(find.text('Học Java'), findsOneWidget);

    // Chuyển lại "Tất cả"
    await tester.tap(find.text('Tất cả'));
    await tester.pumpAndSettle();
    expect(find.text('Học Kotlin'), findsOneWidget);
  });

  testWidgets('TaskFlow App Edit, Delete with Undo, and Clear Completed test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const TaskFlowApp());
    await tester.pumpAndSettle();

    // 1. Thử mở BottomSheet chỉnh sửa (Edit)
    final editFinder = find.byTooltip('Chỉnh sửa công việc').first;
    await tester.ensureVisible(editFinder);
    await tester.tap(editFinder);
    await tester.pumpAndSettle();

    expect(find.text('Chỉnh sửa công việc'), findsOneWidget);
    expect(find.text('LƯU THAY ĐỔI'), findsOneWidget);

    // Thay đổi tiêu đề
    await tester.enterText(find.widgetWithText(TextFormField, 'Nhập tên công việc'), 'Học Java Chuyên Sâu');
    await tester.tap(find.text('LƯU THAY ĐỔI'));
    await tester.pumpAndSettle();

    expect(find.text('Học Java Chuyên Sâu'), findsOneWidget);
    expect(find.text('Đã cập nhật công việc thành công!'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // 2. Thử xóa công việc (Delete) và Hoàn tác (Undo)
    final deleteFinder = find.byTooltip('Xóa công việc').first;
    await tester.ensureVisible(deleteFinder);
    await tester.tap(deleteFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('HOÀN TÁC'), findsOneWidget);
    expect(find.text('Học Java Chuyên Sâu'), findsNothing);

    // Bấm HOÀN TÁC
    await tester.tap(find.text('HOÀN TÁC'));
    await tester.pumpAndSettle();

    // Công việc đã được phục hồi
    expect(find.text('Học Java Chuyên Sâu'), findsOneWidget);

    // 3. Kiểm tra Dọn dẹp việc đã xong (FR-05)
    final clearFinder = find.byTooltip('Dọn dẹp việc đã xong');
    expect(clearFinder, findsOneWidget);
    await tester.tap(clearFinder);
    await tester.pumpAndSettle();

    expect(find.text('Dọn dẹp công việc'), findsOneWidget);
    expect(find.text('XÓA HẾT'), findsOneWidget);

    await tester.tap(find.text('XÓA HẾT'));
    await tester.pumpAndSettle();

    // Task hoàn thành đã bị xóa
    expect(find.text('Học Java Chuyên Sâu'), findsNothing);
  });
}
