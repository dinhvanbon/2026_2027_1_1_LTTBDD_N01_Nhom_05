import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/task_model.dart';
import '../../providers/task_provider.dart';

import '../shared/activity_log_screen.dart';
import '../shared/leaderboard_screen.dart';

import 'create_task_screen.dart';
import 'parent_reward_management_screen.dart';
import 'manage_child_screen.dart';
import 'verify_task_screen.dart';

import '../../providers/language_provider.dart';
class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

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

  Stream<QuerySnapshot<Map<String, dynamic>>> _childrenStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('children')
        .where('parentId', isEqualTo: uid)
        .snapshots();
  }

  int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  String _formatMoney(int value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}K';
    }

    return '$value';
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final tasks = taskProvider.tasks;
    final submittedTasks = taskProvider.submittedTasks;
    final totalTasks = tasks.length;

    return Scaffold(
      backgroundColor: const Color(0xfffffaff),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topRight,
              radius: 1.25,
              colors: [Color(0xffefe5ff), Color(0xfffffaff), Color(0xffffffff)],
              stops: [0.0, 0.35, 1.0],
            ),
          ),
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _childrenStream(),
            builder: (context, childSnapshot) {
              final children = childSnapshot.data?.docs ?? [];

              final totalCoins = children.fold<int>(
                0,
                (total, doc) => total + _asInt(doc.data()['coins']),
              );

              final totalExp = children.fold<int>(
                0,
                (total, doc) => total + _asInt(doc.data()['exp']),
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _topHeader(context),
                    const SizedBox(height: 38),
                    _hero(
                      context: context,
                      submittedTasks: submittedTasks.length,
                    ),
                    _statsGrid(
                      totalTasks: totalTasks,
                      submittedTasks: submittedTasks.length,
                      totalExp: totalExp,
                      totalCoins: totalCoins,
                    ),
                    _sectionTitle(tr('Truy cập nhanh', 'Quick access'), tr('Tất cả công cụ', 'All tools')),
                    _quickGrid(context),
                    _sectionTitle(tr('Cần xử lý ngay', 'Needs action'), tr('Xem tất cả', 'View all')),
                    _pendingAlerts(context, submittedTasks),
                    _sectionTitle(tr('Tiến độ của bé', 'Child progress'), tr('Chi tiết', 'Details')),
                    _childrenProgress(children),
                    _sectionTitle(tr('Hoạt động gần đây', 'Recent activity'), tr('Hôm nay', 'Today')),
                    _recentActivities(tasks),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _topHeader(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: uid == null
          ? null
          : FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final username = data?['username']?.toString().isNotEmpty == true
            ? data!['username'].toString()
            : 'Parent';
        final avatarBytes = _decodeAvatar(data?['avatar']);

        return Column(
          children: [
            Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xffffb347), Color(0xff9d72ff)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff7048ff).withValues(alpha: 0.18),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.star, color: Colors.yellow, size: 34),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Life RPG',
                        style: TextStyle(
                          color: Color(0xff2d243b),
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Parent & Child Gamification',
                        style: TextStyle(
                          color: Color(0xff8b7c99),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            const SizedBox(height: 44),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(34),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff7048ff).withValues(alpha: 0.08),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
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
                            color: Color(0xff7048ff),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          tr('Xin chào,\n$username', 'Hello,\n$username'),
                          style: const TextStyle(
                            color: Color(0xff2d243b),
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          tr('Quản lý nhiệm vụ của con hôm nay', 'Manage your child quests today'),
                          style: TextStyle(
                            color: Color(0xff8b7c99),
                            fontSize: 16,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      gradient: avatarBytes == null
                          ? const LinearGradient(
                              colors: [Color(0xff7048ff), Color(0xffffb347)],
                            )
                          : null,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: avatarBytes == null
                        ? const Icon(
                            Icons.family_restroom,
                            color: Colors.white,
                            size: 46,
                          )
                        : Image.memory(avatarBytes, fit: BoxFit.cover),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _hero({required BuildContext context, required int submittedTasks}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff7048ff), Color(0xff9d72ff)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff7048ff).withValues(alpha: 0.25),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('Tổng quan gia đình', 'Family overview'),
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            tr('$submittedTasks Chờ duyệt', '$submittedTasks Pending'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            submittedTasks == 0
                ? tr('Không có nhiệm vụ nào đang chờ xác nhận.', 'No quests waiting for approval.')
                : tr('Có $submittedTasks nhiệm vụ đang chờ xác nhận. Hãy duyệt để con nhận EXP và vàng.', '$submittedTasks quests are waiting for approval. Approve them so your child gets EXP and gold.'),
            style: const TextStyle(
              color: Colors.white,
              height: 1.5,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _heroButton(
                  text: tr('Giao việc ngay', 'Assign now'),
                  primary: true,
                  onTap: () => _open(context, const CreateTaskScreen()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _heroButton(
                  text: tr('Duyệt ngay', 'Approve now'),
                  primary: false,
                  onTap: () => _open(context, const VerifyTaskScreen()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroButton({
    required String text,
    required bool primary,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 46,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primary
              ? Colors.white
              : Colors.white.withValues(alpha: 0.25),
          foregroundColor: primary ? const Color(0xff7048ff) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: primary
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.45),
            ),
          ),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
    );
  }

  Widget _statsGrid({
    required int totalTasks,
    required int submittedTasks,
    required int totalExp,
    required int totalCoins,
  }) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 1.22,
      children: [
        _statCard(
          icon: Icons.assignment_outlined,
          value: '$totalTasks',
          label: tr('Tổng nhiệm vụ', 'Total quests'),
          color: const Color(0xff7048ff),
        ),
        _statCard(
          icon: Icons.verified_outlined,
          value: '$submittedTasks',
          label: tr('Cần duyệt việc', 'To approve'),
          color: const Color(0xffff9f43),
        ),
        _statCard(
          icon: Icons.star_outline,
          value: '$totalExp',
          label: tr('Tổng EXP đã cấp', 'Total EXP given'),
          color: const Color(0xff2b6bd6),
        ),
        _statCard(
          icon: Icons.card_giftcard,
          value: _formatMoney(totalCoins),
          label: tr('Vàng đã thưởng', 'Gold rewarded'),
          color: const Color(0xff2ecc71),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xfff0e7fb)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff502d82).withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xff2d243b),
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xff8b7c99),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String actionText) {
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
          Text(
            actionText,
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

  Widget _quickGrid(BuildContext context) {
    final items = [
      _QuickItem(
        icon: Icons.add_task,
        title: tr('Giao việc', 'Assign'),
        onTap: () => _open(context, const CreateTaskScreen()),
      ),
      _QuickItem(
        icon: Icons.verified,
        title: tr('Duyệt việc', 'Approve'),
        onTap: () => _open(context, const VerifyTaskScreen()),
      ),
      _QuickItem(
        icon: Icons.card_giftcard,
        title: tr('Đổi quà', 'Redeem'),
        onTap: () => _open(context, const ParentRewardManagementScreen()),
      ),
      _QuickItem(
        icon: Icons.child_care,
        title: tr('Con cái', 'Children'),
        onTap: () => _open(context, const ManageChildScreen()),
      ),
      _QuickItem(
        icon: Icons.leaderboard,
        title: tr('Bảng xếp hạng', 'Leaderboard'),
        onTap: () => _open(context, const LeaderboardScreen()),
      ),
      _QuickItem(
        icon: Icons.history,
        title: tr('Lịch sử', 'History'),
        onTap: () => _open(context, const ActivityLogScreen()),
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.05,
      children: items.map((item) {
        return InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xfff0e7fb)),
              borderRadius: BorderRadius.circular(24),
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
                Icon(item.icon, color: const Color(0xff7048ff), size: 28),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Color(0xff2d243b),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _pendingAlerts(BuildContext context, List<TaskModel> submittedTasks) {
    if (submittedTasks.isEmpty) {
      return _emptyCard(tr('Không có nhiệm vụ cần xác nhận.', 'No quests to approve.'));
    }

    final visibleTasks = submittedTasks.take(2).toList();

    return Column(
      children: visibleTasks.map((task) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xfffff7e8), Colors.white],
            ),
            border: Border.all(color: const Color(0xffffe0a9)),
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
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xfffff0cf),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.pending_actions, color: Colors.orange),
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
                        color: Color(0xff2d243b),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tr('Con đã gửi bằng chứng, đang chờ xác nhận.', 'Your child sent proof, waiting for approval.'),
                      style: TextStyle(
                        color: Color(0xff8b7c99),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => _open(context, const VerifyTaskScreen()),
                child: Text(tr('Duyệt ngay', 'Approve now')),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _childrenProgress(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> children,
  ) {
    if (children.isEmpty) {
      return _emptyCard(tr('Chưa có child được liên kết.', 'No child linked yet.'));
    }

    return Column(
      children: children.take(2).map((doc) {
        final data = doc.data();
        final name = data['username']?.toString().isNotEmpty == true
            ? data['username'].toString()
            : data['email']?.toString() ?? 'Child';

        final level = _asInt(data['level']);
        final exp = _asInt(data['exp']);
        final coins = _asInt(data['coins']);
        final maxExp = (level <= 0 ? 1 : level) * 100;
        final progress = maxExp == 0 ? 0.0 : (exp / maxExp).clamp(0.0, 1.0);

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xfff0e7fb)),
            borderRadius: BorderRadius.circular(26),
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
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xffffb347), Color(0xffff7b54)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.child_care,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Color(0xff2d243b),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tr('$coins vàng đã nhận', '$coins gold received'),
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
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffefe7ff),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      tr('Cấp $level', 'Level $level'),
                      style: const TextStyle(
                        color: Color(0xff7048ff),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: const Color(0xffeee7f7),
                  color: const Color(0xff7048ff),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '$exp / $maxExp EXP',
                    style: const TextStyle(
                      color: Color(0xff8b7c99),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(
                      color: Color(0xff8b7c99),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _recentActivities(List<TaskModel> tasks) {
    final recent = tasks.take(3).toList();

    if (recent.isEmpty) {
      return _emptyCard(tr('Chưa có hoạt động gần đây.', 'No recent activity.'));
    }

    return Column(
      children: recent.map((task) {
        final icon = task.status == TaskStatus.submitted
            ? Icons.upload_file
            : task.status == TaskStatus.approved
            ? Icons.check_circle
            : task.status == TaskStatus.rejected
            ? Icons.cancel
            : Icons.assignment;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xfff0e7fb)),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xff502d82).withValues(alpha: 0.07),
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
                decoration: BoxDecoration(
                  color: const Color(0xfff1e9ff),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: const Color(0xff7048ff)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xff2d243b),
                        fontSize: 14,
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
              Text(
                task.deadlineText,
                style: const TextStyle(
                  color: Color(0xffaaa0b5),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _emptyCard(String message) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xfff0e7fb)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(message, style: const TextStyle(color: Color(0xff8b7c99))),
    );
  }
}

class _QuickItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}
