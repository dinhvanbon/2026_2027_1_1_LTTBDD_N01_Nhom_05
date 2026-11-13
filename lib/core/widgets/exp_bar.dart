import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../utils/level_utils.dart';

/// Thanh hiển thị tiến trình kinh nghiệm (EXP Bar) và cấp độ (Level).
class ExpBar extends StatelessWidget {
  final int totalExp;
  final int? level;

  const ExpBar({
    super.key,
    required this.totalExp,
    this.level,
  });

  @override
  Widget build(BuildContext context) {
    final currentLevel = level ?? LevelUtils.calculateLevel(totalExp);
    final inLevelExp = LevelUtils.currentLevelExp(totalExp);
    final progress = LevelUtils.levelProgress(totalExp);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Level $currentLevel',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '$inLevelExp / ${LevelUtils.expPerLevel} EXP',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: AppColors.primaryLight,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }
}
