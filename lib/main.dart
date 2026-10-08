import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const TaskFlowApp());
}

// ============================================================================
// 1. DESIGN TOKENS & COLOR PALETTE (UI/UX Pro Max & Taste Layer - Soft Modern)
// ============================================================================
/// Bảng màu chuẩn thiết kế hệ thống, tối ưu độ mềm mại và chiều sâu thị giác
class AppColors {
  /// Tiêu đề AppBar, text tiêu đề task chưa hoàn thành, các điểm nhấn quan trọng
  static const Color deepNavy = Color(0xFF03045E);

  /// Nút bấm Thêm công việc, background của Header card, icon active
  static const Color primaryBlue = Color(0xFF0077B6);

  /// Icon checkbox khi active, điểm nhấn thanh tiến độ (progress bar), badge
  static const Color vibrantOcean = Color(0xFF00B4D8);

  /// Đường viền mờ (borders), nền chip lọc chưa chọn, shadow mờ
  static const Color softSky = Color(0xFF90E0EF);

  /// Nền thẻ task hoàn thành, nền input field, nền các component phụ
  static const Color iceBlueTint = Color(0xFFCAF0F8);

  /// Nền các thẻ Card task chưa làm, text trên nền màu đậm
  static const Color pureWhite = Color(0xFFFFFFFF);

  /// Nền Scaffold tổng thể tạo độ tương phản dịu êm, chống mỏi mắt
  static const Color background = Color(0xFFF8FAFD);

  // --- Semantic Auxiliary Tokens ---
  static const Color textMuted = Color(0xFF64748B);
  static const Color editGreen = Color(0xFF2A9D8F);
  static const Color deleteRed = Color(0xFFE63946);
  static const Color typeBadgeBg = Color(0xFFE0F2FE);

  // --- Mức độ ưu tiên Tokens (Màu Pastel Hữu cơ Mềm mại) ---
  static const Color priorityEasyBg = Color(0xFFE8F5E9);
  static const Color priorityEasyText = Color(0xFF2E7D32);
  static const Color priorityMediumBg = Color(0xFFFFF3E0);
  static const Color priorityMediumText = Color(0xFFE65100);
  static const Color priorityHardBg = Color(0xFFFFEBEE);
  static const Color priorityHardText = Color(0xFFC62828);

  // --- Gradients Thư thái & Tinh tế ---
  static const List<Color> oceanHeaderGradient = [
    Color(0xFF023E8A),
    Color(0xFF0077B6),
    Color(0xFF0096C7),
  ];

  static const List<Color> buttonGradient = [
    Color(0xFF0077B6),
    Color(0xFF00B4D8),
  ];
}

// ============================================================================
// 2. DATA MODEL & ENUMS (Local State Only)
// ============================================================================
/// Bộ lọc trạng thái công việc (Tiếng Việt)
enum TaskFilter {
  all('Tất cả'),
  incomplete('Đang làm'),
  completed('Đã xong');

  final String label;
  const TaskFilter(this.label);
}

/// Model dữ liệu cho mỗi công việc bám sát Assignment
class TodoItem {
  final String id;
  String title;
  String content;
  String date;
  String type;
  bool isCompleted;
  final DateTime createdAt;

  TodoItem({
    required this.id,
    required this.title,
    this.content = '',
    required this.date,
    this.type = 'Dễ',
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

// ============================================================================
// 3. ROOT WIDGET (Hỗ trợ Đầy đủ Bản địa hóa Tiếng Việt - NFR-01)
// ============================================================================
class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản lý Công việc - TODOLIST',
      debugShowCheckedModeBanner: false,
      // Cấu hình Localization hỗ trợ tiếng Việt toàn diện cho DatePicker và hệ thống
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('vi', 'VN'),
        Locale('en', 'US'),
      ],
      locale: const Locale('vi', 'VN'),
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
          primary: AppColors.primaryBlue,
          surface: AppColors.pureWhite,
        ),
      ),
      home: const TodoListScreen(),
    );
  }
}

// ============================================================================
// 4. MAIN SCREEN (StatefulWidget - Local State Only)
// ============================================================================
class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  // Form key & Text controllers cho form Thêm mới
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _dateController;
  late final TextEditingController _searchController;
  late final FocusNode _titleFocusNode;

  // Từ khóa tìm kiếm (FR-04)
  String _searchQuery = '';

  // Giá trị mặc định cho Dropdown Mức độ
  String _selectedType = 'Dễ';
  final List<String> _typeOptions = ['Dễ', 'Trung bình', 'Khó'];

  // Bộ lọc hiện tại
  TaskFilter _currentFilter = TaskFilter.all;

  // Format ngày tháng chuẩn dd/MM/yyyy
  static String _formatDate(DateTime dt) {
    final String day = dt.day.toString().padLeft(2, '0');
    final String month = dt.month.toString().padLeft(2, '0');
    final String year = dt.year.toString();
    return '$day/$month/$year';
  }

  // Danh sách công việc mẫu ban đầu
  final List<TodoItem> _tasks = [
    TodoItem(
      id: 'task_1',
      title: 'Học Java',
      content: 'Học Java cơ bản và hướng đối tượng',
      date: '28/02/2023',
      type: 'Dễ',
      isCompleted: true,
    ),
    TodoItem(
      id: 'task_2',
      title: 'Học React Native',
      content: 'Xây dựng giao diện ứng dụng di động',
      date: '24/03/2023',
      type: 'Trung bình',
      isCompleted: false,
    ),
    TodoItem(
      id: 'task_3',
      title: 'Học Kotlin',
      content: 'Lập trình Android nâng cao',
      date: '15/04/2023',
      type: 'Khó',
      isCompleted: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _dateController = TextEditingController(text: _formatDate(DateTime.now()));
    _searchController = TextEditingController();
    _titleFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Quality Gate: Bắt buộc giải phóng controller để tránh rò rỉ bộ nhớ (NFR-05)
    _titleController.dispose();
    _contentController.dispose();
    _dateController.dispose();
    _searchController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  // --- LOGIC NGHIỆP VỤ ---

  /// Thêm công việc mới (FR-01)
  void _addTask() {
    if (_formKey.currentState?.validate() ?? false) {
      final String title = _titleController.text.trim();
      final String content = _contentController.text.trim();
      final String date = _dateController.text.trim();

      setState(() {
        _tasks.insert(
          0,
          TodoItem(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            title: title,
            content: content,
            date: date.isNotEmpty ? date : _formatDate(DateTime.now()),
            type: _selectedType,
            isCompleted: false,
          ),
        );
      });

      _titleController.clear();
      _contentController.clear();
      _dateController.text = _formatDate(DateTime.now());
      _formKey.currentState?.reset();
      FocusScope.of(context).unfocus();

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.pureWhite, size: 20.0),
              const SizedBox(width: 10.0),
              Expanded(
                child: Text(
                  'Đã thêm thành công: "$title"',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.pureWhite, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primaryBlue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Chuyển đổi trạng thái hoàn thành (FR-01)
  void _toggleTask(String id) {
    setState(() {
      final int index = _tasks.indexWhere((item) => item.id == id);
      if (index != -1) {
        _tasks[index].isCompleted = !_tasks[index].isCompleted;
      }
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.pureWhite, size: 20.0),
            SizedBox(width: 10.0),
            Text(
              'Đã cập nhật trạng thái thành công',
              style: TextStyle(color: AppColors.pureWhite, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: AppColors.deepNavy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  /// Xóa công việc kèm SnackBar hỗ trợ Hoàn tác (FR-01)
  void _deleteTask(TodoItem task) {
    final int originalIndex = _tasks.indexOf(task);
    if (originalIndex == -1) return;

    setState(() {
      _tasks.removeAt(originalIndex);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã xóa: "${task.title}"',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.pureWhite, fontWeight: FontWeight.w500),
        ),
        backgroundColor: AppColors.deepNavy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        action: SnackBarAction(
          label: 'HOÀN TÁC',
          textColor: AppColors.vibrantOcean,
          onPressed: () {
            setState(() {
              _tasks.insert(originalIndex, task);
            });
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Chỉnh sửa công việc (FR-01 - Soft Modal BottomSheet)
  void _editTask(TodoItem task) {
    final editTitleCtrl = TextEditingController(text: task.title);
    final editContentCtrl = TextEditingController(text: task.content);
    final editDateCtrl = TextEditingController(text: task.date);
    String editType = task.type;
    final editFormKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalContext).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(22.0, 16.0, 22.0, 24.0),
                decoration: const BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1A03045E),
                      blurRadius: 28.0,
                      offset: Offset(0, -6),
                    ),
                  ],
                ),
                child: Form(
                  key: editFormKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Thanh kéo modal (Pill handle) thanh lịch
                        Center(
                          child: Container(
                            width: 36.0,
                            height: 4.0,
                            margin: const EdgeInsets.only(bottom: 16.0),
                            decoration: BoxDecoration(
                              color: AppColors.softSky.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(2.0),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Chỉnh sửa công việc',
                              style: TextStyle(
                                fontSize: 19.0,
                                fontWeight: FontWeight.bold,
                                color: AppColors.deepNavy,
                                letterSpacing: -0.3,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                              tooltip: 'Đóng',
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14.0),
                        // Tiêu đề
                        TextFormField(
                          controller: editTitleCtrl,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tiêu đề công việc!' : null,
                          decoration: _inputDecoration(label: 'Tiêu đề', hint: 'Nhập tên công việc'),
                        ),
                        const SizedBox(height: 12.0),
                        // Nội dung
                        TextFormField(
                          controller: editContentCtrl,
                          decoration: _inputDecoration(label: 'Nội dung', hint: 'Nhập mô tả chi tiết công việc'),
                        ),
                        const SizedBox(height: 12.0),
                        // Ngày thực hiện
                        TextFormField(
                          controller: editDateCtrl,
                          readOnly: true,
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2035),
                              locale: const Locale('vi', 'VN'),
                              helpText: 'CHỌN NGÀY THỰC HIỆN',
                              cancelText: 'HỦY',
                              confirmText: 'XÁC NHẬN',
                            );
                            if (picked != null) {
                              setModalState(() {
                                editDateCtrl.text = _formatDate(picked);
                              });
                            }
                          },
                          decoration: _inputDecoration(
                            label: 'Ngày thực hiện',
                            hint: 'dd/MM/yyyy',
                            suffixIcon: const Icon(Icons.calendar_today_rounded, size: 18.0, color: AppColors.primaryBlue),
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        // Mức độ
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: editType,
                          items: _typeOptions
                              .map((t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(t, style: const TextStyle(fontSize: 14.0)),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() => editType = val);
                            }
                          },
                          decoration: _inputDecoration(label: 'Mức độ', hint: 'Chọn mức độ'),
                        ),
                        const SizedBox(height: 22.0),
                        // Nút Lưu thay đổi mềm mại
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: AppColors.buttonGradient,
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(16.0),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryBlue.withValues(alpha: 0.28),
                                blurRadius: 14.0,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (editFormKey.currentState?.validate() ?? false) {
                                setState(() {
                                  task.title = editTitleCtrl.text.trim();
                                  task.content = editContentCtrl.text.trim();
                                  task.date = editDateCtrl.text.trim();
                                  task.type = editType;
                                });
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Đã cập nhật công việc thành công!'),
                                    backgroundColor: AppColors.editGreen,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.save_rounded, size: 20.0),
                            label: const Text('LƯU THAY ĐỔI', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.3)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: AppColors.pureWhite,
                              padding: const EdgeInsets.symmetric(vertical: 14.0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Dọn dẹp tất cả các việc đã xong kèm xác nhận (FR-05)
  void _clearCompletedTasks() {
    final completedCount = _tasks.where((t) => t.isCompleted).length;
    if (completedCount == 0) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.0)),
        title: const Row(
          children: [
            Icon(Icons.delete_sweep_rounded, color: AppColors.deleteRed, size: 24.0),
            SizedBox(width: 10.0),
            Text(
              'Dọn dẹp công việc',
              style: TextStyle(color: AppColors.deepNavy, fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa tất cả $completedCount công việc đã hoàn thành?',
          style: const TextStyle(color: AppColors.deepNavy, fontSize: 14.5, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            ),
            child: const Text('HỦY', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deleteRed,
              foregroundColor: AppColors.pureWhite,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _tasks.removeWhere((t) => t.isCompleted);
              });
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã dọn dẹp $completedCount công việc đã hoàn thành!'),
                  backgroundColor: AppColors.deepNavy,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('XÓA HẾT', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  /// Lọc danh sách theo Tab đang chọn & Từ khóa tìm kiếm (FR-03 & FR-04)
  List<TodoItem> get _filteredTasks {
    List<TodoItem> list;
    switch (_currentFilter) {
      case TaskFilter.incomplete:
        list = _tasks.where((t) => !t.isCompleted).toList();
        break;
      case TaskFilter.completed:
        list = _tasks.where((t) => t.isCompleted).toList();
        break;
      case TaskFilter.all:
        list = _tasks;
        break;
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((t) => t.title.toLowerCase().contains(q) || t.content.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  /// Màu sắc theo Mức độ ưu tiên (FR-06 & Taste Layer - Soft Pastels)
  static Color _getTypeTextColor(String type) {
    switch (type) {
      case 'Dễ':
        return AppColors.priorityEasyText;
      case 'Trung bình':
        return AppColors.priorityMediumText;
      case 'Khó':
        return AppColors.priorityHardText;
      default:
        return AppColors.primaryBlue;
    }
  }

  static Color _getTypeBgColor(String type) {
    switch (type) {
      case 'Dễ':
        return AppColors.priorityEasyBg;
      case 'Trung bình':
        return AppColors.priorityMediumBg;
      case 'Khó':
        return AppColors.priorityHardBg;
      default:
        return AppColors.typeBadgeBg;
    }
  }

  /// Helper tạo InputDecoration mềm mại, tinh tế, không gắt (NFR-03 & Taste Layer)
  static InputDecoration _inputDecoration({
    required String label,
    required String hint,
    Widget? suffixIcon,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: AppColors.deepNavy,
        fontWeight: FontWeight.w600,
        fontSize: 14.0,
      ),
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13.0),
      filled: true,
      fillColor: AppColors.iceBlueTint.withValues(alpha: 0.28),
      contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 13.0),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide(color: AppColors.softSky.withValues(alpha: 0.35)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide(color: AppColors.softSky.withValues(alpha: 0.35)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: const BorderSide(color: AppColors.deleteRed, width: 1.2),
      ),
    );
  }

  // ==========================================================================
  // 5. UI COMPONENTS BUILDERS (Soft Modern Aesthetic)
  // ==========================================================================

  /// Component 1: Thẻ tóm tắt tiến độ (Progress Summary Card - FR-02 & Soft Ocean Ambient)
  Widget _buildProgressCard(int total, int completed) {
    final double progress = total > 0 ? (completed / total) : 0.0;
    final int percent = (progress * 100).round();

    return Container(
      margin: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 10.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.oceanHeaderGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.25),
            blurRadius: 20.0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: Stack(
          children: [
            // Ambient glowing circles tạo độ mềm mại, chiều sâu hữu cơ
            Positioned(
              right: -24,
              top: -24,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.pureWhite.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -40,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.vibrantOcean.withValues(alpha: 0.15),
                ),
              ),
            ),

            // Nội dung chính
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 7.0,
                                height: 7.0,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.vibrantOcean,
                                ),
                              ),
                              const SizedBox(width: 6.0),
                              const Text(
                                'TIẾN ĐỘ CÔNG VIỆC',
                                style: TextStyle(
                                  color: AppColors.iceBlueTint,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6.0),
                          Text(
                            '$completed / $total việc hoàn thành',
                            style: const TextStyle(
                              color: AppColors.pureWhite,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color: AppColors.pureWhite.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: AppColors.pureWhite.withValues(alpha: 0.25),
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          '$percent%',
                          style: const TextStyle(
                            color: AppColors.pureWhite,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  // Thanh tiến độ bo tròn hoàn toàn
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8.0,
                      backgroundColor: AppColors.pureWhite.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.vibrantOcean),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Component 2: Form nhập công việc mới (Soft Card Surface - Khắc phục cảm giác khô khan)
  Widget _buildAddTaskForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C03045E),
            blurRadius: 20.0,
            offset: Offset(0, 6),
          ),
          BoxShadow(
            color: Color(0x0403045E),
            blurRadius: 6.0,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header tiêu đề Form mềm mại
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7.0),
                  decoration: BoxDecoration(
                    color: AppColors.iceBlueTint.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Icon(Icons.add_task_rounded, color: AppColors.primaryBlue, size: 18.0),
                ),
                const SizedBox(width: 10.0),
                const Text(
                  'Tạo công việc mới',
                  style: TextStyle(
                    color: AppColors.deepNavy,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Field 1: Tiêu đề
            TextFormField(
              controller: _titleController,
              focusNode: _titleFocusNode,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tiêu đề công việc!';
                }
                return null;
              },
              style: const TextStyle(color: AppColors.deepNavy, fontSize: 14.5, fontWeight: FontWeight.w500),
              decoration: _inputDecoration(
                label: 'Tiêu đề',
                hint: 'Nhập tên công việc...',
              ),
            ),
            const SizedBox(height: 12.0),

            // Field 2: Nội dung
            TextFormField(
              controller: _contentController,
              style: const TextStyle(color: AppColors.deepNavy, fontSize: 14.5),
              decoration: _inputDecoration(
                label: 'Nội dung',
                hint: 'Nhập mô tả chi tiết công việc...',
              ),
            ),
            const SizedBox(height: 12.0),

            // Row 2 cột: Ngày thực hiện & Mức độ (Không viền cứng, không tràn pixel)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Field 3: Ngày thực hiện
                Expanded(
                  child: TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                        locale: const Locale('vi', 'VN'),
                        helpText: 'CHỌN NGÀY THỰC HIỆN',
                        cancelText: 'HỦY',
                        confirmText: 'XÁC NHẬN',
                      );
                      if (picked != null) {
                        setState(() {
                          _dateController.text = _formatDate(picked);
                        });
                      }
                    },
                    style: const TextStyle(color: AppColors.deepNavy, fontSize: 14.0),
                    decoration: _inputDecoration(
                      label: 'Ngày thực hiện',
                      hint: 'dd/MM/yyyy',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                      suffixIcon: const Icon(
                        Icons.calendar_today_rounded,
                        size: 18.0,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),

                // Field 4: Mức độ
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedType,
                    items: _typeOptions
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(
                                t,
                                style: const TextStyle(fontSize: 14.0),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedType = val);
                      }
                    },
                    decoration: _inputDecoration(
                      label: 'Mức độ',
                      hint: 'Chọn mức độ',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18.0),

            // Nút Thêm công việc bo tròn mềm mại kết hợp Gradient
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.buttonGradient,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.28),
                    blurRadius: 14.0,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _addTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: AppColors.pureWhite,
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline_rounded, size: 20.0),
                    SizedBox(width: 8.0),
                    Text(
                      'THÊM CÔNG VIỆC',
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Component 3: Thanh tìm kiếm mềm mại (FR-04 - Soft Capsule Search Bar)
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 8.0),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(18.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0803045E),
            blurRadius: 12.0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
          });
        },
        style: const TextStyle(fontSize: 14.0, color: AppColors.deepNavy),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm công việc theo từ khóa...',
          hintStyle: const TextStyle(fontSize: 13.0, color: AppColors.textMuted),
          prefixIcon: const Icon(Icons.search_rounded, size: 20.0, color: AppColors.primaryBlue),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18.0, color: AppColors.textMuted),
                  tooltip: 'Xóa tìm kiếm',
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 13.0),
        ),
      ),
    );
  }

  /// Component 4: Bộ lọc trạng thái (FR-03 - Soft Pill Segmented Filter)
  Widget _buildFilterChips(int total, int incomplete, int completed) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: AppColors.iceBlueTint.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        children: TaskFilter.values.map((filter) {
          final bool isSelected = _currentFilter == filter;
          int count = total;
          if (filter == TaskFilter.incomplete) count = incomplete;
          if (filter == TaskFilter.completed) count = completed;

          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _currentFilter = filter;
                  });
                },
                borderRadius: BorderRadius.circular(16.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 9.0),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.pureWhite : Colors.transparent,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.deepNavy.withValues(alpha: 0.08),
                              blurRadius: 10.0,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        filter.label,
                        style: TextStyle(
                          color: isSelected ? AppColors.primaryBlue : AppColors.textMuted,
                          fontSize: 13.0,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6.0),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryBlue
                              : AppColors.pureWhite.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            color: isSelected ? AppColors.pureWhite : AppColors.textMuted,
                            fontSize: 11.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Component 5: Thẻ Task Item (FR-01, FR-06 & Taste Layer - Vòng tròn Checkbox & Soft Floating Card)
  Widget _buildTaskItem(TodoItem task) {
    final bool isDone = task.isCompleted;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: isDone
            ? AppColors.pureWhite.withValues(alpha: 0.75)
            : AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: isDone
              ? AppColors.softSky.withValues(alpha: 0.3)
              : AppColors.pureWhite,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDone
                ? const Color(0x0503045E)
                : const Color(0x0C03045E),
            blurRadius: isDone ? 8.0 : 16.0,
            offset: Offset(0, isDone ? 2 : 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 12.0, 14.0, 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bên trái: Checkbox tròn mềm mại (Circular Checkbox - Khắc phục cảm giác cứng nhắc)
            IconButton(
              icon: Icon(
                isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                color: isDone ? AppColors.vibrantOcean : AppColors.softSky,
                size: 26.0,
              ),
              tooltip: isDone ? 'Đánh dấu chưa xong' : 'Đánh dấu hoàn thành',
              onPressed: () => _toggleTask(task.id),
            ),

            // Ở giữa: Tiêu đề, nội dung, mức độ
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row Tiêu đề & Nhãn mức độ
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDone ? AppColors.deepNavy.withValues(alpha: 0.4) : AppColors.deepNavy,
                              fontSize: 16.0,
                              fontWeight: isDone ? FontWeight.w400 : FontWeight.w700,
                              decoration: isDone ? TextDecoration.lineThrough : null,
                              decorationColor: AppColors.deepNavy.withValues(alpha: 0.4),
                              fontStyle: isDone ? FontStyle.italic : FontStyle.normal,
                              height: 1.3,
                            ),
                          ),
                        ),
                        // Badge Mức độ ưu tiên mềm mại dạng Capsule
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 3.0),
                          decoration: BoxDecoration(
                            color: _getTypeBgColor(task.type),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            task.type,
                            style: TextStyle(
                              color: _getTypeTextColor(task.type),
                              fontSize: 11.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Nội dung chi tiết nếu có
                    if (task.content.isNotEmpty) ...[
                      const SizedBox(height: 4.0),
                      Text(
                        task.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDone ? AppColors.textMuted.withValues(alpha: 0.5) : AppColors.textMuted,
                          fontSize: 13.5,
                          fontStyle: FontStyle.italic,
                          height: 1.3,
                        ),
                      ),
                    ],

                    const SizedBox(height: 8.0),

                    // Dòng dưới: Ngày thực hiện & Các nút thao tác
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Ngày thực hiện
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 13.0,
                              color: AppColors.textMuted.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 5.0),
                            Text(
                              task.date,
                              style: TextStyle(
                                color: AppColors.textMuted.withValues(alpha: 0.85),
                                fontSize: 12.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        // Các nút hành động: Sửa & Xóa bo tròn mềm mại
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Nút Sửa
                            Tooltip(
                              message: 'Chỉnh sửa công việc',
                              child: InkWell(
                                onTap: () => _editTask(task),
                                borderRadius: BorderRadius.circular(20.0),
                                child: Container(
                                  padding: const EdgeInsets.all(7.0),
                                  decoration: BoxDecoration(
                                    color: AppColors.editGreen.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit_rounded,
                                    size: 16.0,
                                    color: AppColors.editGreen,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8.0),

                            // Nút Xóa
                            Tooltip(
                              message: 'Xóa công việc',
                              child: InkWell(
                                onTap: () => _deleteTask(task),
                                borderRadius: BorderRadius.circular(20.0),
                                child: Container(
                                  padding: const EdgeInsets.all(7.0),
                                  decoration: BoxDecoration(
                                    color: AppColors.deleteRed.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 16.0,
                                    color: AppColors.deleteRed,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Component 6: Trạng thái trống (Empty State - Soft & Warm)
  Widget _buildEmptyState() {
    final bool isSearching = _searchQuery.trim().isNotEmpty;
    final bool isFiltered = _currentFilter != TaskFilter.all;

    String title;
    String subtitle;
    if (isSearching) {
      title = 'Không tìm thấy kết quả phù hợp';
      subtitle = 'Không có công việc nào khớp với từ khóa "$_searchQuery".';
    } else if (isFiltered) {
      title = 'Không có công việc nào trong mục "${_currentFilter.label}"';
      subtitle = 'Hãy chuyển sang bộ lọc khác hoặc thêm công việc mới.';
    } else {
      title = 'Chưa có công việc nào!';
      subtitle = 'Hãy tạo công việc mới bằng biểu mẫu phía trên nhé ✨';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 84.0,
            height: 84.0,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  AppColors.iceBlueTint.withValues(alpha: 0.8),
                  AppColors.iceBlueTint.withValues(alpha: 0.2),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSearching ? Icons.search_off_rounded : Icons.spa_rounded,
              size: 44.0,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 18.0),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.deepNavy,
              fontSize: 17.0,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 6. MAIN BUILD METHOD
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    final int totalCount = _tasks.length;
    final int completedCount = _tasks.where((t) => t.isCompleted).length;
    final int incompleteCount = totalCount - completedCount;
    final List<TodoItem> filteredList = _filteredTasks;

    // Quality Gate: Bọc GestureDetector để chạm bên ngoài tự ẩn bàn phím (NFR-03)
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: const Text(
            'TODOLIST',
            style: TextStyle(
              color: AppColors.deepNavy,
              fontSize: 22.0,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          actions: [
            // Nút Dọn dẹp việc đã xong (FR-05)
            if (completedCount > 0)
              IconButton(
                icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.deleteRed),
                tooltip: 'Dọn dẹp việc đã xong',
                onPressed: _clearCompletedTasks,
              ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 5.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.iceBlueTint.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: Text(
                    '${filteredList.length} việc',
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        // Quality Gate: SafeArea tránh notch và phím điều hướng hệ thống (NFR-03)
        body: SafeArea(
          // Quality Gate: CustomScrollView tránh RenderFlex overflow khi mở bàn phím (NFR-03)
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // 1. Thẻ thống kê tiến độ công việc (FR-02 & Soft Ocean Ambient)
              SliverToBoxAdapter(
                child: _buildProgressCard(totalCount, completedCount),
              ),
              // 2. Khu vực Form nhập liệu (FR-01, NFR-03 - Soft Card)
              SliverToBoxAdapter(
                child: _buildAddTaskForm(),
              ),
              // 3. Thanh tìm kiếm theo từ khóa (FR-04 - Soft Capsule)
              SliverToBoxAdapter(
                child: _buildSearchBar(),
              ),
              // 4. Thanh lọc trạng thái công việc (FR-03 - Soft Pill Segmented)
              SliverToBoxAdapter(
                child: _buildFilterChips(
                  totalCount,
                  incompleteCount,
                  completedCount,
                ),
              ),
              // 5. Danh sách công việc hoặc Trạng thái trống
              if (filteredList.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 28.0, top: 6.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildTaskItem(filteredList[index]),
                      childCount: filteredList.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
