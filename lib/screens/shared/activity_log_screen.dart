import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/activity_model.dart';
import '../../services/activity_service.dart';

class ActivityLogScreen extends StatelessWidget {
  const ActivityLogScreen({super.key});

  DateTime _dateFromDynamic(dynamic value) {
    if (value == null) return DateTime.now();

    try {
      return value.toDate();
    } catch (_) {
      return DateTime.now();
    }
  }

  Stream<List<ActivityModel>> _activityStream() async* {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      yield <ActivityModel>[];
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final role = userDoc.data()?['role']?.toString().toLowerCase();

    String? activityOwnerId;

    if (role == 'child') {
      activityOwnerId = user.uid;
    } else if (role == 'parent') {
      final childSnapshot = await FirebaseFirestore.instance
          .collection('children')
          .where('parentId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (childSnapshot.docs.isNotEmpty) {
        activityOwnerId = childSnapshot.docs.first.id;
      } else {
        final userChildSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('parentId', isEqualTo: user.uid)
            .where('role', isEqualTo: 'child')
            .limit(1)
            .get();

        if (userChildSnapshot.docs.isNotEmpty) {
          activityOwnerId = userChildSnapshot.docs.first.id;
        }
      }
    }

    if (activityOwnerId == null) {
      yield <ActivityModel>[];
      return;
    }

    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(activityOwnerId);

    final activitiesSnapshot = await userRef
        .collection('activities')
        .orderBy('createdAt', descending: true)
        .get();

    final rewardHistorySnapshot = await userRef
        .collection('rewardHistory')
        .orderBy('redeemedAt', descending: true)
        .get();

    final achievementsSnapshot = await userRef.collection('achievements').get();

    final rewardsSnapshot = await userRef.collection('rewards').get();

    debugPrint(
      'ACTIVITY_DEBUG counts activities=${activitiesSnapshot.docs.length} rewardHistory=${rewardHistorySnapshot.docs.length} achievements=${achievementsSnapshot.docs.length} rewards=${rewardHistorySnapshot.docs.length}',
    );

    final items = <ActivityModel>[];

    for (final doc in activitiesSnapshot.docs) {
      final data = doc.data();

      items.add(
        ActivityModel(
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          createdAt: _dateFromDynamic(data['createdAt']),
        ),
      );
    }

    for (final doc in rewardHistorySnapshot.docs) {
      final data = doc.data();

      items.add(
        ActivityModel(
          title: 'Đã đổi quà',
          description: data['title'] ?? data['description'] ?? 'Phần thưởng',
          createdAt: _dateFromDynamic(data['redeemedAt']),
        ),
      );
    }

    for (final doc in achievementsSnapshot.docs) {
      final data = doc.data();
      items.add(
        ActivityModel(
          title: 'Thành tựu',
          description: data['title'] ?? data['description'] ?? 'Mở khóa thành tựu',
          createdAt: _dateFromDynamic(
            data['unlockedAt'] ?? data['createdAt'] ?? data['updatedAt'],
          ),
        ),
      );
    }

    for (final doc in rewardsSnapshot.docs) {
      final data = doc.data();
      items.add(
        ActivityModel(
          title: 'Phần thưởng',
          description: data['title'] ?? data['description'] ?? 'Phần thưởng mới',
          createdAt: _dateFromDynamic(data['updatedAt'] ?? data['createdAt']),
        ),
      );
    }

    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    debugPrint('ACTIVITY_DEBUG totalItems=${items.length}');

    yield items;
  }

  Widget topButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: const Color(0xff7048ff)),
      ),
    );
  }

  Widget statCard({
    required IconData icon,
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
            Icon(icon, color: const Color(0xff7048ff), size: 27),
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

  Widget activityCard({
    required IconData icon,
    required String title,
    required String description,
    required String tag,
    required String time,
    required String amount,
    required Color iconBg,
    bool featured = false,
    bool positive = true,
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
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: const Color(0xff7048ff)),
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
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xff8b7c99),
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffe7ffe9),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: Color(0xff1c9b43),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: const TextStyle(
                        color: Color(0xffaaa0b5),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: positive
                  ? const Color(0xff1c9b43)
                  : const Color(0xffff8a00),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  String _timeText(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  String _dateText(DateTime time) {
    const days = [
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
      'Chủ Nhật',
    ];

    final day = time.day.toString().padLeft(2, '0');
    final month = time.month.toString().padLeft(2, '0');
    return '${days[time.weekday - 1]}, $day/$month/${time.year}';
  }

  IconData _activityIcon(String title, String description) {
    final text = '$title $description'.toLowerCase();

    if (text.contains('reward') || text.contains('thưởng')) {
      return Icons.card_giftcard;
    }

    if (text.contains('achievement') || text.contains('huy hiệu')) {
      return Icons.emoji_events;
    }

    if (text.contains('từ chối') || text.contains('rejected')) {
      return Icons.cancel;
    }

    if (text.contains('xác nhận') || text.contains('duyệt')) {
      return Icons.check_circle;
    }

    return Icons.assignment;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffffaff),
      body: SafeArea(
        child: StreamBuilder<List<ActivityModel>>(
          stream: _activityStream(),
          builder: (context, snapshot) {
            final activities = snapshot.data ?? [];

            final now = DateTime.now();

            final todayActivities = activities.where((activity) {
              return activity.createdAt.year == now.year &&
                  activity.createdAt.month == now.month &&
                  activity.createdAt.day == now.day;
            }).toList();

            final taskActivityCount = todayActivities.where((activity) {
              final text = '${activity.title} ${activity.description}'
                  .toLowerCase();

              return text.contains('task') ||
                  text.contains('nhiệm vụ') ||
                  text.contains('submitted') ||
                  text.contains('approved') ||
                  text.contains('rejected');
            }).length;

            final achievementActivityCount = todayActivities.where((activity) {
              final text = '${activity.title} ${activity.description}'
                  .toLowerCase();

              return text.contains('achievement') || text.contains('huy hiệu');
            }).length;

            final previousActivities = activities.where((activity) {
              final d = activity.createdAt;

              return !(d.year == now.year &&
                  d.month == now.month &&
                  d.day == now.day);
            }).toList();

            final rewardActivityCount = todayActivities.where((activity) {
              final text = '${activity.title} ${activity.description}'
                  .toLowerCase();

              return text.contains('reward') ||
                  text.contains('thưởng') ||
                  text.contains('coin');
            }).length;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      topButton(Icons.arrow_back, () => Navigator.pop(context)),
                      const Column(
                        children: [
                          Text(
                            'Hoạt động',
                            style: TextStyle(
                              fontSize: 22,
                              color: Color(0xff2d243b),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Lịch sử hoạt động',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xff8b7c99),
                            ),
                          ),
                        ],
                      ),
                      topButton(Icons.settings, () async {
                        await ActivityService().syncOldTasksToActivity();

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã đồng bộ nhiệm vụ cũ')),
                        );
                      }),
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
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _dateText(DateTime.now()),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${todayActivities.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Hoạt động hôm nay bao gồm nhiệm vụ, kinh nghiệm (EXP), phần thưởng và thành tựu.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 180,
                          child: statCard(
                            icon: Icons.assignment,
                            value: '$taskActivityCount',
                            label: 'Nhiệm vụ',
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 180,
                          child: statCard(
                            icon: Icons.star,
                            value: '$achievementActivityCount',
                            label: 'Thành tựu',
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 180,
                          child: statCard(
                            icon: Icons.card_giftcard,
                            value: '$rewardActivityCount',
                            label: 'Phần thưởng',
                          ),
                        ),
                      ],
                    ),
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
                        Icon(Icons.search, color: Color(0xff7048ff)),
                        SizedBox(width: 10),
                        Text(
                          'Tìm kiếm nhiệm vụ, phần thưởng, thành tựu...',
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
                        chip('Tất cả', active: true),
                        const SizedBox(width: 10),
                        chip('Nhiệm vụ'),
                        const SizedBox(width: 10),
                        chip('Kinh nghiệm (EXP)'),
                        const SizedBox(width: 10),
                        chip('Phần thưởng'),
                        const SizedBox(width: 10),
                        chip('Thành tựu'),
                        const SizedBox(width: 10),
                        chip('Bị từ chối'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Dòng thời gian',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xff2d243b),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Xuất dữ liệu',
                        style: TextStyle(
                          color: Color(0xff7048ff),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'HÔM NAY',
                      style: TextStyle(
                        color: Color(0xff8b7c99),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (todayActivities.isEmpty)
                    activityCard(
                      icon: Icons.info_outline,
                      title: 'Chưa có hoạt động',
                      description:
                          'Khi nhiệm vụ được tạo, gửi, duyệt hoặc nhận thưởng, hoạt động sẽ hiển thị tại đây.',
                      tag: 'TRỐNG',
                      time: '--:--',
                      amount: '',
                      iconBg: const Color(0xfff1e9ff),
                    )
                  else
                    Column(
                      children: todayActivities.map((activity) {
                        return activityCard(
                          icon: _activityIcon(
                            activity.title,
                            activity.description,
                          ),
                          title: activity.title,
                          description: activity.description,
                          tag: 'HOẠT ĐỘNG',
                          time: _timeText(activity.createdAt),
                          amount: '',
                          iconBg: const Color(0xfff1e9ff),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 24),

                  if (previousActivities.isNotEmpty) ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'CÁC NGÀY TRƯỚC',
                        style: TextStyle(
                          color: Color(0xff8b7c99),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Column(
                      children: previousActivities.map((activity) {
                        return activityCard(
                          icon: _activityIcon(
                            activity.title,
                            activity.description,
                          ),
                          title: activity.title,
                          description: activity.description,
                          tag:
                              '${activity.createdAt.day}/${activity.createdAt.month}',
                          time: _timeText(activity.createdAt),
                          amount: '',
                          iconBg: const Color(0xfff1e9ff),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
