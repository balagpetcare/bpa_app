import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Headlines
  static TextStyle headline1 = const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle headline2 = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body texts
  static TextStyle bodyLarge = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static TextStyle bodyMedium = const TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  // Captions / Small texts
  static TextStyle caption = const TextStyle(
    fontSize: 12,
    color: AppColors.textTertiary,
  );

  // Game / Reward specific
  static TextStyle rewardPoints = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.accentGold,
  );

  static TextStyle taskCompleted = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.successGreen,
  );
}
