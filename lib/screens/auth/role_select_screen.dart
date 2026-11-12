import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/language_provider.dart';
import '../../services/user_service.dart';
import '../child/child_main_navigation_screen.dart';
import '../parent/parent_main_navigation_screen.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  Widget buildRoleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: color,
              child: Icon(icon, color: Colors.white, size: 42),
            ),
            const SizedBox(height: 26),
            Text(
              title,
              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void goToParent(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ParentMainNavigationScreen()),
    );
  }

  void goToChild(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ChildMainNavigationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return FutureBuilder<String?>(
      future: UserService().getCurrentUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final role = snapshot.data;

        if (role == 'parent') {
          Future.microtask(() {
            if (context.mounted) {
              goToParent(context);
            }
          });

          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (role == 'child') {
          Future.microtask(() {
            if (context.mounted) {
              goToChild(context);
            }
          });

          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xfffffaff),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Life RPG',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff1f1b24),
                        ),
                      ),
                      ActionChip(
                        avatar: Text(lang.isEnglish ? '🇬🇧' : '🇻🇳'),
                        label: Text(lang.isEnglish ? 'EN' : 'VI'),
                        onPressed: () => lang.toggleLanguage(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    lang.tr(
                      'Chọn vai trò để tiếp tục',
                      'Select your role to continue',
                    ),
                    style: const TextStyle(fontSize: 20, color: Colors.black54),
                  ),
                  const SizedBox(height: 40),
                  buildRoleCard(
                    title: lang.tr('Phụ huynh', 'Parent'),
                    subtitle: lang.tr(
                      'Quản lý nhiệm vụ và theo dõi tiến độ của trẻ',
                      'Manage tasks and track children progress',
                    ),
                    icon: Icons.admin_panel_settings,
                    color: Colors.deepPurple,
                    onTap: () async {
                      await UserService().saveUserRoleIfNotExists('parent');
                      if (!context.mounted) return;
                      goToParent(context);
                    },
                  ),
                  const SizedBox(height: 28),
                  buildRoleCard(
                    title: lang.tr('Con cái', 'Child'),
                    subtitle: lang.tr(
                      'Hoàn thành nhiệm vụ và nhận thưởng',
                      'Complete quests, earn EXP and rewards',
                    ),
                    icon: Icons.child_care,
                    color: Colors.orange,
                    onTap: () async {
                      await UserService().saveUserRoleIfNotExists('child');
                      if (!context.mounted) return;
                      goToChild(context);
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
