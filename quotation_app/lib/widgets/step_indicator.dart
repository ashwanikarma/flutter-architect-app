// ============================================================================
// step_indicator.dart — Enhanced Stepper / Progress Indicator Widget
// ============================================================================
// A polished horizontal stepper that shows numbered circles connected by lines.
// Enhanced with:
//   - Animated transitions when steps change
//   - Tooltip labels on all steps (not just active)
//   - Better visual hierarchy with shadows and gradients
//   - Smooth color transitions between states
//
// THREE STATES PER STEP:
//   1. COMPLETED (past): Blue circle with white checkmark ✓
//   2. ACTIVE (current): Blue gradient circle with white number, label visible
//   3. UPCOMING (future): Gray outline circle with gray number
// ============================================================================

import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  /// Which step is currently active (0 = first step)
  final int currentStep;

  /// Labels shown under each circle (e.g., "Sponsor", "Members", ...)
  final List<String> labels;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Horizontal scrolling allows the stepper to work on narrow screens
      // without overflowing or squishing the circles.
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(labels.length * 2 - 1, (index) {
          if (index.isEven) {
            final stepIndex = index ~/ 2;
            return _buildStepCircle(stepIndex);
          } else {
            final stepBefore = index ~/ 2;
            return _buildConnector(stepBefore);
          }
        }),
      ),
    );
  }

  /// Builds one step circle with its label underneath.
  ///
  /// ANIMATION NOTE:
  /// AnimatedContainer automatically animates between its old and new
  /// decoration/size values over the given duration. This creates a
  /// smooth color transition when a step becomes active or completed.
  Widget _buildStepCircle(int stepIndex) {
    final bool isCompleted = stepIndex < currentStep;
    final bool isActive = stepIndex == currentStep;

    return SizedBox(
      width: 52, // Fixed width prevents layout jumps when labels change
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── The Circle ──
          // AnimatedContainer smoothly transitions between states
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut, // Smooth acceleration/deceleration
            width: isActive ? 40 : 34, // Active step is slightly larger
            height: isActive ? 40 : 34,
            decoration: BoxDecoration(
              // Completed/Active: blue gradient. Upcoming: white with gray border.
              gradient: (isCompleted || isActive)
                  ? const LinearGradient(
                      colors: [Color(0xFF3B5BFE), Color(0xFF6C8CFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: (isCompleted || isActive) ? null : Colors.white,
              shape: BoxShape.circle,
              // Border only visible on upcoming steps
              border: (isCompleted || isActive)
                  ? null
                  : Border.all(color: const Color(0xFFCBD5E1), width: 2),
              // Shadow on active step for emphasis
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: const Color(0xFF3B5BFE).withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : Text(
                      '${stepIndex + 1}',
                      style: TextStyle(
                        color: isActive
                            ? Colors.white
                            : const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w700,
                        fontSize: isActive ? 15 : 13,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),

          // ── Label ──
          // AnimatedOpacity fades the label in/out smoothly
          AnimatedOpacity(
            opacity: isActive ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 200),
            child: Text(
              labels[stepIndex],
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isActive
                    ? const Color(0xFF3B5BFE)
                    : isCompleted
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8),
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the connecting line between two step circles.
  /// 
  /// ANIMATION:
  /// AnimatedContainer transitions the color from gray to blue
  /// when the step before it gets completed.
  Widget _buildConnector(int stepBefore) {
    final bool isCompleted = stepBefore < currentStep;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 24,
        height: 2.5,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: isCompleted
              ? const Color(0xFF3B5BFE)
              : const Color(0xFFE2E8F0),
        ),
      ),
    );
  }
}
