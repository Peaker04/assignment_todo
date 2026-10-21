import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegisterMode = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillDemoAccount() {
    setState(() {
      _usernameController.text = 'admin';
      _passwordController.text = '123456';
    });
  }

  Future<void> _submit() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu'),
          backgroundColor: Color(0xFFFF3B30),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isRegisterMode) {
        final res = await AuthService.instance.register(username, password);
        if (!mounted) return;

        if (res.success) {
          widget.onLoginSuccess();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res.error ?? 'Đăng ký thất bại'),
              backgroundColor: const Color(0xFFFF3B30),
            ),
          );
        }
      } else {
        final res = await AuthService.instance.login(username, password);
        if (!mounted) return;

        if (res.success) {
          widget.onLoginSuccess();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res.error ?? 'Đăng nhập thất bại'),
              backgroundColor: const Color(0xFFFF3B30),
            ),
          );
        }
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể đăng nhập, vui lòng thử lại'),
          backgroundColor: Color(0xFFFF3B30),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const systemBackground = Color(0xFFF2F2F7);
    const systemBlue = Color(0xFF007AFF);
    const systemLabel = Color(0xFF000000);
    const systemSecondaryLabel = Color(0xFF3C3C43);
    const systemTertiary = Color(0xFF8E8E93);
    const inputBackground = Color(0xFFEFEFF4);

    return Scaffold(
      backgroundColor: systemBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 28,
                      offset: Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Color(0x05000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Apple HIG Icon Badge
                    Center(
                      child: Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: systemBlue,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33007AFF),
                              blurRadius: 16,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          CupertinoIcons.checkmark_alt,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'TaskFlow',
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w700,
                          color: systemLabel,
                          letterSpacing: -0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        _isRegisterMode
                            ? 'Đăng ký tài khoản mới'
                            : 'Quản lý công việc thông minh & hiệu quả',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: systemTertiary,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // iOS Sliding Segmented Control
                    Center(
                      child: CupertinoSlidingSegmentedControl<bool>(
                        groupValue: _isRegisterMode,
                        backgroundColor: inputBackground,
                        thumbColor: Colors.white,
                        children: const {
                          false: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            child: Text(
                              'Đăng nhập',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: systemLabel,
                              ),
                            ),
                          ),
                          true: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            child: Text(
                              'Đăng ký',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: systemLabel,
                              ),
                            ),
                          ),
                        },
                        onValueChanged: (val) {
                          if (val != null) {
                            setState(() => _isRegisterMode = val);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Username Input (iOS Inset Style)
                    const Text(
                      'Tên đăng nhập',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: systemSecondaryLabel,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 7),
                    TextField(
                      controller: _usernameController,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(fontSize: 15, color: systemLabel),
                      decoration: InputDecoration(
                        hintText: 'Nhập tên đăng nhập',
                        hintStyle: const TextStyle(color: systemTertiary, fontSize: 14.5),
                        prefixIcon: const Icon(CupertinoIcons.person, color: systemBlue, size: 20),
                        filled: true,
                        fillColor: inputBackground,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: const BorderSide(color: systemBlue, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password Input (iOS Inset Style)
                    const Text(
                      'Mật khẩu',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: systemSecondaryLabel,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 7),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      style: const TextStyle(fontSize: 15, color: systemLabel),
                      decoration: InputDecoration(
                        hintText: 'Nhập mật khẩu',
                        hintStyle: const TextStyle(color: systemTertiary, fontSize: 14.5),
                        prefixIcon: const Icon(CupertinoIcons.lock, color: systemBlue, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? CupertinoIcons.eye_slash
                                : CupertinoIcons.eye,
                            color: systemTertiary,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: inputBackground,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: const BorderSide(color: systemBlue, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Primary iOS Button (Apple System Blue)
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: systemBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isRegisterMode ? 'Đăng ký' : 'Đăng nhập',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                              ),
                            ),
                    ),
                    const SizedBox(height: 12),

                    // Fast Demo Account Button (iOS Tinted Style)
                    OutlinedButton.icon(
                      onPressed: _isLoading ? null : _fillDemoAccount,
                      icon: const Icon(CupertinoIcons.bolt_fill, color: systemBlue, size: 16),
                      label: const Text(
                        'Tài khoản mẫu (Test nhanh)',
                        style: TextStyle(
                          color: systemBlue,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: systemBlue.withAlpha(50), width: 1),
                        backgroundColor: const Color(0xFFF2F7FF),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Switch Mode Text Link (Preserves test finders)
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _isRegisterMode = !_isRegisterMode;
                          });
                        },
                        child: Text(
                          _isRegisterMode
                              ? 'Đã có tài khoản? Đăng nhập ngay'
                              : 'Chưa có tài khoản? Đăng ký ngay',
                          style: const TextStyle(
                            color: systemBlue,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
