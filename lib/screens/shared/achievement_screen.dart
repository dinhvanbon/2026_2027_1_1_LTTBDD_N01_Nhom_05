import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../providers/achievement_provider.dart';

class AchievementScreen extends StatelessWidget {
  const AchievementScreen({super.key});

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
          border: Border.all(color: const Color(0xfff0e7fb)),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withValues(alpha: 0.08),
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
                fontSize: 20,
                color: Color(0xff2d243b),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xff8b7c99),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget chip(String text, {bool active = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: active ? const Color(0xff7048ff) : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active ? const Color(0xff7048ff) : const Color(0xffeee3fb),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active ? Colors.white : const Color(0xff7d708d),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget achievementCard({
    required String icon,
    required String title,
    required String description,
    required String status,
    required String reward,
    required double progress,
    bool unlocked = false,
    bool featured = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: featured ? const Color(0xfffff7e8) : Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: featured ? const Color(0xffffe0a9) : const Color(0xfff0e7fb),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: featured
                  ? const Color(0xfffff0cf)
                  : const Color(0xfff1e9ff),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Text(icon, style: const TextStyle(fontSize: 30)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xff2d243b),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xff8b7c99),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: const Color(0xffeee7f7),
                    color: const Color(0xff7048ff),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: unlocked
                      ? const Color(0xffe7ffe9)
                      : const Color(0xfff1edf5),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: unlocked
                        ? const Color(0xff1c9b43)
                        : const Color(0xff8b7c99),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                reward,
                style: const TextStyle(
                  color: Color(0xffff8a00),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Future.microtask(() {
        if (context.mounted) {
          context.read<AchievementProvider>().listenAchievementsForChild(
            user.uid,
          );
        }
      });
    }

    final achievements = context.watch<AchievementProvider>().achievements;
    final unlockedCount = achievements
        .where((achievement) => achievement.unlocked)
        .length;
    final totalCount = achievements.length;
    final lockedCount = totalCount - unlockedCount;
    final progress = totalCount == 0 ? 0.0 : unlockedCount / totalCount;

    return Scaffold(
      backgroundColor: const Color(0xfffffaff),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _topButton('←', () => Navigator.pop(context)),
                        const Column(
                          children: [
                            Text(
                              'Thành tựu',
                              style: TextStyle(
                                fontSize: 22,
                                color: Color(0xff2d243b),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Huy hiệu & thành tựu',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xff8b7c99),
                              ),
                            ),
                          ],
                        ),
                        _topButton('🔔', () {}),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xff7048ff), Color(0xff9d72ff)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xff7048ff,
                            ).withValues(alpha: 0.25),
                            blurRadius: 30,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Achievement Progress',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '$unlockedCount / $totalCount',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Bạn đã mở khóa $unlockedCount thành tựu. Tiếp tục hoàn thành nhiệm vụ để nhận thêm huy hiệu.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Overall',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${(progress * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: progress,
                            minHeight: 11,
                            backgroundColor: Colors.white38,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        statCard(
                          icon: '🏆',
                          value: '$unlockedCount',
                          label: 'Đã mở khóa',
                        ),
                        const SizedBox(width: 12),
                        statCard(
                          icon: '🔒',
                          value: '$lockedCount',
                          label: 'Chưa mở',
                        ),
                        const SizedBox(width: 12),
                        statCard(
                          icon: '⭐',
                          value: '${unlockedCount * 50}',
                          label: 'EXP Thưởng',
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xffeee3fb)),
                      ),
                      child: const Row(
                        children: [
                          Text('🔍', style: TextStyle(fontSize: 20)),
                          SizedBox(width: 10),
                          Text(
                            'Tìm achievement, badge, reward...',
                            style: TextStyle(
                              color: Color(0xff8b7c99),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          chip('All', active: true),
                          const SizedBox(width: 10),
                          chip('Unlocked'),
                          const SizedBox(width: 10),
                          chip('Locked'),
                          const SizedBox(width: 10),
                          chip('Study'),
                          const SizedBox(width: 10),
                          chip('Daily'),
                          const SizedBox(width: 10),
                          chip('Special'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Featured Badges',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xff2d243b),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Sort',
                          style: TextStyle(
                            color: Color(0xff7048ff),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (achievements.isEmpty)
                      const Text(
                        'Chưa có achievement',
                        style: TextStyle(color: Color(0xff8b7c99)),
                      )
                    else
                      Column(
                        children: achievements.map((achievement) {
                          final unlocked = achievement.unlocked;

                          return achievementCard(
                            icon: unlocked ? '🏆' : '🔒',
                            title: achievement.title,
                            description: achievement.description,
                            status: unlocked
                                ? 'DONE'
                                : 'LV ${achievement.requiredLevel}',
                            reward: '+50 EXP',
                            progress: unlocked ? 1 : 0,
                            unlocked: unlocked,
                            featured: unlocked,
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topButton(String text, VoidCallback onTap) {
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
}
