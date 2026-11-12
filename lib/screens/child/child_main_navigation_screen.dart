import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/language_provider.dart';
import '../../providers/task_provider.dart';
import '../shared/achievement_screen.dart';
import '../shared/group_info_screen.dart';
import 'child_home_screen.dart';
import 'child_profile_screen.dart';
import 'child_reward_screen.dart';
import 'child_task_screen.dart';

class ChildMainNavigationScreen extends StatefulWidget {
  const ChildMainNavigationScreen({super.key});

  @override
  State<ChildMainNavigationScreen> createState() =>
      _ChildMainNavigationScreenState();
}

class _ChildMainNavigationScreenState extends State<ChildMainNavigationScreen> {
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
    ChildHomeScreen(),
    ChildTaskScreen(),
    ChildRewardScreen(),
    AchievementScreen(),
    ChildProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(44),
        child: Container(
          color: const Color(0xfffff4e6),
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
                          color: Color(0xffd97706),
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
                      border: Border.all(color: const Color(0xfffcd34d)),
                    ),
                    child: Text(
                      lang.isEnglish ? '🇬🇧 English' : '🇻🇳 Tiếng Việt',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xffb45309),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: screens[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: lang.tr('Trang chủ', 'Home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.task_alt_outlined),
            selectedIcon: const Icon(Icons.task_alt),
            label: lang.tr('Nhiệm vụ', 'Quests'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.card_giftcard_outlined),
            selectedIcon: const Icon(Icons.card_giftcard),
            label: lang.tr('Đổi quà', 'Rewards'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.emoji_events_outlined),
            selectedIcon: const Icon(Icons.emoji_events),
            label: lang.tr('Thành tựu', 'Badges'),
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
