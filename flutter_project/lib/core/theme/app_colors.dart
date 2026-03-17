import 'package:flutter/material.dart';

/// Central color palette with light/dark mode support.
class AppColors {
  // Brand colors (shared)
  static const Color primaryBlue = Color(0xFF3B5BFE);
  static const Color primaryLight = Color(0xFFD6DEFF);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color cardGradientStart = Color(0xFF3B5BFE);
  static const Color cardGradientEnd = Color(0xFF6C8CFF);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [cardGradientStart, cardGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Light palette
  static const Color _backgroundLight = Color(0xFFF1F4F9);
  static const Color _surfaceLight = Colors.white;
  static const Color _textMainLight = Color(0xFF0F172A);
  static const Color _textMutedLight = Color(0xFF64748B);
  static const Color _chartTargetLight = Color(0xFFD6DEFF);
  static const Color _chartCurrentLight = Color(0xFF0F172A);

  // Dark palette
  static const Color _backgroundDark = Color(0xFF0F1117);
  static const Color _surfaceDark = Color(0xFF1A1D27);
  static const Color _textMainDark = Color(0xFFE2E8F0);
  static const Color _textMutedDark = Color(0xFF94A3B8);
  static const Color _chartTargetDark = Color(0xFF2A3352);
  static const Color _chartCurrentDark = Color(0xFFE2E8F0);

  // Legacy static accessors (light only) — prefer themed variants below
  static const Color background = _backgroundLight;
  static const Color surface = _surfaceLight;
  static const Color textMain = _textMainLight;
  static const Color textMuted = _textMutedLight;
  static const Color chartReached = primaryBlue;
  static const Color chartTarget = _chartTargetLight;
  static const Color chartCurrent = _chartCurrentLight;

  // ── Theme-aware accessors ──
  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color backgroundOf(BuildContext context) =>
      _isDark(context) ? _backgroundDark : _backgroundLight;

  static Color surfaceOf(BuildContext context) =>
      _isDark(context) ? _surfaceDark : _surfaceLight;

  static Color textMainOf(BuildContext context) =>
      _isDark(context) ? _textMainDark : _textMainLight;

  static Color textMutedOf(BuildContext context) =>
      _isDark(context) ? _textMutedDark : _textMutedLight;

  static Color chartTargetOf(BuildContext context) =>
      _isDark(context) ? _chartTargetDark : _chartTargetLight;

  static Color chartCurrentOf(BuildContext context) =>
      _isDark(context) ? _chartCurrentDark : _chartCurrentLight;

  static Color primaryLightOf(BuildContext context) =>
      _isDark(context) ? const Color(0xFF1E2A5E) : primaryLight;
}
