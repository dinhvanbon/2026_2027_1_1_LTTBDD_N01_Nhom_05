import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/task_provider.dart';
import '../../providers/family_provider.dart';
import 'child_detail_profile_screen.dart';

import '../../providers/language_provider.dart';
class ManageChildScreen extends StatefulWidget {
  const ManageChildScreen({super.key});

  @override
  State<ManageChildScreen> createState() => _ManageChildScreenState();
}

class _ManageChildScreenState extends State<ManageChildScreen> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
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
    final tasks = context.watch<TaskProvider>().tasks;

    return Scaffold(
      backgroundColor: const Color(0xfffffaff),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _childrenStream(),
          builder: (context, snapshot) {
            final children = snapshot.data?.docs ?? [];

            final totalExp = children.fold<int>(
              0,
              (total, doc) => total + _asInt(doc.data()['exp']),
            );

            final totalTasks = tasks.length;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(context),
                  const SizedBox(height: 20),
                  _linkCodeCard(context),
                  _hero(children.length),
                  _stats(
                    totalExp: totalExp,
                    totalTasks: totalTasks,
                    children: children,
                  ),
                  const SizedBox(height: 8),
                  if (children.isEmpty)
                    _emptyCard()
                  else
                    ...children.map((doc) {
                      return _childCard(
                        childId: doc.id,
                        data: doc.data(),
                        completedTasks: tasks
                            .where(
                              (task) =>
                                  task.childId == doc.id &&
                                  task.status.name == 'approved',
                            )
                            .length,
                      );
                    }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _linkCodeCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          TextField(
            controller: _codeController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: tr('Nhập mã liên kết của con (VD: KQ123ABC)', 'Enter your child link code (e.g. KQ123ABC)'),
              prefixIcon: const Icon(Icons.link),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                try {
                  await context.read<FamilyProvider>().linkChildByCode(
                    _codeController.text,
                  );

                  _codeController.clear();

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          tr('Liên kết thành công', 'Linked successfully'),
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                }
              },
              child: Text(tr('Liên kết với bé', 'Link with child')),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final nameController = TextEditingController(text: 'Bé Bi');
                final createdName = await showDialog<String>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(
                      tr('Tạo nhanh hồ sơ Bé', 'Quick Create Child Profile'),
                    ),
                    content: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: tr('Tên của bé', 'Child name'),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(tr('Hủy', 'Cancel')),
                      ),
                      FilledButton(
                        onPressed: () =>
                            Navigator.pop(ctx, nameController.text.trim()),
                        child: Text(tr('Tạo ngay', 'Create now')),
                      ),
                    ],
                  ),
                );
                if (createdName == null || !context.mounted) return;
                await context.read<FamilyProvider>().createQuickChild(
                  createdName,
                );
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      tr(
                        'Đã tạo hồ sơ bé "$createdName"!',
                        'Created child profile "$createdName"!',
                      ),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.person_add_alt_1),
              label: Text(
                tr(
                  'Tạo nhanh hồ sơ Bé (không cần mã)',
                  'Quick Create Child (no code needed)',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('Danh sách các bé', 'Children list'),
                style: TextStyle(
                  color: Color(0xff2d243b),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                tr('Quản lý tiến độ của con', 'Manage your child progress'),
                style: TextStyle(color: Color(0xff8b7c99), fontSize: 13),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () => Navigator.maybePop(context),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xff7048ff),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _hero(int count) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff7048ff), Color(0xff9d72ff)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff7048ff).withValues(alpha: 0.30),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            tr('Danh sách các bé đã kết nối với tài khoản gia đình', 'Children connected to the family account'),
            style: TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _stats({
    required int totalExp,
    required int totalTasks,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> children,
  }) {
    final totalCoins = children.fold<int>(
      0,
      (total, doc) => total + _asInt(doc.data()['coins']),
    );

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.95,
      children: [
        _statCard(Icons.star, '$totalExp', tr('Tổng EXP', 'Total EXP')),
        _statCard(Icons.assignment, '$totalTasks', tr('Nhiệm vụ', 'Quests')),
        _statCard(Icons.card_giftcard, '$totalCoins', tr('Vàng', 'Gold')),
      ],
    );
  }

  Widget _statCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xff7048ff), size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

  Widget _childCard({
    required String childId,
    required Map<String, dynamic> data,
    required int completedTasks,
  }) {
    final name = data['username']?.toString().isNotEmpty == true
        ? data['username'].toString()
        : data['email']?.toString() ?? tr('Bé', 'Child');

    final level = _asInt(data['level']);
    final exp = _asInt(data['exp']);
    final coins = _asInt(data['coins']);
    final avatarBytes = _decodeAvatar(data['avatar']);

    final maxExp = (level <= 0 ? 1 : level) * 100;
    final progress = maxExp == 0 ? 0.0 : (exp / maxExp).clamp(0.0, 1.0);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(childId)
          .collection('achievements')
          .where('unlocked', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        final badges = snapshot.data?.docs.length ?? 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 18),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xff502d82).withValues(alpha: 0.10),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      gradient: avatarBytes == null
                          ? const LinearGradient(
                              colors: [Color(0xffffb347), Color(0xffff7b54)],
                            )
                          : null,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: avatarBytes == null
                        ? const Icon(
                            Icons.child_care,
                            color: Colors.white,
                            size: 36,
                          )
                        : Image.memory(
                            avatarBytes,
                            width: 65,
                            height: 65,
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xff2d243b),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tr('$completedTasks nhiệm vụ hoàn thành', '$completedTasks quests completed'),
                          style: const TextStyle(
                            color: Color(0xff8b7c99),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
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
              const SizedBox(height: 15),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: const Color(0xffeee7f7),
                  color: const Color(0xff7048ff),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _childData('$exp', 'EXP')),
                  Expanded(child: _childData('$badges', tr('Huy hiệu', 'Badges'))),
                  Expanded(child: _childData('$coins', tr('Vàng', 'Gold'))),
                ],
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: FilledButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChildDetailProfileScreen(
                          childId: childId,
                          childData: data,
                        ),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xff7048ff),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    tr('Xem hồ sơ', 'View profile'),
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _childData(String value, String label) {
    return Column(
      children: [
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
    );
  }

  Widget _emptyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        tr('Chưa có bé nào được liên kết.', 'No child linked yet.'),
        style: TextStyle(color: Color(0xff8b7c99)),
      ),
    );
  }
}
