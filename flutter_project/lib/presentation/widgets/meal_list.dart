import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Planned meals list section.
class MealList extends StatelessWidget {
  const MealList({super.key});

  static const _meals = [
    {'icon': Icons.free_breakfast, 'color': 0xFFFFF3E0, 'name': 'Add Breakfast', 'info': 'Recommended  440 - 615 kcal'},
    {'icon': Icons.lunch_dining, 'color': 0xFFFFEBEE, 'name': 'Add Lunch', 'info': 'Recommended  527 - 703 kcal'},
    {'icon': Icons.dinner_dining, 'color': 0xFFE8F5E9, 'name': 'Add Dinner', 'info': 'Recommended  550 - 750 kcal'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _meals.map((m) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: AppColors.surfaceOf(context), borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: Color(m['color'] as int), borderRadius: BorderRadius.circular(12)),
                  child: Icon(m['icon'] as IconData, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m['name'] as String, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textMainOf(context))),
                      const SizedBox(height: 2),
                      Text(m['info'] as String, style: TextStyle(color: AppColors.textMutedOf(context), fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primaryBlue),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add, size: 18, color: AppColors.primaryBlue),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
