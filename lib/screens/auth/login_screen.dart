import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/language_provider.dart';
import '../../providers/task_provider.dart';

import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../child/child_main_navigation_screen.dart';
import '../parent/parent_main_navigation_screen.dart';
import '../shared/group_info_screen.dart';
import 'register_screen.dart';
import 'role_select_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final _userService = UserService();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final lang = context.read<LanguageProvider>();
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showMessage(
        lang.tr(
          'Vui lòng nhập đầy đủ email và mật khẩu',
          'Please enter both email and password',
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.loginWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );

      final role = await _userService.getCurrentUserRole();

      if (!mounted) return;

      if (role == 'parent') {
        context.read<TaskProvider>().listenToTasks();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ParentMainNavigationScreen()),
        );
      } else if (role == 'child') {
        await _userService.ensureChildDocumentExists();

        if (!mounted) return;

        context.read<TaskProvider>().listenToTasks();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ChildMainNavigationScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RoleSelectScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showMessage(_getFirebaseErrorMessage(e.code));
    } catch (_) {
      _showMessage(
        lang.tr(
          'Đăng nhập thất bại. Vui lòng thử lại.',
          'Login failed. Please try again.',
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
        return 'Email không hợp lệ / Invalid email';
      case 'user-not-found':
        return 'Tài khoản không tồn tại / User not found';
      case 'wrong-password':
        return 'Mật khẩu không đúng / Wrong password';
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không đúng / Invalid credentials';
      case 'too-many-requests':
        return 'Thử quá nhiều lần. Vui lòng thử lại sau.';
      default:
        return 'Đăng nhập thất bại: $code';
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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

  @override
  Widget build(BuildContext context) {
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
                  ActionChip(
                    avatar: const Icon(
                      Icons.groups,
                      size: 18,
                      color: Color(0xff7048ff),
                    ),
                    label: Text(
                      lang.tr('Nhóm 05', 'Group 05'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff2d243b),
                      ),
                    ),
                    backgroundColor: Colors.white,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GroupInfoScreen(),
                        ),
                      );
                    },
                  ),
                  ActionChip(
                    avatar: Text(lang.isEnglish ? '🇬🇧' : '🇻🇳'),
                    label: Text(
                      lang.isEnglish ? 'English' : 'Tiếng Việt',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff2d243b),
                      ),
                    ),
                    backgroundColor: Colors.white,
                    onPressed: () => lang.toggleLanguage(),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff7048ff), Color(0xffffb347)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff7048ff).withValues(alpha: 0.32),
                      blurRadius: 30,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('⭐', style: TextStyle(fontSize: 42)),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Life RPG',
                style: TextStyle(
                  color: Color(0xff2d243b),
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                lang.tr(
                  'Đăng nhập để tiếp tục\nhành trình nhiệm vụ của bạn',
                  'Sign in to continue\nyour gamified quest journey',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xff8b7c99),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: const Color(0xfff0e7fb)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff502d82).withValues(alpha: 0.10),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.tr('Đăng nhập', 'Sign In'),
                      style: const TextStyle(
                        color: Color(0xff2d243b),
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 22),
                    _inputField(
                      label: 'Email',
                      icon: '📧',
                      controller: _emailController,
                      hintText: lang.tr('Nhập email', 'Enter your email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _inputField(
                      label: lang.tr('Mật khẩu', 'Password'),
                      icon: '🔒',
                      controller: _passwordController,
                      hintText: lang.tr('Nhập mật khẩu', 'Enter your password'),
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
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _login,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xff7048ff),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                lang.tr('ĐĂNG NHẬP', 'SIGN IN'),
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
              const SizedBox(height: 22),
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                child: Text.rich(
                  TextSpan(
                    text: lang.tr(
                      'Chưa có tài khoản? ',
                      'Don\'t have an account? ',
                    ),
                    style: const TextStyle(
                      color: Color(0xff8b7c99),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    children: [
                      TextSpan(
                        text: lang.tr('Đăng ký ngay', 'Register now'),
                        style: const TextStyle(
                          color: Color(0xff7048ff),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
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
