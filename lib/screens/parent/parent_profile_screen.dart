import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/task_provider.dart';
import '../../providers/child_provider.dart';
import '../shared/settings_screen.dart';
import '../shared/edit_profile_screen.dart';
import '../../services/user_service.dart';
import '../../providers/family_provider.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

import '../../providers/language_provider.dart';
class ParentProfileScreen extends StatelessWidget {
  const ParentProfileScreen({super.key});

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
            GestureDetector(
              onTap: onActionTap,
              child: Text(
                action,
                style: const TextStyle(
                  color: Color(0xff7048ff),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void showAddChildDialog(BuildContext context) {
    final linkCodeController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(tr('Thêm liên kết với Bé', 'Link a child')),
          content: TextField(
            controller: linkCodeController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: tr('Mã liên kết', 'Link code'),
              hintText: tr('Nhập mã liên kết của bé, ví dụ KQFPX5UF', 'Enter the child link code, e.g. KQFPX5UF'),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(tr('Hủy', 'Cancel')),
            ),

            FilledButton(
              onPressed: () async {
                final linkCode = linkCodeController.text.trim();

                if (linkCode.isEmpty) {
                  return;
                }

                try {
                  await context.read<FamilyProvider>().linkChildByCode(
                    linkCode,
                  );

                  if (!context.mounted) return;

                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(tr('Liên kết Child thành công', 'Child linked successfully'))),
                  );
                } catch (e) {
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(tr('Lỗi: $e', 'Error: $e'))));
                }
              },

              child: Text(tr('Liên kết', 'Link')),
            ),
          ],
        );
      },
    );
  }

  Widget infoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xfff3edf8))),
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

  Widget settingCard({
    required String icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xfff0e7fb)),
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
    );
  }

  Widget childCard({
    required String icon,
    required String name,
    required String level,
    required double progress,
    required VoidCallback onUnlink,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xfff0e7fb)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xffffb347), Color(0xffff7b54)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  '$level • EXP Progress',
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
                    backgroundColor: const Color(0xffeee7f7),
                    color: const Color(0xff7048ff),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: onUnlink,
            icon: const Icon(Icons.link_off, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final childProvider = context.watch<ChildProvider>();
    final familyProvider = context.watch<FamilyProvider>();

    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (currentUid.isNotEmpty && !familyProvider.hasChildren) {
      Future.microtask(() {
        if (context.mounted) {
          context.read<FamilyProvider>().listenToLinkedChildren();
        }
      });
    }

    return FutureBuilder<Map<String, dynamic>?>(
      key: ValueKey(currentUid),
      future: UserService().getCurrentParentProfile(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text(tr('Lỗi tải profile: ${snapshot.error}', 'Profile loading error: ${snapshot.error}'))),
          );
        }

        if (snapshot.data == null) {
          return Scaffold(
            body: Center(
              child: Text(tr('Không tìm thấy thông tin Parent Profile', 'Parent profile not found')),
            ),
          );
        }

        final user = snapshot.data!;

        final username = user['username'] ?? 'User';

        final email =
            user['email'] ?? FirebaseAuth.instance.currentUser?.email ?? '';

        final phone = user['phone'] ?? '';

        final avatar = user['avatar'] as String?;

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
                      Column(
                        children: [
                          Text(
                            'Parent Profile',
                            style: TextStyle(
                              fontSize: 22,
                              color: Color(0xff2d243b),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            tr('Thông tin phụ huynh', 'Parent information'),
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
                        colors: [Color(0xff7048ff), Color(0xff9d72ff)],
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
                              ? const Text(
                                  '👨‍👧',
                                  style: TextStyle(fontSize: 50),
                                )
                              : null,
                        ),
                        SizedBox(height: 14),
                        Text(
                          username,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          tr('Parent Account\nQuản lý nhiệm vụ, xác nhận và trao thưởng cho con', 'Parent Account\nManage quests, approve and reward your child'),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: statCard(
                          icon: '👦',
                          value: '${familyProvider.children.length}',
                          label: tr('Số bé', 'Children'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: statCard(
                          icon: '📋',
                          value: '${taskProvider.tasks.length}',
                          label: tr('Nhiệm vụ', 'Quests'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: statCard(
                          icon: '🎁',
                          value: '${childProvider.totalReward}',
                          label: tr('Quà tặng', 'Gifts'),
                        ),
                      ),
                    ],
                  ),
                  sectionTitle(tr('Thông tin tài khoản', 'Account information'), action: tr('Sửa', 'Edit')),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: const Color(0xfff0e7fb)),
                    ),
                    child: Column(
                      children: [
                        infoRow('Email', email),
                        infoRow(tr('Số điện thoại', 'Phone number'), phone),
                        infoRow(tr('Vai trò', 'Role'), tr('Phụ huynh', 'Parent')),
                        infoRow(tr('Ngày tham gia', 'Joined'), tr('Học kỳ I 2026', 'Semester I 2026')),
                      ],
                    ),
                  ),
                  sectionTitle(
                    tr('Danh sách các bé', 'Children list'),
                    action: tr('Thêm bé', 'Add child'),
                    onActionTap: () {
                      showAddChildDialog(context);
                    },
                  ),

                  ...familyProvider.children.map((child) {
                    return childCard(
                      icon: '🧒',
                      name: child['username'] ?? tr('Bé', 'Child'),
                      level: tr('Cấp ${child['level'] ?? 1}', 'Level ${child[\'level\'] ?? 1}'),
                      progress: ((child['exp'] ?? 0) / 100).clamp(0, 1),
                      onUnlink: () async {
                        await context.read<FamilyProvider>().unlinkChild(
                          child['uid'],
                        );

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(tr('Đã hủy liên kết với bé', 'Child unlinked')),
                          ),
                        );
                      },
                    );
                  }),
                  sectionTitle(tr('Cài đặt', 'Settings')),
                  settingCard(
                    icon: '🔔',
                    title: tr('Thông báo', 'Notifications'),
                    subtitle: tr('Nhận thông báo khi con hoàn thành nhiệm vụ', 'Get notified when your child completes a quest'),
                  ),
                  settingCard(
                    icon: '🌙',
                    title: tr('Chế độ tối (Dark Mode)', 'Dark Mode'),
                    subtitle: tr('Tùy chỉnh giao diện hiển thị', 'Customize the display theme'),
                  ),
                  FilledButton(
                    onPressed: () async {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfileScreen(
                            username: username,
                            phone: phone,
                            role: 'parent',
                            accentColorHex: 'purple',
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
                      backgroundColor: const Color(0xff7048ff),
                    ),
                    child: Text(tr('Chỉnh sửa thông tin', 'Edit profile')),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () async {
                      context.read<FamilyProvider>().clear();

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );

                      await AuthService().logout();
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
}
