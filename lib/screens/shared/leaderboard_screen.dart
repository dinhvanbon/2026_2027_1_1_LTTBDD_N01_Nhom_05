import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../providers/language_provider.dart';
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  Stream<QuerySnapshot<Map<String, dynamic>>> _childrenStream() {
    final parentId = FirebaseAuth.instance.currentUser?.uid;

    if (parentId == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('children')
        .where('parentId', isEqualTo: parentId)
        .snapshots();
  }

  int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  String _name(Map<String, dynamic> data) {
    final username = data['username']?.toString() ?? '';
    if (username.isNotEmpty) return username;

    final email = data['email']?.toString() ?? '';
    if (email.isNotEmpty) return email;

    return 'Child';
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

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _sortChildren(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final sorted = [...docs];

    sorted.sort((a, b) {
      final aData = a.data();
      final bData = b.data();

      final aLevel = _asInt(aData['level']);
      final bLevel = _asInt(bData['level']);

      final aExp = _asInt(aData['exp']);
      final bExp = _asInt(bData['exp']);

      final aCoins = _asInt(aData['coins']);
      final bCoins = _asInt(bData['coins']);

      final byLevel = bLevel.compareTo(aLevel);
      if (byLevel != 0) return byLevel;

      final byExp = bExp.compareTo(aExp);
      if (byExp != 0) return byExp;

      return bCoins.compareTo(aCoins);
    });

    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>();
    return Scaffold(
      backgroundColor: const Color(0xfffffaff),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.2,
              colors: [Color(0xffefe5ff), Color(0xffffffff)],
            ),
          ),
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _childrenStream(),
            builder: (context, snapshot) {
              final children = _sortChildren(snapshot.data?.docs ?? []);

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 25, 20, 40),
                child: Column(
                  children: [
                    _title(context),
                    const SizedBox(height: 25),
                    if (children.isEmpty)
                      _emptyCard()
                    else ...[
                      _rankOne(children.first),
                      const SizedBox(height: 25),
                      ...children.asMap().entries.map((entry) {
                        final rank = entry.key + 1;
                        return _rankCard(rank: rank, doc: entry.value);
                      }),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _title(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.maybePop(context),
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
            child: const Icon(Icons.arrow_back, color: Color(0xff2d243b)),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                tr('Bảng xếp hạng', 'Leaderboard'),
                style: TextStyle(
                  color: Color(0xff2d243b),
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                tr('Xếp hạng trong gia đình', 'Family ranking'),
                style: TextStyle(color: Color(0xff8b7c99), fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(width: 44),
      ],
    );
  }

  Widget _rankOne(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    final name = _name(data);
    final level = _asInt(data['level']);
    final exp = _asInt(data['exp']);
    final avatarBytes = _decodeAvatar(data['avatar']);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xffffb347), Color(0xffff7b54)],
        ),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: const Color(0xffff9646).withValues(alpha: 0.35),
            blurRadius: 35,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.workspace_premium, color: Colors.white, size: 46),
          const SizedBox(height: 10),
          _avatar(
            avatarBytes: avatarBytes,
            size: 100,
            radius: 35,
            fallbackSize: 55,
            topOne: true,
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
          const SizedBox(height: 6),
          Text(
            tr('Chiến binh Cấp $level', 'Level $level Warrior'),
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Text(
            '⭐ $exp EXP',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rankCard({
    required int rank,
    required QueryDocumentSnapshot<Map<String, dynamic>> doc,
  }) {
    final data = doc.data();

    final name = _name(data);
    final level = _asInt(data['level']);
    final exp = _asInt(data['exp']);
    final avatarBytes = _decodeAvatar(data['avatar']);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff502d82).withValues(alpha: 0.10),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(
              '#$rank',
              style: const TextStyle(
                color: Color(0xff7048ff),
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          _avatar(
            avatarBytes: avatarBytes,
            size: 55,
            radius: 20,
            fallbackSize: 28,
            topOne: false,
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
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$exp EXP',
                  style: const TextStyle(
                    color: Color(0xff8b7c99),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
    );
  }

  Widget _avatar({
    required Uint8List? avatarBytes,
    required double size,
    required double radius,
    required double fallbackSize,
    required bool topOne,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: avatarBytes == null
            ? topOne
                  ? Colors.white.withValues(alpha: 0.30)
                  : const Color(0xffefe7ff)
            : null,
        borderRadius: BorderRadius.circular(radius),
      ),
      clipBehavior: Clip.antiAlias,
      child: avatarBytes == null
          ? Icon(
              Icons.child_care,
              color: topOne ? Colors.white : const Color(0xff7048ff),
              size: fallbackSize,
            )
          : Image.memory(
              avatarBytes,
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
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
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xff8b7c99)),
      ),
    );
  }
}
