import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/activity_model.dart';
import '../../services/activity_service.dart';

import '../../providers/language_provider.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  String _selectedFilter = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesFilter(ActivityModel activity) {
    final text = '${activity.title} ${activity.description}'.toLowerCase();
    if (_searchQuery.trim().isNotEmpty &&
        !text.contains(_searchQuery.trim().toLowerCase())) {
      return false;
    }
    switch (_selectedFilter) {
      case 'task':
        return text.contains('task') ||
            text.contains('nhiệm vụ') ||
            text.contains('submitted') ||
            text.contains('approved') ||
            text.contains('xác nhận') ||
            text.contains('duyệt') ||
            text.contains('gửi');
      case 'exp':
        return text.contains('exp') ||
            text.contains('kinh nghiệm') ||
            text.contains('approved') ||
            text.contains('duyệt') ||
            text.contains('hoàn thành');
      case 'reward':
        return text.contains('reward') ||
            text.contains('thưởng') ||
            text.contains('quà') ||
            text.contains('coin');
      case 'achievement':
        return text.contains('achievement') ||
            text.contains('huy hiệu') ||
            text.contains('thành tựu');
      case 'rejected':
        return text.contains('rejected') || text.contains('từ chối');
      default:
        return true;
    }
  }

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
          title: tr('Đã đổi quà', 'Reward redeemed'),
          description: data['title'] ?? data['description'] ?? tr('Phần thưởng', 'Rewards'),
          createdAt: _dateFromDynamic(data['redeemedAt']),
        ),
      );
    }

    for (final doc in achievementsSnapshot.docs) {
      final data = doc.data();
      items.add(
        ActivityModel(
          title: tr('Thành tựu', 'Achievements'),
          description: data['title'] ?? data['description'] ?? tr('Mở khóa thành tựu', 'Achievement unlocked'),
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
          title: tr('Phần thưởng', 'Rewards'),
          description: data['title'] ?? data['description'] ?? tr('Phần thưởng mới', 'New reward'),
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

  Widget chip(String text, {bool active = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
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
    final days = [
      tr('Thứ Hai', 'Monday'),
      tr('Thứ Ba', 'Tuesday'),
      tr('Thứ Tư', 'Wednesday'),
      tr('Thứ Năm', 'Thursday'),
      tr('Thứ Sáu', 'Friday'),
      tr('Thứ Bảy', 'Saturday'),
      tr('Chủ Nhật', 'Sunday'),
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
    context.watch<LanguageProvider>();
    return Scaffold(
      backgroundColor: const Color(0xfffffaff),
      body: SafeArea(
        child: StreamBuilder<List<ActivityModel>>(
          stream: _activityStream(),
          builder: (context, snapshot) {
            final activities = snapshot.data ?? [];

            final now = DateTime.now();

            final allTodayActivities = activities.where((activity) {
              return activity.createdAt.year == now.year &&
                  activity.createdAt.month == now.month &&
                  activity.createdAt.day == now.day;
            }).toList();

            final filteredActivities = activities
                .where(_matchesFilter)
                .toList();

            final todayActivities = filteredActivities.where((activity) {
              return activity.createdAt.year == now.year &&
                  activity.createdAt.month == now.month &&
                  activity.createdAt.day == now.day;
            }).toList();

            final taskActivityCount = allTodayActivities.where((activity) {
              final text = '${activity.title} ${activity.description}'
                  .toLowerCase();

              return text.contains('task') ||
                  text.contains('nhiệm vụ') ||
                  text.contains('submitted') ||
                  text.contains('approved') ||
                  text.contains('rejected');
            }).length;

            final achievementActivityCount = allTodayActivities.where((
              activity,
            ) {
              final text = '${activity.title} ${activity.description}'
                  .toLowerCase();

              return text.contains('achievement') || text.contains('huy hiệu');
            }).length;

            final previousActivities = filteredActivities.where((activity) {
              final d = activity.createdAt;

              return !(d.year == now.year &&
                  d.month == now.month &&
                  d.day == now.day);
            }).toList();

            final rewardActivityCount = allTodayActivities.where((activity) {
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
                      topButton(Icons.arrow_back, () => Navigator.maybePop(context)),
                      Column(
                        children: [
                          Text(
                            tr('Hoạt động', 'Activity'),
                            style: TextStyle(
                              fontSize: 22,
                              color: Color(0xff2d243b),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            tr('Lịch sử hoạt động', 'Activity history'),
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
                          SnackBar(content: Text(tr('Đã đồng bộ nhiệm vụ cũ', 'Old quests synced'))),
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
                        Text(
                          tr('Hoạt động hôm nay bao gồm nhiệm vụ, kinh nghiệm (EXP), phần thưởng và thành tựu.', 'Today activity includes quests, experience (EXP), rewards and achievements.'),
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
                            label: tr('Nhiệm vụ', 'Quests'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 180,
                          child: statCard(
                            icon: Icons.star,
                            value: '$achievementActivityCount',
                            label: tr('Thành tựu', 'Achievements'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 180,
                          child: statCard(
                            icon: Icons.card_giftcard,
                            value: '$rewardActivityCount',
                            label: tr('Phần thưởng', 'Rewards'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xffeee3fb)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        icon: const Icon(
                          Icons.search,
                          color: Color(0xff7048ff),
                        ),
                        hintText: tr(
                          'Tìm kiếm nhiệm vụ, phần thưởng, thành tựu...',
                          'Search quests, rewards, achievements...',
                        ),
                        hintStyle: const TextStyle(
                          color: Color(0xff8b7c99),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        chip(
                          tr('Tất cả', 'All'),
                          active: _selectedFilter == 'all',
                          onTap: () => setState(() => _selectedFilter = 'all'),
                        ),
                        const SizedBox(width: 10),
                        chip(
                          tr('Nhiệm vụ', 'Quests'),
                          active: _selectedFilter == 'task',
                          onTap: () => setState(() => _selectedFilter = 'task'),
                        ),
                        const SizedBox(width: 10),
                        chip(
                          tr('Kinh nghiệm (EXP)', 'Experience (EXP)'),
                          active: _selectedFilter == 'exp',
                          onTap: () => setState(() => _selectedFilter = 'exp'),
                        ),
                        const SizedBox(width: 10),
                        chip(
                          tr('Phần thưởng', 'Rewards'),
                          active: _selectedFilter == 'reward',
                          onTap: () =>
                              setState(() => _selectedFilter = 'reward'),
                        ),
                        const SizedBox(width: 10),
                        chip(
                          tr('Thành tựu', 'Achievements'),
                          active: _selectedFilter == 'achievement',
                          onTap: () =>
                              setState(() => _selectedFilter = 'achievement'),
                        ),
                        const SizedBox(width: 10),
                        chip(
                          tr('Bị từ chối', 'Rejected'),
                          active: _selectedFilter == 'rejected',
                          onTap: () =>
                              setState(() => _selectedFilter = 'rejected'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tr('Dòng thời gian', 'Timeline'),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xff2d243b),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (dialogCtx) => AlertDialog(
                              title: Text(
                                tr(
                                  'Xuất dữ liệu hoạt động',
                                  'Export Activity Data',
                                ),
                              ),
                              content: Text(
                                tr(
                                  'Tổng số hoạt động ghi nhận: ${activities.length}\n'
                                      '• Hôm nay: ${allTodayActivities.length}\n'
                                      '• Nhiệm vụ: $taskActivityCount\n'
                                      '• Thành tựu: $achievementActivityCount\n'
                                      '• Phần thưởng: $rewardActivityCount\n\n'
                                      'Dữ liệu nhật ký đã sẵn sàng để trích xuất.',
                                  'Total recorded activities: ${activities.length}\n'
                                      '• Today: ${allTodayActivities.length}\n'
                                      '• Quests: $taskActivityCount\n'
                                      '• Achievements: $achievementActivityCount\n'
                                      '• Rewards: $rewardActivityCount\n\n'
                                      'Activity log summary is ready for export.',
                                ),
                              ),
                              actions: [
                                FilledButton(
                                  onPressed: () {
                                    Navigator.pop(dialogCtx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          tr(
                                            'Đã xuất báo cáo nhật ký hoạt động thành công!',
                                            'Activity log report exported successfully!',
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(tr('Xác nhận', 'Confirm')),
                                ),
                              ],
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Text(
                            tr('Xuất dữ liệu', 'Export data'),
                            style: const TextStyle(
                              color: Color(0xff7048ff),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      tr('HÔM NAY', 'TODAY'),
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
                      title: tr('Chưa có hoạt động', 'No activity yet'),
                      description:
                          tr('Khi nhiệm vụ được tạo, gửi, duyệt hoặc nhận thưởng, hoạt động sẽ hiển thị tại đây.', 'When quests are created, submitted, approved or rewarded, activities will appear here.'),
                      tag: tr('TRỐNG', 'EMPTY'),
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
                          tag: tr('HOẠT ĐỘNG', 'ACTIVITY'),
                          time: _timeText(activity.createdAt),
                          amount: '',
                          iconBg: const Color(0xfff1e9ff),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 24),

                  if (previousActivities.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        tr('CÁC NGÀY TRƯỚC', 'PREVIOUS DAYS'),
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
