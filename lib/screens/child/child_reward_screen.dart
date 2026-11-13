import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/reward_model.dart';
import '../../providers/reward_provider.dart';
import '../../providers/activity_provider.dart';

import '../../providers/language_provider.dart';
class ChildRewardScreen extends StatefulWidget {
  const ChildRewardScreen({super.key});

  @override
  State<ChildRewardScreen> createState() => _ChildRewardScreenState();
}

class _ChildRewardScreenState extends State<ChildRewardScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final childId = FirebaseAuth.instance.currentUser?.uid;

      if (childId == null) return;

      context.read<RewardProvider>().listenRewardsForChild(childId);
    });
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
        color: active ? const Color(0xffff9f43) : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active ? const Color(0xffff9f43) : const Color(0xffeee3fb),
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

  Widget rewardCard({
    required BuildContext context,
    required RewardModel reward,
    required bool canRedeem,
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
              color: const Color(0xfffff0cf),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Text(reward.icon, style: const TextStyle(fontSize: 30)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.title,
                  style: const TextStyle(
                    color: Color(0xff2d243b),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reward.description,
                  style: const TextStyle(
                    color: Color(0xff8b7c99),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xfffff3df),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${reward.price} ⭐',
                        style: const TextStyle(
                          color: Color(0xffff8a00),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      canRedeem
                          ? 'Available'
                          : 'Need ${reward.price - context.read<RewardProvider>().coins} ⭐',
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
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: canRedeem
                ? () async {
                    try {
                      await context.read<RewardProvider>().redeemReward(
                        reward.id,
                      );

                      final user = FirebaseAuth.instance.currentUser;

                      if (user == null) {
                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(tr('Phiên đăng nhập hết hạn', 'Session expired')),
                          ),
                        );
                        return;
                      }

                      final childId = user.uid;

                      if (!context.mounted) return;

                      await context.read<ActivityProvider>().addActivity(
                        childId: childId,
                        title: 'Đã đổi quà',
                        description: reward.title,
                      );

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(tr('Đổi thưởng thành công', 'Reward redeemed successfully'))),
                      );
                    } catch (e) {
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(tr('Lỗi đổi thưởng: $e', 'Redeem error: $e'))),
                      );
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              elevation: canRedeem ? 8 : 0,
              backgroundColor: canRedeem
                  ? const Color(0xffff9f43)
                  : const Color(0xfff1edf5),
              foregroundColor: canRedeem
                  ? Colors.white
                  : const Color(0xff8b7c99),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              canRedeem ? 'REDEEM' : 'LOCKED',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
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
    required int price,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xfff0e7fb)),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.07),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xfffff0cf),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(icon, style: const TextStyle(fontSize: 23)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xff2d243b),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
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
            '-$price ⭐',
            style: const TextStyle(
              color: Color(0xffff8a00),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>();
    final rewardProvider = context.watch<RewardProvider>();
    final rewards = rewardProvider.rewards;
    final history = rewardProvider.history;

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
                      children: [
                        topButton('←', () => Navigator.pop(context)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                tr('Đổi thưởng', 'Redeem rewards'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Color(0xff2d243b),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                tr('Đổi quà & quản lý vàng', 'Redeem gifts & manage gold'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xff8b7c99),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        topButton('🔔', () {}),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xffff9f43), Color(0xffffb347)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xffff9f43,
                            ).withValues(alpha: 0.28),
                            blurRadius: 30,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Balance',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${rewardProvider.coins} ⭐',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 46,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            tr('Dùng coin để đổi phần thưởng sau khi hoàn thành nhiệm vụ.', 'Use coins to redeem rewards after completing quests.'),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton(
                                  onPressed: () {},
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xffff8a00),
                                  ),
                                  child: Text(tr('Đổi quà ngay', 'Redeem now')),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(
                                      color: Colors.white54,
                                    ),
                                  ),
                                  child: Text(tr('Lịch sử', 'History')),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        statCard(
                          icon: '🎁',
                          value: '${rewards.length}',
                          label: tr('Quà tặng', 'Gifts'),
                        ),
                        const SizedBox(width: 12),
                        statCard(
                          icon: '✅',
                          value: '${rewardProvider.redeemedCount}',
                          label: tr('Đã đổi', 'Redeemed'),
                        ),
                        const SizedBox(width: 12),
                        statCard(icon: '🔥', value: '4', label: tr('Chuỗi ngày', 'Streak')),
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
                      child: Row(
                        children: [
                          Text('🔍', style: TextStyle(fontSize: 20)),
                          SizedBox(width: 10),
                          Text(
                            tr('Tìm reward, voucher, phần thưởng...', 'Search rewards, vouchers, gifts...'),
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
                          chip('Food'),
                          const SizedBox(width: 10),
                          chip('Game'),
                          const SizedBox(width: 10),
                          chip('Gift'),
                          const SizedBox(width: 10),
                          chip('Family'),
                          const SizedBox(width: 10),
                          chip('Redeemed'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Reward Shop',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xff2d243b),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Sort',
                          style: TextStyle(
                            color: Color(0xffff8a00),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: rewards.map((reward) {
                        return rewardCard(
                          context: context,
                          reward: reward,
                          canRedeem: rewardProvider.canRedeem(reward.price),
                          featured: reward.id == '1',
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Redeem',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xff2d243b),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'View all',
                          style: TextStyle(
                            color: Color(0xffff8a00),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (history.isEmpty)
                      Text(
                        tr('Chưa có lịch sử đổi thưởng', 'No redemption history yet'),
                        style: TextStyle(color: Color(0xff8b7c99)),
                      )
                    else
                      Column(
                        children: history.map((reward) {
                          return historyCard(
                            icon: reward.icon,
                            title: '${reward.title} Redeemed',
                            subtitle: 'Just now • Approved by Parent',
                            price: reward.price,
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
}
