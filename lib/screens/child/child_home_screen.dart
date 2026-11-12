import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import 'child_reward_screen.dart';
import 'child_task_screen.dart';
import '../shared/achievement_screen.dart';
import '../shared/activity_log_screen.dart';
import '../shared/settings_screen.dart';

class ChildHomeScreen extends StatelessWidget {
  const ChildHomeScreen({super.key});

  String getTaskStatusLabel(Object status) {
    final value = status.toString().split('.').last;

    switch (value) {
      case 'submitted':
        return 'CHỜ DUYỆT';
      case 'approved':
        return 'HOÀN THÀNH';
      case 'rejected':
        return 'TỪ CHỐI';
      default:
        return 'CẦN LÀM';
    }
  }

  Color getTaskStatusColor(Object status) {
    final value = status.toString().split('.').last;

    switch (value) {
      case 'submitted':
        return Colors.blue;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.redAccent;
      default:
        return Colors.orange;
    }
  }

  Widget buildTaskCard({
    required BuildContext context,
    required TaskModel task,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFF0E7FB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.auto_stories, color: color, size: 28),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '+${task.expReward} EXP • ${task.rewardAmount} coins',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Chip(
            label: Text(getTaskStatusLabel(task.status)),
            backgroundColor: getTaskStatusColor(
              task.status,
            ).withValues(alpha: 0.14),
            labelStyle: TextStyle(
              color: getTaskStatusColor(task.status),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
            side: BorderSide.none,
          ),
        ],
      ),
    );
  }

  Widget buildSuggestionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFF0E7FB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (buttonText != null && onPressed != null) ...[
            const SizedBox(width: 10),
            FilledButton(onPressed: onPressed, child: Text(buttonText)),
          ],
        ],
      ),
    );
  }

  Widget buildQuickCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required Widget screen,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
        },
        child: Container(
          height: 142,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        height: 142,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>().tasks;

    return Scaffold(
      appBar: null,

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7048FF), Color(0xFFFFB347)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withValues(alpha: .18),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('⭐', style: TextStyle(fontSize: 30)),
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KidQuest',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF24183D),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Level Up Your Daily Habits',
                        style: TextStyle(
                          color: Color(0xFF8B7C99),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .06),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.notifications,
                      color: Color(0xFFFF9F43),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                final user = snapshot.data?.data();

                final username = user?['username']?.toString() ?? 'Little Hero';

                final avatar =
                    user?['avatar']?.toString() ??
                    user?['avatarBase64']?.toString();

                Widget avatarChild;

                if (avatar != null && avatar.isNotEmpty) {
                  final clean = avatar.contains(',')
                      ? avatar.split(',').last
                      : avatar;

                  avatarChild = ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: Image.memory(
                      base64Decode(clean),
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                    ),
                  );
                } else {
                  avatarChild = const Icon(
                    Icons.child_care,
                    color: Colors.white,
                    size: 38,
                  );
                }

                return Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: .12),
                        blurRadius: 24,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),

                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome back 👋',
                              style: TextStyle(
                                color: Color(0xffff8a00),
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'Hi, $username',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                              ),
                            ),

                            const SizedBox(height: 8),

                            const Text(
                              'Sẵn sàng hoàn thành nhiệm vụ hôm nay chưa?',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xffff9f43), Color(0xffff6b81)],
                          ),
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Center(child: avatarChild),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                final user = snapshot.data?.data();

                final level = (user?['level'] as num?)?.toInt() ?? 1;
                final exp = (user?['exp'] as num?)?.toInt() ?? 0;
                final coins = (user?['coins'] as num?)?.toInt() ?? 0;

                final maxExp = level * 100;
                final progress = maxExp == 0
                    ? 0.0
                    : (exp / maxExp).clamp(0.0, 1.0);

                return Column(
                  children: [
                    Row(
                      children: [
                        buildStatCard(
                          icon: Icons.task_alt,
                          value: tasks.length.toString(),
                          label: 'Nhiệm vụ',
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        buildStatCard(
                          icon: Icons.stars,
                          value: coins.toString(),
                          label: 'Vàng',
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        buildStatCard(
                          icon: Icons.local_fire_department,
                          value: '0',
                          label: 'Chuỗi ngày',
                          color: Colors.redAccent,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6A3ACB), Color(0xFFB022B8)],
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Level $level',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '$exp / $maxExp EXP',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 14,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Truy cập nhanh',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        buildQuickCard(
                          context: context,
                          icon: Icons.task_alt,
                          label: 'Nhiệm vụ',
                          color: Colors.blue,
                          screen: const ChildTaskScreen(),
                        ),
                        const SizedBox(width: 12),
                        buildQuickCard(
                          context: context,
                          icon: Icons.emoji_events,
                          label: 'Huy hiệu',
                          color: Colors.orange,
                          screen: const AchievementScreen(),
                        ),
                        const SizedBox(width: 12),
                        buildQuickCard(
                          context: context,
                          icon: Icons.card_giftcard,
                          label: 'Đổi quà',
                          color: Colors.purple,
                          screen: const ChildRewardScreen(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6A3ACB), Color(0xFFB022B8)],
                        ),
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ActivityLogScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.history),
                        label: const Text(
                          'Nhật ký hoạt động',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            const Text(
              'Nhiệm vụ hàng ngày',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChildTaskScreen()),
                );
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('Xem tất cả'),
            ),

            const SizedBox(height: 20),

            if (tasks.isEmpty)
              const Center(child: Text('Chưa có nhiệm vụ'))
            else
              Column(
                children: tasks.take(3).map((task) {
                  return buildTaskCard(
                    context: context,
                    task: task,
                    color: Colors.blue,
                  );
                }).toList(),
              ),

            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Thành tựu nổi bật',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AchievementScreen(),
                      ),
                    );
                  },
                  child: const Text('Tất cả'),
                ),
              ],
            ),

            buildSuggestionCard(
              icon: Icons.menu_book,
              title: 'Hiệp sĩ học tập',
              subtitle: 'Hoàn thành nhiệm vụ để mở khóa thêm thành tựu.',
              color: Colors.orange,
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Gợi ý đổi quà',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChildRewardScreen(),
                      ),
                    );
                  },
                  child: const Text('Cửa hàng'),
                ),
              ],
            ),

            buildSuggestionCard(
              icon: Icons.videogame_asset,
              title: 'Giờ chơi game',
              subtitle: 'Dùng vàng để đổi phần thưởng từ phụ huynh.',
              color: Colors.purple,
              buttonText: 'Đổi ngay',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChildRewardScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
