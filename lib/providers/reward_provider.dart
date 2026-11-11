import 'dart:async';

import 'package:flutter/material.dart';

import '../models/reward_model.dart';
import '../services/reward_service.dart';

class RewardProvider extends ChangeNotifier {
  final RewardService _rewardService = RewardService();

  StreamSubscription<List<RewardModel>>? _rewardSubscription;
  StreamSubscription<int>? _coinsSubscription;

  int coins = 0;

  List<RewardModel> _rewards = [];
  final List<RewardModel> _history = [];

  List<RewardModel> get rewards => _rewards;

  List<RewardModel> get history => List.unmodifiable(_history.reversed);

  int get redeemedCount => _history.length;

  bool canRedeem(int price) {
    return coins >= price;
  }

  Future<void> initRewards() async {
    await _rewardService.seedDefaultRewardsIfNeeded();

    _rewardSubscription?.cancel();

    _rewardSubscription = _rewardService.getRewardsStream().listen((rewards) {
      _rewards = rewards;
      notifyListeners();
    });

    _coinsSubscription?.cancel();

    _coinsSubscription = _rewardService.getCoinsStream().listen((value) {
      coins = value;
      notifyListeners();
    });
  }

  void listenRewardsForChild(String childId) {
    _rewardSubscription?.cancel();
    _coinsSubscription?.cancel();

    _rewardSubscription = _rewardService
        .getRewardsStreamForChild(childId)
        .listen((rewards) {
          _rewards = rewards;
          notifyListeners();
        });

    _coinsSubscription = _rewardService.getCoinsStreamForChild(childId).listen((
      value,
    ) {
      coins = value;
      notifyListeners();
    });
  }

  void setCoins(int value) {
    coins = value;
    notifyListeners();
  }

  void addCoins(int amount) {
    coins += amount;
    notifyListeners();
  }

  Future<void> redeemReward(String rewardId) async {
    final reward = _rewards.firstWhere((reward) => reward.id == rewardId);

    if (coins < reward.price) return;

    await _rewardService.redeemReward(reward: reward);

    coins -= reward.price;
    _history.add(reward.copyWith(redeemed: true));

    notifyListeners();
  }

  Future<void> createReward({
    required String title,
    required String description,
    required int price,
    required String icon,
  }) async {
    await _rewardService.createReward(
      title: title,
      description: description,
      price: price,
      icon: icon,
    );
  }

  Future<void> updateReward({
    required String rewardId,
    required String title,
    required String description,
    required int price,
    required String icon,
  }) async {
    await _rewardService.updateReward(
      rewardId: rewardId,
      title: title,
      description: description,
      price: price,
      icon: icon,
    );
  }

  Future<void> deleteReward(String rewardId) async {
    await _rewardService.deleteReward(rewardId);
  }

  Future<void> createRewardForChild({
    required String childId,
    required String title,
    required String description,
    required int price,
    required String icon,
  }) async {
    await _rewardService.createRewardForChild(
      childId: childId,
      title: title,
      description: description,
      price: price,
      icon: icon,
    );
  }

  Future<void> updateRewardForChild({
    required String childId,
    required String rewardId,
    required String title,
    required String description,
    required int price,
    required String icon,
  }) async {
    await _rewardService.updateRewardForChild(
      childId: childId,
      rewardId: rewardId,
      title: title,
      description: description,
      price: price,
      icon: icon,
    );
  }

  Future<void> deleteRewardForChild({
    required String childId,
    required String rewardId,
  }) async {
    await _rewardService.deleteRewardForChild(
      childId: childId,
      rewardId: rewardId,
    );
  }

  @override
  void dispose() {
    _rewardSubscription?.cancel();
    _coinsSubscription?.cancel();
    super.dispose();
  }
}
