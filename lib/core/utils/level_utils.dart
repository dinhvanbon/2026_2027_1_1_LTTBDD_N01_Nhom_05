/// Tiện ích tính toán cấp độ (Level) và tiến trình kinh nghiệm (EXP).
class LevelUtils {
  LevelUtils._();

  static const int expPerLevel = 100;

  static int calculateLevel(int totalExp) {
    if (totalExp <= 0) return 1;
    return (totalExp ~/ expPerLevel) + 1;
  }

  static int currentLevelExp(int totalExp) {
    if (totalExp <= 0) return 0;
    return totalExp % expPerLevel;
  }

  static double levelProgress(int totalExp) {
    return (currentLevelExp(totalExp) / expPerLevel).clamp(0.0, 1.0);
  }
}
