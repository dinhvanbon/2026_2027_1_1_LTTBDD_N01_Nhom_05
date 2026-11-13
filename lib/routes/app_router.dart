import 'package:flutter/material.dart';

import '../core/constants/app_routes.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/role_select_screen.dart';
import '../screens/child/child_main_navigation_screen.dart';
import '../screens/parent/parent_main_navigation_screen.dart';
import '../screens/shared/achievement_screen.dart';
import '../screens/shared/activity_log_screen.dart';
import '../screens/shared/group_info_screen.dart';
import '../screens/shared/leaderboard_screen.dart';
import '../screens/shared/settings_screen.dart';

/// Bộ điều hướng trung tâm (AppRouter) ánh xạ tên route tới các màn hình.
class AppRouter {
  AppRouter._();

  static Map<String, WidgetBuilder> get routes => {
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.roleSelect: (_) => const RoleSelectScreen(),
        AppRoutes.parentMain: (_) => const ParentMainNavigationScreen(),
        AppRoutes.childMain: (_) => const ChildMainNavigationScreen(),
        AppRoutes.achievements: (_) => const AchievementScreen(),
        AppRoutes.activityLog: (_) => const ActivityLogScreen(),
        AppRoutes.leaderboard: (_) => const LeaderboardScreen(),
        AppRoutes.settings: (_) => const SettingsScreen(),
        AppRoutes.groupInfo: (_) => const GroupInfoScreen(),
      };
}
