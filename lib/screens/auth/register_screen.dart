import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/language_provider.dart';
import '../../providers/task_provider.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../child/child_main_navigation_screen.dart';
import '../parent/parent_main_navigation_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _authService = AuthService();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedRole;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final lang = context.read<LanguageProvider>();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final username = _usernameController.text.trim();
    final phone = _phoneController.text.trim();

    if (username.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage(
        lang.tr(
          'Vui lòng nhập đầy đủ thông tin',
          'Please fill in all required fields',
        ),
      );
      return;
    }

    if (_selectedRole == null) {
      _showMessage(
        lang.tr(
          'Vui lòng chọn vai trò Phụ huynh hoặc Trẻ em',
          'Please select Parent or Child role',
        ),
      );
      return;
    }

    if (password.length < 6) {
      _showMessage(
        lang.tr(
          'Mật khẩu phải có ít nhất 6 ký tự',
          'Password must be at least 6 characters',
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      _showMessage(
        lang.tr(
          'Mật khẩu xác nhận không khớp',
          'Confirm password does not match',
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.registerWithEmail(email: email, password: password);
      await UserService().createUserProfile(username: username, phone: phone);
      await UserService().saveUserRoleIfNotExists(_selectedRole!);

      if (_selectedRole == 'child') {
        await UserService().ensureChildDocumentExists();
      }

      if (!mounted) return;

      context.read<TaskProvider>().listenToTasks();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => _selectedRole == 'parent'
              ? const ParentMainNavigationScreen()
              : const ChildMainNavigationScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      _showMessage(_getFirebaseErrorMessage(e.code));
    } catch (_) {
      _showMessage(
        lang.tr(
          'Đăng ký thất bại. Vui lòng thử lại.',
          'Registration failed. Please try again.',
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return tr('Email không hợp lệ', 'Invalid email');
      case 'email-already-in-use':
        return tr('Email này đã được sử dụng', 'Email already in use');
      case 'weak-password':
        return tr('Mật khẩu quá yếu', 'Weak password');
      default:
        return tr('Đăng ký thất bại: $code', 'Registration failed: $code');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _topButton({required IconData icon, required VoidCallback onTap}) {
    return SizedBox(
      width: 44,
      height: 44,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: EdgeInsets.zero,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xff2d243b),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Icon(icon, size: 22),
      ),
    );
  }

  Widget _inputField({
    required String label,
    required String icon,
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xff2d243b),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xfffaf7ff),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xffeee3fb)),
            ),
            child: Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    obscureText: obscureText,
                    decoration: InputDecoration(
                      hintText: hintText,
                      border: InputBorder.none,
                      hintStyle: const TextStyle(
                        color: Color(0xff8b7c99),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                ?suffixIcon,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleOption({
    required String role,
    required String icon,
    required String title,
    required String subtitle,
    required Color activeColor,
  }) {
    final isSelected = _selectedRole == role;

    return Expanded(
      child: GestureDetector(
        onTap: _isLoading ? null : () => setState(() => _selectedRole = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: 0.10)
                : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? activeColor : const Color(0xffeee3fb),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xff2d243b),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xff8b7c99),
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>();
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: const Color(0xfffffaff),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _topButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                  ),
                  ActionChip(
                    avatar: Text(lang.isEnglish ? '🇬🇧' : '🇻🇳'),
                    label: Text(
                      lang.isEnglish ? 'English' : 'Tiếng Việt',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Colors.white,
                    onPressed: () => lang.toggleLanguage(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Life RPG',
                style: TextStyle(
                  color: Color(0xff2d243b),
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                lang.tr(
                  'Đăng ký tài khoản để bắt đầu\nquản lý nhiệm vụ trẻ em',
                  'Register an account to start\ngamified task management',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xff8b7c99),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: const Color(0xfff0e7fb)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.tr('Tạo tài khoản', 'Create Account'),
                      style: const TextStyle(
                        color: Color(0xff2d243b),
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _inputField(
                      label: lang.tr('Tên người dùng', 'Username'),
                      icon: '👤',
                      controller: _usernameController,
                      hintText: lang.tr('Nhập họ tên', 'Enter full name'),
                    ),
                    _inputField(
                      label: lang.tr('Số điện thoại', 'Phone Number'),
                      icon: '📱',
                      controller: _phoneController,
                      hintText: lang.tr(
                        'Nhập số điện thoại',
                        'Enter phone number',
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    _inputField(
                      label: 'Email',
                      icon: '📧',
                      controller: _emailController,
                      hintText: lang.tr('Nhập email', 'Enter email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _inputField(
                      label: lang.tr('Mật khẩu', 'Password'),
                      icon: '🔒',
                      controller: _passwordController,
                      hintText: lang.tr('Nhập mật khẩu', 'Enter password'),
                      obscureText: !_isPasswordVisible,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: const Color(0xff8b7c99),
                        ),
                      ),
                    ),
                    _inputField(
                      label: lang.tr('Xác nhận mật khẩu', 'Confirm Password'),
                      icon: '🔐',
                      controller: _confirmPasswordController,
                      hintText: lang.tr(
                        'Nhập lại mật khẩu',
                        'Re-enter password',
                      ),
                      obscureText: !_isConfirmPasswordVisible,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          });
                        },
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: const Color(0xff8b7c99),
                        ),
                      ),
                    ),
                    Text(
                      lang.tr('Đăng ký với vai trò', 'Select Role'),
                      style: const TextStyle(
                        color: Color(0xff2d243b),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _roleOption(
                          role: 'parent',
                          icon: '👨‍👧',
                          title: lang.tr('Phụ huynh', 'Parent'),
                          subtitle: lang.tr(
                            'Giao việc, duyệt & thưởng',
                            'Assign, verify & reward',
                          ),
                          activeColor: const Color(0xff7048ff),
                        ),
                        const SizedBox(width: 12),
                        _roleOption(
                          role: 'child',
                          icon: '🧒',
                          title: lang.tr('Trẻ em', 'Child'),
                          subtitle: lang.tr(
                            'Làm việc, nhận EXP & quà',
                            'Complete quests & level up',
                          ),
                          activeColor: const Color(0xffff9f43),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _register,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xff7048ff),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: Text(
                          lang.tr('ĐĂNG KÝ TÀI KHOẢN', 'REGISTER ACCOUNT'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              TextButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                child: Text(
                  lang.tr(
                    'Đã có tài khoản? Đăng nhập',
                    'Already have an account? Sign In',
                  ),
                  style: const TextStyle(
                    color: Color(0xff7048ff),
                    fontWeight: FontWeight.w900,
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
