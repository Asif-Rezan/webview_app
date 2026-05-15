import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Light theme colors
  static const Color primary = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF388E3C);
  static const Color background = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);

  // Text colors for light theme
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);

  // Text colors for dark theme (improved readability)
  static const Color textPrimaryDark = Color(0xFFE0E0E0);   // Softer than pure white
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  // Profile Card Colors
  static const Color contact = Color(0xFF3B82F6);
  static const Color personal = Color(0xFF8B5CF6);
  static const Color address = Color(0xFF10B981);
  static const Color additional = Color(0xFFF59E0B);

  // ─── Subject Color Palette ─────────────────────────────────────────────────
  static const List<Color> subjectPalette = [
    Color(0xFF6C63FF), // violet
    Color(0xFFFF6B6B), // coral
    Color(0xFF4CAF50), // green
    Color(0xFFFF9800), // orange
    Color(0xFF00BCD4), // cyan
    Color(0xFF9C27B0), // purple
    Color(0xFF2196F3), // blue
    Color(0xFFE91E63), // pink
    Color(0xFF009688), // teal
    Color(0xFFFF5722), // deep-orange
  ];
  static Color getSubjectColor(String subject) {
    if (subject.isEmpty) return subjectPalette[0];
    return subjectPalette[subject.codeUnitAt(0) % subjectPalette.length];
  }

  // Helper to get text color based on brightness
  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textPrimaryDark : textPrimaryLight;

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textSecondaryDark : textSecondaryLight;
}