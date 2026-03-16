import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/calorie_card.dart';
import '../widgets/macro_row.dart';
import '../widgets/meal_list.dart';

/// Home tab – matches the left screen of the reference image.
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Good morning,', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                        const SizedBox(height: 2),
                        const Text('Abraham Steevan', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.notifications_none_rounded, size: 26),
                        ),
                        const CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=fitness'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Search bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: AppColors.textMuted),
                      const SizedBox(width: 10),
                      Text('Search..', style: TextStyle(color: AppColors.textMuted, fontSize: 15)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Calorie card
                const CalorieCard(),
                const SizedBox(height: 20),

                // Macros
                const MacroRow(),
                const SizedBox(height: 24),

                // Planned meals header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Planned Meals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    Text('View all', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 12),
                const MealList(),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
