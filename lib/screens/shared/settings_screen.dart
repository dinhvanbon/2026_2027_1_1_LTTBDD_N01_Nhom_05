import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/language_provider.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'group_info_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        tileColor: Colors.grey.shade100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }

  Widget buildSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    ValueChanged<bool>? onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged ?? (_) {},
        secondary: Icon(icon, color: Colors.deepPurple),
        title: Text(title),
        subtitle: Text(subtitle),
        tileColor: Colors.grey.shade100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: const Color(0xfffffaff),
      appBar: AppBar(
        title: Text(lang.tr('Cài đặt', 'Settings')),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ActionChip(
              avatar: Text(lang.isEnglish ? '🇬🇧' : '🇻🇳'),
              label: Text(
                lang.isEnglish ? 'EN' : 'VI',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () => lang.toggleLanguage(),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSectionTitle(lang.tr('Thông tin Nhóm', 'Group Information')),
            buildSettingItem(
              icon: Icons.groups,
              title: lang.tr('Thông tin Nhóm 05', 'Group 05 Information'),
              subtitle: lang.tr(
                'Đinh Văn Bốn (22010067) - Lớp N01',
                'Dinh Van Bon (22010067) - Class N01',
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GroupInfoScreen()),
                );
              },
            ),

            buildSectionTitle(lang.tr('Tài khoản', 'Account')),
            buildSettingItem(
              icon: Icons.person,
              title: lang.tr('Thông tin cá nhân', 'Personal Profile'),
              subtitle: lang.tr(
                'Quản lý tên, email và hồ sơ người dùng',
                'Manage user name, email and profile',
              ),
            ),
            buildSettingItem(
              icon: Icons.family_restroom,
              title: lang.tr('Quản lý gia đình', 'Family Management'),
              subtitle: lang.tr(
                'Quản lý phụ huynh và trẻ em trong hệ thống',
                'Manage parents and children in the system',
              ),
            ),

            buildSectionTitle(lang.tr('Ứng dụng', 'Application')),
            buildSwitchItem(
              icon: Icons.notifications,
              title: lang.tr('Thông báo', 'Notifications'),
              subtitle: lang.tr(
                'Nhắc nhiệm vụ, xác nhận và phần thưởng',
                'Task reminders, verifications and rewards',
              ),
              value: true,
            ),
            buildSwitchItem(
              icon: Icons.dark_mode,
              title: lang.tr('Chế độ tối', 'Dark Mode'),
              subtitle: lang.tr(
                'Bật giao diện tối cho ứng dụng',
                'Enable dark theme for the app',
              ),
              value: false,
            ),
            buildSettingItem(
              icon: Icons.language,
              title: lang.tr('Ngôn ngữ (Language)', 'Language (Ngôn ngữ)'),
              subtitle: lang.isEnglish
                  ? 'English (Nhấn để chuyển sang Tiếng Việt)'
                  : 'Tiếng Việt (Tap to switch to English)',
              onTap: () => lang.toggleLanguage(),
            ),

            buildSectionTitle('Gamification'),
            buildSettingItem(
              icon: Icons.star,
              title: lang.tr('Quy tắc EXP / Level', 'EXP / Level Rules'),
              subtitle: lang.tr(
                'Thiết lập điểm kinh nghiệm và cấp độ',
                'Configure experience points and levels',
              ),
            ),
            buildSettingItem(
              icon: Icons.card_giftcard,
              title: lang.tr('Quy tắc Reward', 'Reward Rules'),
              subtitle: lang.tr(
                'Thiết lập coin, thưởng và đổi quà',
                'Configure coins, bonuses and gift redemption',
              ),
            ),
            buildSettingItem(
              icon: Icons.emoji_events,
              title: lang.tr('Thành tựu', 'Achievements'),
              subtitle: lang.tr(
                'Quản lý điều kiện mở khóa thành tựu',
                'Manage achievement unlock conditions',
              ),
            ),

            buildSectionTitle(lang.tr('Dữ liệu', 'Data')),
            buildSettingItem(
              icon: Icons.cloud_sync,
              title: lang.tr('Đồng bộ dữ liệu', 'Data Synchronization'),
              subtitle: lang.tr(
                'Kết nối Firebase / Cloud Firestore thời gian thực',
                'Realtime Firebase / Cloud Firestore sync',
              ),
            ),
            buildSettingItem(
              icon: Icons.backup,
              title: lang.tr('Sao lưu', 'Backup'),
              subtitle: lang.tr(
                'Sao lưu dữ liệu nhiệm vụ và lịch sử',
                'Backup tasks and activity history',
              ),
            ),

            buildSectionTitle(lang.tr('Khác', 'Others')),
            buildSettingItem(
              icon: Icons.info,
              title: lang.tr('Giới thiệu ứng dụng', 'About Application'),
              subtitle: lang.tr(
                'Life RPG - Quản lý nhiệm vụ hóa trò chơi',
                'Life RPG - Gamified Task Management',
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GroupInfoScreen()),
                );
              },
            ),
            buildSettingItem(
              icon: Icons.logout,
              title: lang.tr('Đăng xuất', 'Log Out'),
              subtitle: lang.tr(
                'Đăng xuất khỏi tài khoản hiện tại',
                'Sign out of current account',
              ),
              onTap: () async {
                await AuthService().logout();

                if (!context.mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
