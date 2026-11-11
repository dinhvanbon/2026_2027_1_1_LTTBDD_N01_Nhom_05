import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/achievement_model.dart';

class AchievementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User chưa đăng nhập');
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _achievementRef {
    return _firestore.collection('users').doc(_uid).collection('achievements');
  }

  Stream<List<AchievementModel>> getAchievementsStream() {
    return _achievementRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return AchievementModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> seedDefaultAchievementsIfNeeded() async {
    final snapshot = await _achievementRef.limit(1).get();

    if (snapshot.docs.isNotEmpty) {
      return;
    }

    final achievements = [
      const AchievementModel(
        id: 'beginner',
        title: 'Beginner',
        description: 'Hoàn thành nhiệm vụ đầu tiên',
        requiredLevel: 1,
        unlocked: false,
      ),
      const AchievementModel(
        id: 'task_master',
        title: 'Task Master',
        description: 'Đạt level 3',
        requiredLevel: 3,
        unlocked: false,
      ),
      const AchievementModel(
        id: 'rpg_hero',
        title: 'RPG Hero',
        description: 'Đạt level 5',
        requiredLevel: 5,
        unlocked: false,
      ),
    ];

    for (final achievement in achievements) {
      await _achievementRef.doc(achievement.id).set(achievement.toMap());
    }
  }

  Future<void> unlockAchievement(String achievementId) async {
    await _achievementRef.doc(achievementId).update({
      'unlocked': true,
      'unlockedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> unlockAchievementForChild({
    required String childId,
    required String achievementId,
  }) async {
    await _firestore
        .collection('users')
        .doc(childId)
        .collection('achievements')
        .doc(achievementId)
        .update({'unlocked': true, 'unlockedAt': FieldValue.serverTimestamp()});
  }

  Future<List<AchievementModel>> getAchievementsForChild(String childId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(childId)
        .collection('achievements')
        .get();

    return snapshot.docs.map((doc) {
      return AchievementModel.fromMap(doc.id, doc.data());
    }).toList();
  }

  Stream<List<AchievementModel>> getAchievementsStreamForChild(String childId) {
    return _firestore
        .collection('users')
        .doc(childId)
        .collection('achievements')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return AchievementModel.fromMap(doc.id, doc.data());
          }).toList();
        });
  }
}
