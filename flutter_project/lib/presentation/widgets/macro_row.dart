import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Row of macro nutrient cards (Carbs, Protein, Fat).
class MacroRow extends StatelessWidget {
  const MacroRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _macro('Carbs', '281 / 359g', 0.78, AppColors.primaryBlue),
        const SizedBox(width: 10),
        _macro('Protein', '20 / 143g', 0.14, Colors.orange),
        const SizedBox(width: 10),
        _macro('Fat', '169 / 359g', 0.47, Colors.redAccent),
      ],
    );
  }

  Widget _macro(String label, String value, double progress, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                Icon(Icons.more_horiz, size: 16, color: AppColors.textMuted),
              ],
            ),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(value: progress, color: color, backgroundColor: color.withOpacity(0.15), minHeight: 6),
            ),
          ],
        ),
      ),
    );
  }
}
