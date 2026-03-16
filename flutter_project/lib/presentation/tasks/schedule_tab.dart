import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../services/providers.dart';

/// Schedule tab – matches the right screen of the reference image.
class ScheduleTab extends ConsumerWidget {
  const ScheduleTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Header
                Row(
                  children: [
                    const Icon(Icons.arrow_back_ios_rounded, size: 20),
                    const Spacer(),
                    const Text('December 2024 ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const Icon(Icons.keyboard_arrow_down, size: 20),
                    const Spacer(),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.add, color: Colors.white, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Week day row
                _weekRow(),
                const SizedBox(height: 24),

                // Task list from API / demo data
                tasksAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e'),
                  data: (tasks) => Column(
                    children: [
                      for (int i = 0; i < tasks.length; i++)
                        _taskTile(
                          time: '${7 + (i ~/ 2)}:${i.isEven ? '00' : '30'}',
                          showTime: i.isEven,
                          title: tasks[i].title,
                          subtitle: tasks[i].description,
                          color: [AppColors.primaryBlue, AppColors.accentGreen, Colors.orange, AppColors.primaryBlue, Colors.orange][i % 5],
                          checked: i < 3,
                        ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _weekRow() {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final dates = [12, 13, 14, 15, 16, 17, 18];
    const selected = 3; // Thursday
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final isSelected = i == selected;
        return Column(
          children: [
            Text(days[i], style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text('${dates[i]}', style: TextStyle(color: isSelected ? Colors.white : AppColors.textMain, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      }),
    );
  }

  Widget _taskTile({
    required String time,
    required bool showTime,
    required String title,
    required String subtitle,
    required Color color,
    required bool checked,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 54,
            child: showTime ? Text(time, style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w500)) : const SizedBox(),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.fitness_center, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                Text(subtitle, style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: checked ? AppColors.primaryBlue : Colors.transparent,
              border: Border.all(color: checked ? AppColors.primaryBlue : AppColors.textMuted.withOpacity(0.3), width: 1.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: checked ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
          ),
        ],
      ),
    );
  }
}
