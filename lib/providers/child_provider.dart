import 'package:flutter/material.dart';

class ChildProvider extends ChangeNotifier {
  int exp = 0;
  int level = 1;
  int totalReward = 0;

  int get maxExpForCurrentLevel => level * 100;

  double get expProgress {
    if (maxExpForCurrentLevel == 0) return 0;
    return exp / maxExpForCurrentLevel;
  }

  void addExp(int amount) {
    exp += amount;

    while (exp >= maxExpForCurrentLevel) {
      exp -= maxExpForCurrentLevel;
      level++;
    }

    notifyListeners();
  }

  void addReward(int amount) {
    totalReward += amount;
    notifyListeners();
  }
}
