import 'dart:async';

import 'package:flutter/material.dart';

import '../models/achievement_model.dart';
import '../services/achievement_service.dart';

class AchievementProvider extends ChangeNotifier {
  final AchievementService _achievementService = AchievementService();

  StreamSubscription<List<AchievementModel>>? _achievementSubscription;

  List<AchievementModel> _achievements = [];

  List<AchievementModel> get achievements => _achievements;

  Future<void> initAchievements() async {
    await _achievementService.seedDefaultAchievementsIfNeeded();

    _achievementSubscription?.cancel();

    _achievementSubscription =
        _achievementService.getAchievementsStream().listen((achievements) {
      _achievements = achievements;
      notifyListeners();
    });
  }
  void listenAchievementsForChild(String childId) {
  _achievementSubscription?.cancel();

  _achievementSubscription = _achievementService
      .getAchievementsStreamForChild(childId)
      .listen((achievements) {
    _achievements = achievements;
    notifyListeners();
  });
}

  Future<List<String>> checkAchievements({
  required String childId,
  required int level,
}) async {
  final List<String> unlockedAchievements = [];

  final achievements =
      await _achievementService.getAchievementsForChild(childId);

  for (final achievement in achievements) {
    if (level >= achievement.requiredLevel &&
        achievement.unlocked == false) {
      await _achievementService.unlockAchievementForChild(
        childId: childId,
        achievementId: achievement.id,
      );

      unlockedAchievements.add(achievement.title);
    }
  }

  return unlockedAchievements;
}

  @override
  void dispose() {
    _achievementSubscription?.cancel();
    super.dispose();
  }
}