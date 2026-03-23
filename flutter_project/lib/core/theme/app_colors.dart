import 'package:flutter/material.dart';

/// Central color palette — inspired by Plum/Smart Saving purple theme.
/// All primary colors are deep purple → violet gradient.
class AppColors {
  // ── Brand colors (shared across light & dark) ──
  /// Deep purple primary — the main brand color
  static const Color primaryPurple = Color(0xFF7B2FF2);

  /// Lighter purple for secondary elements
  static const Color primaryLight = Color(0xFFE8DAFE);

  /// Vibrant violet for gradient endpoints
  static const Color primaryViolet = Color(0xFF9B59F0);

  /// Rich dark purple for gradient starts
  static const Color primaryDeep = Color(0xFF5B10C2);

  /// Accent green for success states, progress bars, confirmations
  static const Color accentGreen = Color(0xFF4CAF50);

  /// Accent coral for warnings or highlights
  static const Color accentCoral = Color(0xFFFF6B6B);

  /// Gold accent for premium / star elements
  static const Color accentGold = Color(0xFFFFB800);

  // Legacy alias so existing code still compiles
  static const Color primaryBlue = primaryPurple;

  // ── Gradients ──

  /// Main brand gradient — deep purple to violet
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryDeep, primaryViolet, Color(0xFFB07CFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Subtle card gradient for backgrounds
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF6A1FD0), Color(0xFF9B59F0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Splash / auth screen gradient — full-screen purple
  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF4A06A4), Color(0xFF7B2FF2), Color(0xFFA855F7)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Light palette ──
  static const Color _backgroundLight = Color(0xFFF6F2FF);
  static const Color _surfaceLight = Colors.white;
  static const Color _textMainLight = Color(0xFF1A0A3E);
  static const Color _textMutedLight = Color(0xFF8B7DA8);
  static const Color _chartTargetLight = Color(0xFFE8DAFE);
  static const Color _chartCurrentLight = Color(0xFF1A0A3E);

  // ── Dark palette ──
  static const Color _backgroundDark = Color(0xFF0D0620);
  static const Color _surfaceDark = Color(0xFF1A1035);
  static const Color _textMainDark = Color(0xFFE8DAFE);
  static const Color _textMutedDark = Color(0xFF9B8DB8);
  static const Color _chartTargetDark = Color(0xFF2A1A52);
  static const Color _chartCurrentDark = Color(0xFFE8DAFE);

  // Legacy static accessors (light only)
  static const Color background = _backgroundLight;
  static const Color surface = _surfaceLight;
  static const Color textMain = _textMainLight;
  static const Color textMuted = _textMutedLight;
  static const Color chartReached = primaryPurple;
  static const Color chartTarget = _chartTargetLight;
  static const Color chartCurrent = _chartCurrentLight;

  // ── Gradient shortcuts for cards ──
  static const Color cardGradientStart = primaryDeep;
  static const Color cardGradientEnd = primaryViolet;

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
      _isDark(context) ? const Color(0xFF2A1A52) : primaryLight;
}
