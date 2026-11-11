import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/language_provider.dart';

class GroupInfoScreen extends StatelessWidget {
  const GroupInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: const Color(0xfffffaff),
      appBar: AppBar(
        title: Text(
          lang.tr('Thông tin Nhóm 05', 'Group 05 Information'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff7048ff), Color(0xff9c6bff)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff7048ff).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Center(
                      child: Text('🎮', style: TextStyle(fontSize: 38)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'LIFE RPG',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    lang.tr(
                      'Hệ thống quản lý nhiệm vụ trẻ em ứng dụng Gamification',
                      'Gamified Children Task Management System',
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoCard(
              title: lang.tr('📚 Thông tin học phần', '📚 Course Information'),
              items: [
                _InfoRow(
                  icon: Icons.school,
                  label: lang.tr('Trường:', 'University:'),
                  value: 'Phenikaa University',
                ),
                _InfoRow(
                  icon: Icons.menu_book,
                  label: lang.tr('Môn học:', 'Course:'),
                  value: lang.tr(
                    'Lập trình cho thiết bị di động',
                    'Mobile Application Development',
                  ),
                ),
                _InfoRow(
                  icon: Icons.code,
                  label: lang.tr('Mã lớp:', 'Class Code:'),
                  value: 'CSE702027-1-1-26(N01)',
                ),
                _InfoRow(
                  icon: Icons.groups,
                  label: lang.tr('Nhóm:', 'Group:'),
                  value: lang.tr('Nhóm 05', 'Group 05'),
                ),
                _InfoRow(
                  icon: Icons.person_pin,
                  label: lang.tr('Giảng viên HD:', 'Instructor:'),
                  value: lang.tr('Thầy Nguyễn Xuân Quế', 'Mr. Nguyen Xuan Que'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: lang.tr('👤 Thành viên thực hiện', '👤 Group Member'),
              items: [
                _InfoRow(
                  icon: Icons.badge,
                  label: lang.tr('Họ và tên:', 'Full Name:'),
                  value: 'Đinh Văn Bốn',
                ),
                _InfoRow(
                  icon: Icons.numbers,
                  label: lang.tr('Mã sinh viên:', 'Student ID:'),
                  value: '22010067',
                ),
                _InfoRow(
                  icon: Icons.email,
                  label: 'Email:',
                  value: '22010067@st.phenikaa-uni.edu.vn',
                ),
                _InfoRow(
                  icon: Icons.verified_user,
                  label: lang.tr('Vai trò:', 'Role:'),
                  value: lang.tr(
                    'Phát triển toàn diện (Fullstack Flutter & Firebase)',
                    'Fullstack Flutter & Firebase Developer',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: lang.tr('🛠️ Công nghệ sử dụng', '🛠️ Tech Stack'),
              items: [
                _InfoRow(
                  icon: Icons.phone_android,
                  label: 'Frontend:',
                  value: 'Flutter & Material Design 3',
                ),
                _InfoRow(
                  icon: Icons.cloud,
                  label: 'Backend:',
                  value: 'Firebase Auth & Cloud Firestore',
                ),
                _InfoRow(
                  icon: Icons.layers,
                  label: 'State Management:',
                  value: 'Provider Architecture',
                ),
                _InfoRow(
                  icon: Icons.translate,
                  label: lang.tr('Đa ngôn ngữ:', 'Languages:'),
                  value: lang.tr('Tiếng Việt & Tiếng Anh', 'Vietnamese & English'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<_InfoRow> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xffeee3fb)),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xff2d243b),
            ),
          ),
          const Divider(height: 22),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(item.icon, size: 20, color: const Color(0xff7048ff)),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 110,
                    child: Text(
                      item.label,
                      style: const TextStyle(
                        color: Color(0xff6b5e7a),
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.value,
                      style: const TextStyle(
                        color: Color(0xff2d243b),
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
}

