import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/task_provider.dart';
import 'providers/child_provider.dart';
import 'providers/activity_provider.dart';
import 'providers/achievement_provider.dart';
import 'providers/reward_provider.dart';
import 'providers/language_provider.dart';

import 'services/user_service.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/role_select_screen.dart';
import 'screens/parent/parent_main_navigation_screen.dart';
import 'screens/child/child_main_navigation_screen.dart';
import 'providers/family_provider.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown,
  };
}

class LifeRPGApp extends StatelessWidget {
  const LifeRPGApp({super.key});

  Future<Widget> _getStartScreen() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return const LoginScreen();
      }

      final role = await UserService().getCurrentUserRole();

      if (role == 'parent') {
        return const ParentMainNavigationScreen();
      }

      if (role == 'child') {
        return const ChildMainNavigationScreen();
      }

      return const RoleSelectScreen();
    } catch (e) {
      debugPrint('Error getting start screen: $e');
      return const LoginScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ChildProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
        ChangeNotifierProvider(create: (_) => AchievementProvider()),
        ChangeNotifierProvider(create: (_) => RewardProvider()),
        ChangeNotifierProvider(create: (_) => FamilyProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Life RPG',
        scrollBehavior: AppScrollBehavior(),
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.deepPurple,
        ),
        builder: (context, child) {
          final Widget appContent = child ?? const SizedBox();

          return LayoutBuilder(
            builder: (context, constraints) {
              // Khi chạy trên máy tính hoặc Web màn hình rộng
              if (constraints.maxWidth > 520) {
                const double mobileWidth = 420.0;
                final double targetHeight = constraints.maxHeight > 900
                    ? 860.0
                    : (constraints.maxHeight - 32.0).clamp(
                        580.0,
                        constraints.maxHeight,
                      );

                return Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.2,
                      colors: [
                        Color(0xFF1E1B4B), // Tím than hiện đại
                        Color(0xFF0B0F19), // Nền tối công nghệ
                      ],
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: mobileWidth,
                      height: targetHeight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(36),
                        border: Border.all(
                          color: const Color(0xFF334155),
                          width: 3.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.55),
                            blurRadius: 35,
                            spreadRadius: 4,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: MediaQuery(
                          data: MediaQuery.of(
                            context,
                          ).copyWith(size: Size(mobileWidth, targetHeight)),
                          child: appContent,
                        ),
                      ),
                    ),
                  ),
                );
              }

              // Trên điện thoại thật hiển thị toàn màn hình tự nhiên
              return appContent;
            },
          );
        },
        home: FutureBuilder<Widget>(
          future: _getStartScreen(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return const LoginScreen();
            }

            return snapshot.data!;
          },
        ),
      ),
    );
  }
}