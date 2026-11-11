import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/reward_model.dart';

class RewardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User chưa đăng nhập');
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _rewardsRef {
    return _firestore.collection('users').doc(_uid).collection('rewards');
  }

  CollectionReference<Map<String, dynamic>> rewardsRefForChild(String childId) {
    return _firestore.collection('users').doc(childId).collection('rewards');
  }

  Stream<List<RewardModel>> getRewardsStream() {
    return _rewardsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return RewardModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> seedDefaultRewardsIfNeeded() async {
    final snapshot = await _rewardsRef.limit(1).get();

    if (snapshot.docs.isNotEmpty) {
      return;
    }

    final defaultRewards = [
      const RewardModel(
        id: '1',
        title: 'Favorite Meal',
        description: 'Đổi một bữa ăn yêu thích cuối tuần.',
        price: 300,
        icon: '🍔',
        redeemed: false,
      ),
      const RewardModel(
        id: '2',
        title: 'Gaming Time',
        description: 'Thêm 1 giờ chơi game sau khi học xong.',
        price: 500,
        icon: '🎮',
        redeemed: false,
      ),
      const RewardModel(
        id: '3',
        title: 'Movie Night',
        description: 'Một buổi xem phim cùng gia đình.',
        price: 800,
        icon: '🍿',
        redeemed: false,
      ),
      const RewardModel(
        id: '4',
        title: 'New Headphone',
        description: 'Phần thưởng đặc biệt cần nhiều coin hơn.',
        price: 1500,
        icon: '🎧',
        redeemed: false,
      ),
    ];

    for (final reward in defaultRewards) {
      await _rewardsRef.doc(reward.id).set(reward.toMap());
    }
  }

  Future<void> redeemReward({required RewardModel reward}) async {
    final userRef = _firestore.collection('users').doc(_uid);
    final rewardRef = userRef.collection('rewards').doc(reward.id);
    final historyRef = userRef.collection('rewardHistory').doc();

    await _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);

      final currentCoins = (userSnapshot.data()?['coins'] ?? 0).toInt();

      if (currentCoins < reward.price) {
        throw Exception('Không đủ coins để đổi thưởng');
      }

      transaction.set(userRef, {
        'coins': currentCoins - reward.price,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      transaction.update(rewardRef, {
        'redeemed': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.set(historyRef, {
        ...reward.toMap(),
        'rewardId': reward.id,
        'redeemedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Stream<int> getCoinsStream() {
    return _firestore.collection('users').doc(_uid).snapshots().map((doc) {
      final data = doc.data();

      if (data == null) return 0;

      return data['coins'] ?? 0;
    });
  }

  Stream<int> getCoinsStreamForChild(String childId) {
    return _firestore.collection('users').doc(childId).snapshots().map((doc) {
      final data = doc.data();

      if (data == null) return 0;

      return (data['coins'] ?? 0).toInt();
    });
  }

  Future<void> createReward({
    required String title,
    required String description,
    required int price,
    required String icon,
  }) async {
    await _rewardsRef.add({
      'title': title,
      'description': description,
      'price': price,
      'icon': icon,
      'redeemed': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateReward({
    required String rewardId,
    required String title,
    required String description,
    required int price,
    required String icon,
  }) async {
    await _rewardsRef.doc(rewardId).update({
      'title': title,
      'description': description,
      'price': price,
      'icon': icon,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteReward(String rewardId) async {
    await _rewardsRef.doc(rewardId).delete();
  }

  Future<void> createRewardForChild({
    required String childId,
    required String title,
    required String description,
    required int price,
    required String icon,
  }) async {
    await rewardsRefForChild(childId).add({
      'title': title,
      'description': description,
      'price': price,
      'icon': icon,
      'redeemed': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateRewardForChild({
    required String childId,
    required String rewardId,
    required String title,
    required String description,
    required int price,
    required String icon,
  }) async {
    await rewardsRefForChild(childId).doc(rewardId).set({
      'title': title,
      'description': description,
      'price': price,
      'icon': icon,
      'redeemed': false,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteRewardForChild({
    required String childId,
    required String rewardId,
  }) async {
    await rewardsRefForChild(childId).doc(rewardId).delete();
  }

  Stream<List<RewardModel>> getRewardsStreamForChild(String childId) {
    return rewardsRefForChild(childId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return RewardModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }
}
