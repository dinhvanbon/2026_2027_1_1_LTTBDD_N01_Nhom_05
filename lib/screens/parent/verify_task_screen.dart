import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../providers/child_provider.dart';
import '../../providers/activity_provider.dart';
import '../../providers/achievement_provider.dart';
import '../../providers/reward_provider.dart';
import '../../providers/family_provider.dart';
import '../../services/task_service.dart';

import 'dart:convert';
import 'dart:typed_data';

class VerifyTaskScreen extends StatelessWidget {
  const VerifyTaskScreen({super.key});

  Uint8List? decodeProofImage(String? image) {
    if (image == null || image.isEmpty) {
      return null;
    }

    try {
      return base64Decode(image);
    } catch (_) {
      return null;
    }
  }

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

  Widget sectionTitle(String title, String actionText) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xff2d243b),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            actionText,
            style: const TextStyle(
              color: Color(0xff7048ff),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget historyCard({
    required String icon,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xfff0e7fb)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xfff1e9ff),
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
                const SizedBox(height: 4),
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
          Text(
            time,
            style: const TextStyle(
              color: Color(0xffaaa0b5),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> approveTask(BuildContext context, TaskModel task) async {
    final childProvider = context.read<ChildProvider>();
    final rewardProvider = context.read<RewardProvider>();
    final activityProvider = context.read<ActivityProvider>();
    final achievementProvider = context.read<AchievementProvider>();

    final updatedLevel = await TaskService().approveTask(task.id);
    debugPrint('DEBUG APPROVE childId: ${task.childId}');
    debugPrint('DEBUG APPROVE updatedLevel: $updatedLevel');

    if (!context.mounted) return;

    childProvider.addExp(task.expReward);
    childProvider.addReward(task.rewardAmount);
    rewardProvider.addCoins(task.rewardAmount);

    activityProvider.addActivity(
      childId: task.childId,
      title: 'Nhiệm vụ đã được duyệt',
      description: task.title,
    );

    final unlockedAchievements = await achievementProvider.checkAchievements(
      childId: task.childId,
      level: updatedLevel,
    );
    debugPrint('DEBUG unlockedAchievements: $unlockedAchievements');

    for (final achievement in unlockedAchievements) {
      activityProvider.addActivity(
        childId: task.childId,
        title: 'Mở khóa thành tựu',
        description: achievement,
      );
    }
  }

  Future<void> rejectTask(BuildContext context, TaskModel task) async {
    await TaskService().rejectTask(task.id);

    if (!context.mounted) return;

    context.read<ActivityProvider>().addActivity(
      childId: task.childId,
      title: 'Nhiệm vụ bị từ chối',
      description: task.title,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>().tasks.where((task) {
      return task.status == TaskStatus.submitted;
    }).toList();

    final familyProvider = context.watch<FamilyProvider>();

    if (familyProvider.children.isEmpty) {
      Future.microtask(() {
        if (context.mounted) {
          context.read<FamilyProvider>().listenToLinkedChildren();
        }
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xfffffaff),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  topButton('←', () => Navigator.pop(context)),
                  const Column(
                    children: [
                      Text(
                        'Duyệt nhiệm vụ',
                        style: TextStyle(
                          fontSize: 22,
                          color: Color(0xff2d243b),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Hệ thống phê duyệt của phụ huynh',
                        style: TextStyle(
                          color: Color(0xff8b7c99),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  topButton('⋯', () {}),
                ],
              ),
              const SizedBox(height: 24),
              if (tasks.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 160),
                  child: Center(
                    child: Text(
                      'Không có nhiệm vụ chờ xác nhận',
                      style: TextStyle(fontSize: 18, color: Color(0xff8b7c99)),
                    ),
                  ),
                )
              else
                ...tasks.map((task) {
                  final child = familyProvider.children.firstWhere(
                    (child) =>
                        (child['uid'] ?? child['id']).toString() ==
                        task.childId,
                    orElse: () => <String, dynamic>{},
                  );

                  final childName =
                      (child['username'] ?? child['email'] ?? 'Unknown Child')
                          .toString();
                  final childLevel = (child['level'] ?? 1).toString();
                  final childExp = (child['exp'] ?? 0).toDouble();
                  final childProgress = (childExp / 100).clamp(0.0, 1.0);

                  return Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xff7048ff), Color(0xff9d72ff)],
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '📝 ${task.title}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.22),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Text(
                                    'SUBMITTED',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              task.description,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _badge('⭐ +${task.expReward} EXP'),
                                _badge('🎁 +${task.rewardAmount} Coins'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      sectionTitle('Child Information', 'LV $childLevel'),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(color: const Color(0xfff0e7fb)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xffffb347),
                                    Color(0xffff7b54),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                '🧒',
                                style: TextStyle(fontSize: 30),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    childName,
                                    style: const TextStyle(
                                      color: Color(0xff2d243b),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Current EXP Progress',
                                    style: TextStyle(
                                      color: Color(0xff8b7c99),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(999),
                                    child: LinearProgressIndicator(
                                      value: childProgress,
                                      minHeight: 8,
                                      backgroundColor: const Color(0xffeee7f7),
                                      color: const Color(0xff7048ff),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      sectionTitle('Submitted Proof', 'Image Evidence'),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: const Color(0xfff0e7fb)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 220,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xfff3ecff),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: const Color(0xffd8c8ff),
                                  width: 2,
                                ),
                              ),
                              child: Builder(
                                builder: (_) {
                                  final imageBytes = decodeProofImage(
                                    task.proofImage,
                                  );

                                  if (imageBytes == null) {
                                    return const Text(
                                      '📸',
                                      style: TextStyle(fontSize: 70),
                                    );
                                  }

                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.memory(
                                      imageBytes,
                                      width: double.infinity,
                                      height: 220,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                _proofItem(
                                  'Submitted Time',
                                  task.submittedAt == null
                                      ? 'Just now'
                                      : '${task.submittedAt!.hour}:${task.submittedAt!.minute.toString().padLeft(2, '0')}',
                                ),
                                const SizedBox(width: 12),
                                _proofItem('Task Difficulty', task.difficulty),
                              ],
                            ),
                          ],
                        ),
                      ),
                      sectionTitle('Child Note', 'Message'),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(color: const Color(0xfff0e7fb)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '📝 Message from Child',
                              style: TextStyle(
                                color: Color(0xff2d243b),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '"${task.childNote ?? 'Con đã hoàn thành nhiệm vụ được giao rồi ạ.'}"',
                              style: TextStyle(
                                color: Color(0xff6f6280),
                                height: 1.7,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => rejectTask(context, task),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(58),
                                foregroundColor: const Color(0xffd94343),
                                side: const BorderSide(
                                  color: Color(0xffffd4d4),
                                ),
                                backgroundColor: const Color(0xfffff0f0),
                              ),
                              child: const Text('❌ Reject'),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: FilledButton(
                              onPressed: () => approveTask(context, task),
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(58),
                                backgroundColor: const Color(0xff7048ff),
                              ),
                              child: const Text('✔ Duyệt nhiệm vụ'),
                            ),
                          ),
                        ],
                      ),
                      sectionTitle('Lịch sử duyệt gần đây', 'Hôm nay'),
                      historyCard(
                        icon: '📘',
                        title: 'Bài tập đã được duyệt',
                        subtitle: '+40 EXP đã cộng cho bé',
                        time: '7:10 PM',
                      ),
                      historyCard(
                        icon: '🏆',
                        title: 'Mở khóa thành tựu',
                        subtitle: 'Đạt huy hiệu Hiệp sĩ học tập',
                        time: '6:40 PM',
                      ),
                      const SizedBox(height: 28),
                    ],
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _proofItem(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xfffaf7ff),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xff8b7c99),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xff2d243b),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
