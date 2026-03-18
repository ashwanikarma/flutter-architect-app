// ============================================================================
// step_indicator.dart — Custom Stepper / Progress Indicator Widget
// ============================================================================
// This widget shows the numbered circles (1, 2, 3...) at the top of the screen
// connected by dashed lines, exactly like the reference screenshots.
//
// HOW IT WORKS:
//   - It takes the current step index (0-based) and a list of step labels.
//   - Steps before the current one show a blue checkmark (✓) = completed.
//   - The current step shows a filled blue circle with its number.
//   - Future steps show a gray circle with their number.
//
// FLUTTER CONCEPTS USED:
//   - Row: places children horizontally (like flexbox row in CSS)
//   - Column: places children vertically
//   - Container: a box that can have decoration (color, border, shape)
//   - Expanded: tells a child to take up all remaining space in a Row/Column
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
    // We use a Row to lay out circles and lines horizontally
    return Row(
      children: List.generate(labels.length * 2 - 1, (index) {
        // Even indices (0, 2, 4...) are circles, odd indices are connecting lines
        if (index.isEven) {
          // Convert to step index: 0→0, 2→1, 4→2, etc.
          final stepIndex = index ~/ 2;
          return _buildStepCircle(stepIndex);
        } else {
          // This is a connecting line between two circles
          final stepBefore = index ~/ 2;
          return _buildConnector(stepBefore);
        }
      }),
    );
  }

  /// Builds one circle for a step.
  /// Three states: completed (✓), active (blue number), or upcoming (gray number).
  Widget _buildStepCircle(int stepIndex) {
    // Determine the state of this step
    final bool isCompleted = stepIndex < currentStep;
    final bool isActive = stepIndex == currentStep;

    // Choose colors based on state
    final Color circleColor = (isCompleted || isActive)
        ? const Color(0xFF3B5BFE) // Blue for completed/active
        : const Color(0xFFE2E8F0); // Light gray for upcoming

    final Color textColor = (isCompleted || isActive)
        ? Colors.white // White text/icon on blue
        : const Color(0xFF94A3B8); // Gray text on gray circle

    return Column(
      // mainAxisSize.min = only take as much vertical space as needed
      mainAxisSize: MainAxisSize.min,
      children: [
        // The circle itself
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle, // Makes it a circle instead of a square
          ),
          // Center the number or checkmark inside the circle
          child: Center(
            child: isCompleted
                // Show a checkmark icon for completed steps
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                // Show the step number (1-based) for active/upcoming steps
                : Text(
                    '${stepIndex + 1}',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6), // Small gap between circle and label

        // Show label only for the active step (to avoid crowding)
        if (isActive)
          Text(
            labels[stepIndex],
            style: const TextStyle(
              color: Color(0xFF3B5BFE),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          )
        else
          // Empty space to keep alignment consistent
          const SizedBox(height: 14),
      ],
    );
  }

  /// Builds the dashed line connecting two step circles.
  /// It's blue if the step before it is completed, gray otherwise.
  Widget _buildConnector(int stepBefore) {
    final bool isCompleted = stepBefore < currentStep;

    return Expanded(
      // Expanded makes this line fill all available horizontal space
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20), // Align with circle center
        child: Container(
          height: 2,
          // A dashed line effect using a thin colored container
          color: isCompleted
              ? const Color(0xFF3B5BFE) // Blue = completed connection
              : const Color(0xFFE2E8F0), // Gray = not yet reached
        ),
      ),
    );
  }
}
