import 'package:flutter/material.dart';

/// Central color palette matching the "Ceramic Logic" design brief.
class AppColors {
  static const Color background = Color(0xFFF1F4F9);
  static const Color surface = Colors.white;
  static const Color primaryBlue = Color(0xFF3B5BFE);
  static const Color primaryLight = Color(0xFFD6DEFF);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color textMain = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color cardGradientStart = Color(0xFF3B5BFE);
  static const Color cardGradientEnd = Color(0xFF6C8CFF);
  static const Color chartReached = Color(0xFF3B5BFE);
  static const Color chartTarget = Color(0xFFD6DEFF);
  static const Color chartCurrent = Color(0xFF0F172A);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [cardGradientStart, cardGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
