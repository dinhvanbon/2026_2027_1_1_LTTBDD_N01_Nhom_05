import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/reward_model.dart';
import '../../providers/reward_provider.dart';
import '../../providers/family_provider.dart';

import '../../providers/language_provider.dart';
class ParentRewardManagementScreen extends StatefulWidget {
  const ParentRewardManagementScreen({super.key});

  @override
  State<ParentRewardManagementScreen> createState() =>
      _ParentRewardManagementScreenState();
}

class _ParentRewardManagementScreenState
    extends State<ParentRewardManagementScreen> {
  String? _selectedChildId;
  bool _startedFamilyListen = false;

  Future<void> showRewardDialog(
    BuildContext context, {
    required String childId,
    RewardModel? reward,
  }) async {
    final titleController = TextEditingController(text: reward?.title ?? '');
    final descriptionController = TextEditingController(
      text: reward?.description ?? '',
    );
    final priceController = TextEditingController(
      text: reward?.price.toString() ?? '',
    );
    final iconController = TextEditingController(text: reward?.icon ?? '🎁');

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(reward == null ? tr('Tạo reward', 'Create reward') : tr('Sửa reward', 'Edit reward')),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: iconController,
                  decoration: const InputDecoration(labelText: 'Icon'),
                ),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: tr('Tên reward', 'Reward name')),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: tr('Mô tả', 'Description')),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: tr('Giá coin', 'Coin price')),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(tr('Hủy', 'Cancel')),
            ),
            FilledButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final description = descriptionController.text.trim();
                final icon = iconController.text.trim();
                final price = int.tryParse(priceController.text.trim()) ?? 0;

                if (title.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(tr('Vui lòng nhập tên reward', 'Please enter the reward name'))),
                  );
                  return;
                }

                if (description.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(tr('Vui lòng nhập mô tả reward', 'Please enter the reward description'))),
                  );
                  return;
                }

                if (price <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(tr('Giá coin phải lớn hơn 0', 'Coin price must be greater than 0'))),
                  );
                  return;
                }

                final provider = context.read<RewardProvider>();

                try {
                  debugPrint(
                    'REWARD_SAVE childId=$childId rewardId=${reward?.id} title=$title price=$price',
                  );

                  if (reward == null) {
                    await provider.createRewardForChild(
                      childId: childId,
                      title: title,
                      description: description,
                      price: price,
                      icon: icon.isEmpty ? '🎁' : icon,
                    );
                  } else {
                    await provider.updateRewardForChild(
                      childId: childId,
                      rewardId: reward.id,
                      title: title,
                      description: description,
                      price: price,
                      icon: icon.isEmpty ? '🎁' : icon,
                    );
                  }

                  debugPrint('REWARD_SAVE_SUCCESS');

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(tr('Đã lưu reward', 'Reward saved'))),
                    );
                  }
                } catch (e) {
                  debugPrint('REWARD_SAVE_ERROR: $e');

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(tr('Lỗi lưu reward: $e', 'Save reward error: $e'))),
                    );
                  }
                }
              },
              child: Text(tr('Lưu', 'Save')),
            ),
          ],
        );
      },
    );

    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    iconController.dispose();
  }

  Widget statCard({
    required String icon,
    required String value,
    required String label,
  }) {
    return Container(
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
    );
  }

  Widget rewardCard(BuildContext context, RewardModel reward, String childId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: reward.redeemed ? Colors.white : const Color(0xfffff7e8),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: reward.redeemed
              ? const Color(0xfff0e7fb)
              : const Color(0xffffe0a9),
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: reward.redeemed
                            ? const Color(0xfff1edf5)
                            : const Color(0xffe7ffe9),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        reward.redeemed ? 'Redeemed' : 'Available',
                        style: TextStyle(
                          color: reward.redeemed
                              ? const Color(0xff8b7c99)
                              : const Color(0xff1c9b43),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () =>
                showRewardDialog(context, childId: childId, reward: reward),
            icon: const Icon(Icons.edit, color: Color(0xff7048ff)),
          ),
          IconButton(
            onPressed: () async {
              try {
                debugPrint(
                  'REWARD_DELETE childId=$childId rewardId=${reward.id}',
                );

                await context.read<RewardProvider>().deleteRewardForChild(
                  childId: childId,
                  rewardId: reward.id,
                );

                debugPrint('REWARD_DELETE_SUCCESS');

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(tr('Đã xóa reward', 'Reward deleted'))),
                  );
                }
              } catch (e) {
                debugPrint('REWARD_DELETE_ERROR: $e');

                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(tr('Lỗi xóa reward: $e', 'Delete reward error: $e'))));
                }
              }
            },
            icon: const Icon(Icons.delete, color: Color(0xffd94343)),
          ),
        ],
      ),
    );
  }

  ImageProvider? _avatarProvider(String? avatar) {
    if (avatar == null || avatar.trim().isEmpty) return null;

    try {
      var cleanAvatar = avatar.trim();

      if (cleanAvatar.contains(',')) {
        cleanAvatar = cleanAvatar.split(',').last;
      }

      cleanAvatar = cleanAvatar.replaceAll(RegExp(r'\s+'), '');

      return MemoryImage(base64Decode(cleanAvatar));
    } catch (_) {
      return null;
    }
  }

  Widget childRewardChip({
    required Map<String, dynamic> child,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final childName = (child['username'] ?? child['email'] ?? 'Child')
        .toString();

    final avatar =
        (child['avatar'] ??
                child['avatarBase64'] ??
                child['avatarUrl'] ??
                child['photoUrl'] ??
                child['image'])
            ?.toString();

    final avatarProvider = _avatarProvider(avatar);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 104,
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : const Color(0xffffb45c),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? Colors.white : const Color(0xffffd092),
            width: selected ? 3 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: Container(
                width: 54,
                height: 54,
                color: Colors.white,
                child: avatarProvider == null
                    ? const Center(
                        child: Text('🧒', style: TextStyle(fontSize: 24)),
                      )
                    : Image(
                        image: avatarProvider,
                        width: 54,
                        height: 54,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                      ),
              ),
            ),
            const SizedBox(height: 8),
            if (selected) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xffff8a00),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Text(
                  'Selected',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 7),
            ],
            Text(
              childName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? const Color(0xffff8a00) : Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>();
    final rewardProvider = context.watch<RewardProvider>();
    final rewards = rewardProvider.rewards;

    final familyProvider = context.watch<FamilyProvider>();

    if (!_startedFamilyListen) {
      _startedFamilyListen = true;
      final familyReader = context.read<FamilyProvider>();

      Future.microtask(() {
        if (!mounted) return;
        familyReader.listenToLinkedChildren();
      });
    }

    final childIds = familyProvider.children
        .map((child) => (child['uid'] ?? child['id'])?.toString())
        .whereType<String>()
        .toList();

    if (_selectedChildId == null && childIds.isNotEmpty) {
      _selectedChildId = childIds.first;
    }

    if (_selectedChildId != null && !childIds.contains(_selectedChildId)) {
      _selectedChildId = childIds.isNotEmpty ? childIds.first : null;
    }

    final selectedChildId = _selectedChildId;

    if (selectedChildId != null) {
      final rewardReader = context.read<RewardProvider>();

      Future.microtask(() {
        if (!mounted) return;
        rewardReader.listenRewardsForChild(selectedChildId);
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
                children: [
                  _topButton('←', () => Navigator.pop(context)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          tr('Quản lý phần thưởng', 'Reward management'),
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
                          tr('Hệ thống phần thưởng cho bé', 'Reward system for your child'),
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
                  _topButton(
                    '+',
                    selectedChildId == null
                        ? () {}
                        : () => showRewardDialog(
                            context,
                            childId: selectedChildId,
                          ),
                  ),
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
                      color: const Color(0xffff9f43).withValues(alpha: 0.28),
                      blurRadius: 30,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tr('Tổng phần thưởng', 'Total rewards'),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${rewards.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 46,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        FilledButton(
                          onPressed: selectedChildId == null
                              ? null
                              : () => showRewardDialog(
                                  context,
                                  childId: selectedChildId,
                                ),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xffff8a00),
                          ),
                          child: Text(tr('Thêm phần thưởng', 'Add reward')),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tr('Chọn bé, tạo phần thưởng mới và chỉnh sửa quà tặng riêng cho từng bé.', 'Choose a child, create new rewards and edit gifts for each child.'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    if (familyProvider.children.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: familyProvider.children.map((child) {
                          final childId = (child['uid'] ?? child['id'])
                              .toString();

                          return childRewardChip(
                            child: child,
                            selected: childId == selectedChildId,
                            onTap: () {
                              setState(() {
                                _selectedChildId = childId;
                              });

                              context
                                  .read<RewardProvider>()
                                  .listenRewardsForChild(childId);
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: statCard(
                      icon: '🎁',
                      value: '${rewards.length}',
                      label: tr('Quà tặng', 'Gifts'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: statCard(
                      icon: '✅',
                      value:
                          '${rewards.where((reward) => reward.redeemed).length}',
                      label: tr('Đã đổi', 'Redeemed'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: statCard(
                      icon: '🟢',
                      value:
                          '${rewards.where((reward) => !reward.redeemed).length}',
                      label: tr('Có sẵn', 'Available'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reward Catalog',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xff2d243b),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Manage',
                    style: TextStyle(
                      color: Color(0xffff8a00),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (rewards.isEmpty)
                Text(
                  tr('Chưa có reward', 'No rewards yet'),
                  style: TextStyle(color: Color(0xff8b7c99)),
                )
              else
                Column(
                  children: rewards.map((reward) {
                    return rewardCard(context, reward, selectedChildId!);
                  }).toList(),
                ),
            ],
          ),
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
