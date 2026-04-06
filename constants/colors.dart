import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors
  static const primary = Color(0xFF1C4F45);
  static const primaryMedium = Color(0xFF2A7A65);

  // Backgrounds
  static const white = Color(0xFFFFFFFF);
  static const background = Color(0xFFF5F7F6);

  // Text
  static const textPrimary = Color(0xFF0D1B16);
  static const textSecondary = Color(0xFF5E6E68);
  static const textTertiary = Color(0xFF8FA39B);

  // Border & surface
  static const border = Color(0xFFE8ECEA);
  static const mintTint = Color(0xFFE6F5F0);

  // Status
  static const success = Color(0xFF2ECC70);
  static const error = Color(0xFFE74C3C);

  // Legacy aliases kept for backward compatibility
  static const navy = primary;
  static const green = primaryMedium;
  static const blue = border;
  static const grey = background;
  static const customGreen = mintTint;
  static const mediumGrey = textSecondary;
  static const darkerGrey = textSecondary;
  static const transactionBlue = Color(0xFF1976D2);
  static const transactionBlack = textPrimary;
}
