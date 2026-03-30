import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════════════
/// PAGE TRANSITIONS — Reusable smooth animated route transitions
/// ═══════════════════════════════════════════════════════════════════════
///
/// Usage:
///   Navigator.push(context, AppTransitions.slideUp(const MyScreen()));
///   Navigator.pushReplacement(context, AppTransitions.fadeScale(const MyScreen()));
///
/// Why a utility?
///   Instead of repeating PageRouteBuilder everywhere, we centralise
///   all transitions here. This ensures consistent animation timing
///   and curves throughout the app.
/// ═══════════════════════════════════════════════════════════════════════
class AppTransitions {
  AppTransitions._(); // prevent instantiation

  /// Default duration for all transitions
  static const Duration _duration = Duration(milliseconds: 400);

  /// Faster duration for lightweight transitions
  static const Duration _fast = Duration(milliseconds: 300);

  // ── Slide from right (standard push) ──────────────────────────────
  /// Classic iOS-style slide from right edge.
  /// Best for: forward navigation (login → OTP, list → detail).
  static Route<T> slideRight<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: _duration,
      reverseTransitionDuration: _fast,
      transitionsBuilder: (_, animation, __, child) {
        // Combine slide + fade for a polished feel
        final offsetTween = Tween<Offset>(
          begin: const Offset(1.0, 0.0), // start off-screen right
          end: Offset.zero,              // end in place
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,    // smooth deceleration
        ));

        final fadeTween = Tween<double>(begin: 0.6, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOut),
        );

        return SlideTransition(
          position: offsetTween,
          child: FadeTransition(opacity: fadeTween, child: child),
        );
      },
    );
  }

  // ── Slide up from bottom ──────────────────────────────────────────
  /// Modal-style slide up from the bottom.
  /// Best for: modals, sheets, overlay screens.
  static Route<T> slideUp<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: _duration,
      reverseTransitionDuration: _fast,
      transitionsBuilder: (_, animation, __, child) {
        final offsetTween = Tween<Offset>(
          begin: const Offset(0.0, 0.3), // slight upward push
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));

        final fadeTween = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOut),
        );

        return SlideTransition(
          position: offsetTween,
          child: FadeTransition(opacity: fadeTween, child: child),
        );
      },
    );
  }

  // ── Fade + Scale (hero transition) ────────────────────────────────
  /// Subtle scale-up with fade. Feels premium.
  /// Best for: splash → home, OTP success → dashboard.
  static Route<T> fadeScale<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: _fast,
      transitionsBuilder: (_, animation, __, child) {
        final scaleTween = Tween<double>(begin: 0.92, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        );

        final fadeTween = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOut),
        );

        return FadeTransition(
          opacity: fadeTween,
          child: ScaleTransition(scale: scaleTween, child: child),
        );
      },
    );
  }

  // ── Simple fade ───────────────────────────────────────────────────
  /// Clean crossfade. No movement.
  /// Best for: splash → login, tab switches.
  static Route<T> fade<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: _fast,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  // ── Push and remove all (for auth flows) ──────────────────────────
  /// Navigates to [page] and removes the entire navigation stack.
  /// Best for: after login/OTP success, logout.
  static void pushAndClearAll(BuildContext context, Widget page) {
    Navigator.of(context).pushAndRemoveUntil(
      fadeScale(page),
      (_) => false, // remove all previous routes
    );
  }
}
