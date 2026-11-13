import 'package:flutter/material.dart';

import '../core/utils/level_utils.dart';

/// Provider tính toán điểm kinh nghiệm (EXP), cấp độ (Level) và tiến trình Gamification.
class GamificationProvider extends ChangeNotifier {
  int _totalExp = 0;
  int _coins = 0;

  int get totalExp => _totalExp;
  int get coins => _coins;
  int get level => LevelUtils.calculateLevel(_totalExp);
  int get currentLevelExp => LevelUtils.currentLevelExp(_totalExp);
  double get progress => LevelUtils.levelProgress(_totalExp);

  void updateStats({required int exp, required int coins}) {
    _totalExp = exp;
    _coins = coins;
    notifyListeners();
  }

  void addReward({required int expGain, required int coinGain}) {
    _totalExp += expGain;
    _coins += coinGain;
    notifyListeners();
  }
}
