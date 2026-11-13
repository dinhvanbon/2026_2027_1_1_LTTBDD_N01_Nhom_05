import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/task_provider.dart';
import '../../providers/reward_provider.dart';
import '../../providers/achievement_provider.dart';
import '../shared/achievement_screen.dart';
import '../shared/settings_screen.dart';
import '../shared/edit_profile_screen.dart';
import '../../services/user_service.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

import '../../providers/language_provider.dart';
class ChildProfileScreen extends StatelessWidget {
  const ChildProfileScreen({super.key});

  Widget topButton(String text, VoidCallback onTap) {
    return SizedBox(
      width: 44,
      height: 44,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: EdgeInsets.zero,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(text, style: const TextStyle(fontSize: 20)),
      ),
    );
  }

  Widget statCard({
    required String icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xfff4e6d2)),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withValues(alpha: 0.08),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xff2d243b),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xff8b7c99),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(
    String title, {
    String? action,
    VoidCallback? onActionTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xff2d243b),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (action != null)
            InkWell(
              onTap: onActionTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text(
                  action,
                  style: const TextStyle(
                    color: Color(0xffff8a00),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget infoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xfff5eee4))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xff8b7c99))),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xff2d243b),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget achievementCard({
    required String icon,
    required String title,
    required String subtitle,
    required String status,
    required double progress,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xfffff7e8),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xfff4e6d2)),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xfffff0cf),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 30)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xff8b7c99),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: const Color(0xfffff0cf),
                    color: const Color(0xffff9f43),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xffe7ffe9),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              status,
              style: const TextStyle(
                color: Color(0xff1c9b43),
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget settingCard({
    required String icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(26),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: const Color(0xfff4e6d2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.08),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xfffff0cf),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(icon, style: const TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xff8b7c99),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  '›',
                  style: TextStyle(
                    color: Color(0xffaaa0b5),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final rewardProvider = context.watch<RewardProvider>();
    final achievementProvider = context.watch<AchievementProvider>();

    if (achievementProvider.achievements.isEmpty) {
      Future.microtask(() {
        if (context.mounted) {
          context.read<AchievementProvider>().initAchievements();
        }
      });
    }

    final unlockedAchievements = achievementProvider.achievements
        .where((achievement) => achievement.unlocked)
        .length;

    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return FutureBuilder<Map<String, dynamic>?>(
      key: ValueKey(currentUid),
      future: UserService().getCurrentChildProfile(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data!;

        final username = user['username'] ?? 'Hero';

        final email = user['email'] ?? '';

        final phone = user['phone'] ?? '';

        final linkCode = user['linkCode'] ?? tr('Chưa có', 'None yet');

        final isLinked = (user['parentId'] ?? '').toString().isNotEmpty;

        final exp = user['exp'] ?? 0;
        final level = user['level'] ?? 1;
        final maxExp = level * 100;
        final expProgress = maxExp == 0 ? 0.0 : exp / maxExp;

        final avatar = user['avatar'] as String?;

        return Scaffold(
          backgroundColor: const Color(0xfffffdf8),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      topButton('←', () => Navigator.maybePop(context)),
                      Column(
                        children: [
                          Text(
                            'Child Profile',
                            style: TextStyle(
                              fontSize: 22,
                              color: Color(0xff2d243b),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            tr('Hồ sơ người chơi', 'Player profile'),
                            style: TextStyle(
                              color: Color(0xff8b7c99),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      topButton('⚙️', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xffff9f43), Color(0xffff6b81)],
                      ),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: Colors.white.withValues(alpha: 0.25),
                          backgroundImage: avatar == null || avatar.isEmpty
                              ? null
                              : MemoryImage(base64Decode(avatar)),
                          child: avatar == null || avatar.isEmpty
                              ? const Text('🧒', style: TextStyle(fontSize: 54))
                              : null,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          tr('Young Hero\nHoàn thành nhiệm vụ để nhận EXP và mở khóa huy hiệu', 'Young Hero\nComplete quests to earn EXP and unlock badges'),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, height: 1.5),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _levelBadge('LV $level'),
                            _levelBadge('🔥 4 Day Streak'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xfff4e6d2)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'EXP Progress',
                              style: TextStyle(
                                color: Color(0xff2d243b),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${(expProgress * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Color(0xffff8a00),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: expProgress.clamp(0, 1),
                            minHeight: 12,
                            backgroundColor: const Color(0xfffff0cf),
                            color: const Color(0xffff9f43),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$exp / $maxExp EXP',
                          style: const TextStyle(
                            color: Color(0xff8b7c99),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      statCard(
                        icon: '📋',
                        value: '${taskProvider.tasks.length}',
                        label: tr('Nhiệm vụ', 'Quests'),
                      ),
                      const SizedBox(width: 12),
                      statCard(
                        icon: '🏆',
                        value: '$unlockedAchievements',
                        label: tr('Huy hiệu', 'Badges'),
                      ),
                      const SizedBox(width: 12),
                      statCard(
                        icon: '⭐',
                        value: '${rewardProvider.coins}',
                        label: tr('Vàng', 'Gold'),
                      ),
                    ],
                  ),
                  sectionTitle(
                    tr('Thành tựu nổi bật', 'Featured achievements'),
                    action: tr('Xem tất cả', 'View all'),
                    onActionTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AchievementScreen(),
                        ),
                      );
                    },
                  ),
                  achievementCard(
                    icon: '📚',
                    title: tr('Hiệp sĩ học tập', 'Study Knight'),
                    subtitle: tr('Hoàn thành 10 nhiệm vụ học tập', 'Complete 10 study quests'),
                    status: '8/10',
                    progress: 0.8,
                  ),
                  achievementCard(
                    icon: '🧹',
                    title: tr('Bậc thầy gọn gàng', 'Tidy Master'),
                    subtitle: tr('Hoàn thành 5 nhiệm vụ dọn dẹp', 'Complete 5 cleaning quests'),
                    status: tr('HOÀN THÀNH', 'COMPLETED'),
                    progress: 1,
                  ),
                  sectionTitle(tr('Thông tin cá nhân', 'Personal information')),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: const Color(0xfff4e6d2)),
                    ),
                    child: Column(
                      children: [
                        infoRow('Email', email),
                        infoRow(tr('Số điện thoại', 'Phone number'), phone),
                        infoRow(tr('Vai trò', 'Role'), tr('Con cái', 'Children')),
                        infoRow(tr('Mã liên kết', 'Link code'), linkCode),
                        infoRow(
                          tr('Trạng thái', 'Status'),
                          isLinked ? tr('Đã liên kết', 'Linked') : tr('Chưa liên kết', 'Not linked'),
                        ),
                        infoRow('Tham gia', tr('Học kỳ I 2026', 'Semester I 2026')),
                      ],
                    ),
                  ),
                  sectionTitle(tr('Cài đặt', 'Settings')),
                  settingCard(
                    icon: '🔔',
                    title: tr('Nhắc nhở nhiệm vụ', 'Quest reminders'),
                    subtitle: context.watch<LanguageProvider>().notificationsEnabled
                        ? tr(
                            'Đang bật • Nhấn để tắt nhắc nhở hằng ngày',
                            'ON • Tap to disable daily reminders',
                          )
                        : tr(
                            'Đang tắt • Nhấn để bật nhắc nhở hằng ngày',
                            'OFF • Tap to enable daily reminders',
                          ),
                    onTap: () {
                      final lang = context.read<LanguageProvider>();
                      lang.toggleNotifications();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            lang.notificationsEnabled
                                ? tr(
                                    'Đã bật nhắc nhở nhiệm vụ hằng ngày',
                                    'Daily quest reminders enabled',
                                  )
                                : tr(
                                    'Đã tắt nhắc nhở nhiệm vụ hằng ngày',
                                    'Daily quest reminders disabled',
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                  settingCard(
                    icon: '🎨',
                    title: tr('Hình đại diện & Nhân vật', 'Avatar & Character'),
                    subtitle: tr(
                      'Đổi nhân vật và giao diện',
                      'Change character and theme',
                    ),
                    onTap: () async {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfileScreen(
                            username: username,
                            phone: phone,
                            role: 'child',
                            accentColorHex: 'orange',
                          ),
                        ),
                      );
                      if (updated == true && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              tr(
                                'Cập nhật thông tin thành công',
                                'Profile updated successfully',
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  FilledButton(
                    onPressed: () async {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfileScreen(
                            username: username,
                            phone: phone,
                            role: 'child',
                            accentColorHex: 'orange',
                          ),
                        ),
                      );

                      if (updated == true && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(tr('Cập nhật thông tin thành công', 'Profile updated successfully')),
                          ),
                        );
                      }
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      backgroundColor: const Color(0xffff9f43),
                    ),
                    child: Text(tr('Chỉnh sửa thông tin', 'Edit profile')),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () async {
                      await AuthService().logout();

                      if (!context.mounted) return;

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      foregroundColor: const Color(0xffd94343),
                      backgroundColor: const Color(0xfffff0f0),
                      side: const BorderSide(color: Color(0xffffd4d4)),
                    ),
                    child: Text(tr('Đăng xuất', 'Log out')),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _levelBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 13,
        ),
      ),
    );
  }
}
