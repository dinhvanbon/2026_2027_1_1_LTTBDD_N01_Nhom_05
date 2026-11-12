import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/language_provider.dart';
import '../../providers/task_provider.dart';
import '../shared/activity_log_screen.dart';
import '../shared/group_info_screen.dart';
import 'create_task_screen.dart';
import 'parent_dashboard_screen.dart';
import 'parent_profile_screen.dart';
import 'verify_task_screen.dart';

class ParentMainNavigationScreen extends StatefulWidget {
  const ParentMainNavigationScreen({super.key});

  @override
  State<ParentMainNavigationScreen> createState() =>
      _ParentMainNavigationScreenState();
}

class _ParentMainNavigationScreenState
    extends State<ParentMainNavigationScreen> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;
      context.read<TaskProvider>().listenToTasks();
    });
  }

  final screens = const [
    ParentDashboardScreen(),
    CreateTaskScreen(),
    VerifyTaskScreen(),
    ActivityLogScreen(),
    ParentProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(44),
        child: Container(
          color: const Color(0xfff5f0ff),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const GroupInfoScreen(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.groups,
                          size: 18,
                          color: Color(0xff7048ff),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          lang.tr(
                            'Nhóm 05 - Đinh Văn Bốn',
                            'Group 05 - Dinh Van Bon',
                          ),
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xff2d243b),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => lang.toggleLanguage(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xffd8c7ff)),
                    ),
                    child: Text(
                      lang.isEnglish ? '🇬🇧 English' : '🇻🇳 Tiếng Việt',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff7048ff),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: lang.tr('Tổng quan', 'Dashboard'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.add_task_outlined),
            selectedIcon: const Icon(Icons.add_task),
            label: lang.tr('Tạo việc', 'Create'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.verified_outlined),
            selectedIcon: const Icon(Icons.verified),
            label: lang.tr('Duyệt việc', 'Verify'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history),
            label: lang.tr('Nhật ký', 'Activity'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: lang.tr('Cá nhân', 'Profile'),
          ),
        ],
      ),
    );
  }
}
