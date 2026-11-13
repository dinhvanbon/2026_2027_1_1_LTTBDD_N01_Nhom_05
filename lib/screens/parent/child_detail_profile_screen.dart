import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../shared/activity_log_screen.dart';
import 'create_task_screen.dart';

import '../../providers/language_provider.dart';
class ChildDetailProfileScreen extends StatelessWidget {
  final String childId;
  final Map<String, dynamic> childData;

  const ChildDetailProfileScreen({
    super.key,
    required this.childId,
    required this.childData,
  });

  Uint8List? _decodeAvatar(dynamic avatar) {
    if (avatar == null) return null;

    try {
      var value = avatar.toString();

      if (value.isEmpty) return null;

      if (value.contains(',')) {
        value = value.split(',').last;
      }

      return base64Decode(value);
    } catch (_) {
      return null;
    }
  }

  int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>();
    final tasks = context
        .watch<TaskProvider>()
        .tasks
        .where((task) => task.childId == childId)
        .toList();

    final name = childData['username']?.toString().isNotEmpty == true
        ? childData['username'].toString()
        : childData['email']?.toString() ?? 'Child';

    final level = _asInt(childData['level']);
    final exp = _asInt(childData['exp']);
    final coins = _asInt(childData['coins']);

    final maxExp = (level <= 0 ? 1 : level) * 100;
    final progress = maxExp == 0 ? 0.0 : (exp / maxExp).clamp(0.0, 1.0);

    final completedTasks = tasks
        .where((task) => task.status == TaskStatus.approved)
        .length;

    return Scaffold(
      backgroundColor: const Color(0xfffffaff),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context),
              const SizedBox(height: 22),
              _profileCard(name, level, childData['avatar']),
              _expCard(exp, maxExp, progress),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(childId)
                    .collection('achievements')
                    .snapshots(),
                builder: (context, snapshot) {
                  final achievements = snapshot.data?.docs ?? [];
                  final unlockedCount = achievements.where((doc) {
                    return doc.data()['unlocked'] == true;
                  }).length;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _stats(
                        tasks: completedTasks,
                        badges: unlockedCount,
                        coins: coins,
                      ),
                      _section(tr('Nhiệm vụ gần đây', 'Recent quests'), tr('Xem tất cả', 'View all')),
                      _recentTasks(tasks),
                      _section(tr('Thành tựu', 'Achievements'), tr('Tất cả', 'All')),
                      _achievements(achievements),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              _actions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        _topButton(icon: Icons.arrow_back, onTap: () => Navigator.pop(context)),
        Expanded(
          child: Column(
            children: [
              Text(
                tr('Hồ sơ của bé', 'Child profile'),
                style: TextStyle(
                  color: Color(0xff2d243b),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 3),
              Text(
                tr('Góc nhìn phụ huynh', 'Parent view'),
                style: TextStyle(color: Color(0xff8b7c99), fontSize: 13),
              ),
            ],
          ),
        ),
        _topButton(icon: Icons.settings, onTap: () {}),
      ],
    );
  }

  Widget _topButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff502d82).withValues(alpha: 0.10),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xff2d243b)),
      ),
    );
  }

  Widget _profileCard(String name, int level, dynamic avatar) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff7048ff), Color(0xff9d72ff)],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff7048ff).withValues(alpha: 0.30),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Builder(
            builder: (_) {
              final avatarBytes = _decodeAvatar(avatar);

              if (avatarBytes == null) {
                return Container(
                  width: 95,
                  height: 95,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const Icon(
                    Icons.child_care,
                    color: Colors.white,
                    size: 56,
                  ),
                );
              }

              return ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Image.memory(
                  avatarBytes,
                  width: 95,
                  height: 95,
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
          const SizedBox(height: 15),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            tr('Chiến binh nhí • Hoạt động mỗi ngày', 'Little warrior • Active every day'),
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 15),
          Wrap(spacing: 10, children: [_badge(tr('Cấp $level', 'Level $level')), _badge(tr('Đang hoạt động', 'Active'))]),
        ],
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _expCard(int exp, int maxExp, double progress) {
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff502d82).withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'EXP Progress',
                style: TextStyle(
                  color: Color(0xff2d243b),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: Color(0xff7048ff),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: const Color(0xffeee7f7),
              color: const Color(0xff7048ff),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '$exp / $maxExp EXP',
              style: const TextStyle(color: Color(0xff8b7c99), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stats({required int tasks, required int badges, required int coins}) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.95,
      children: [
        _stat(Icons.assignment, '$tasks', tr('Nhiệm vụ', 'Quests')),
        _stat(Icons.emoji_events, '$badges', tr('Huy hiệu', 'Badges')),
        _stat(Icons.star, '$coins', tr('Vàng', 'Gold')),
      ],
    );
  }

  Widget _stat(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff502d82).withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xff7048ff), size: 27),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xff2d243b),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Color(0xff8b7c99), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, String action) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xff2d243b),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            action,
            style: const TextStyle(
              color: Color(0xff7048ff),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentTasks(List<TaskModel> tasks) {
    final recent = tasks.take(2).toList();

    if (recent.isEmpty) {
      return _emptyCard(tr('Chưa có nhiệm vụ gần đây.', 'No recent quests.'));
    }

    return Column(
      children: recent.map((task) {
        final done = task.status == TaskStatus.approved;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: const Color(0xff502d82).withValues(alpha: 0.08),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xfff1e9ff),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  done ? Icons.check_circle : Icons.pending_actions,
                  color: const Color(0xff7048ff),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(
                        color: Color(0xff2d243b),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.statusText,
                      style: const TextStyle(
                        color: Color(0xff8b7c99),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _status(done ? 'DONE' : 'WAIT', done),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _status(String text, bool done) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: done ? const Color(0xffe7ffe9) : const Color(0xfffff3df),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: done ? const Color(0xff1c9b43) : const Color(0xffff8a00),
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _achievements(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> achievements,
  ) {
    if (achievements.isEmpty) {
      return _emptyCard(tr('Chưa có achievement nào.', 'No achievements yet.'));
    }

    return Column(
      children: achievements.map((doc) {
        final data = doc.data();

        final title = data['title']?.toString() ?? 'Achievement';
        final description = data['description']?.toString() ?? '';
        final requiredLevel = data['requiredLevel'] ?? 1;
        final unlocked = data['unlocked'] == true;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: unlocked
                  ? [const Color(0xfffff7e8), Colors.white]
                  : [const Color(0xfff5f2f8), Colors.white],
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: unlocked
                  ? const Color(0xffffe0a9)
                  : const Color(0xffeee3fb),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xff502d82).withValues(alpha: 0.08),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: unlocked
                      ? const Color(0xfffff0cf)
                      : const Color(0xffeee7f7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  unlocked ? Icons.emoji_events : Icons.lock,
                  color: unlocked ? Colors.orange : const Color(0xff8b7c99),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: unlocked
                            ? const Color(0xff2d243b)
                            : const Color(0xff8b7c99),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description.isNotEmpty
                          ? description
                          : tr('Yêu cầu level $requiredLevel', 'Requires level $requiredLevel'),
                      style: const TextStyle(
                        color: Color(0xff8b7c99),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: unlocked
                      ? const Color(0xffe7ffe9)
                      : const Color(0xfffff3df),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  unlocked ? tr('ĐÃ MỞ', 'UNLOCKED') : tr('CẤP $requiredLevel', 'LEVEL $requiredLevel'),
                  style: TextStyle(
                    color: unlocked
                        ? const Color(0xff1c9b43)
                        : const Color(0xffff8a00),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _actions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 55,
            child: FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ActivityLogScreen()),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xfff1e9ff),
                foregroundColor: const Color(0xff7048ff),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: Text(
                tr('Nhật ký hoạt động', 'Activity log'),
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 55,
            child: FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateTaskScreen()),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xff7048ff),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: Text(
                tr('Giao việc ngay', 'Assign now'),
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyCard(String message) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(message, style: const TextStyle(color: Color(0xff8b7c99))),
    );
  }
}
