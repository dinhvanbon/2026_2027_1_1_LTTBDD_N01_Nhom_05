/// Tiện ích gợi ý điểm EXP và số xu thưởng theo độ khó nhiệm vụ.
class RewardUtils {
  RewardUtils._();

  static int suggestedExp(String difficulty) {
    switch (difficulty) {
      case 'Khó':
      case 'Hard':
        return 60;
      case 'Trung bình':
      case 'Medium':
        return 40;
      default:
        return 20;
    }
  }

  static int suggestedCoins(String difficulty) {
    switch (difficulty) {
      case 'Khó':
      case 'Hard':
        return 30;
      case 'Trung bình':
      case 'Medium':
        return 20;
      default:
        return 10;
    }
  }

  static bool canRedeem(int currentCoins, int cost) {
    return cost > 0 && currentCoins >= cost;
  }
}
