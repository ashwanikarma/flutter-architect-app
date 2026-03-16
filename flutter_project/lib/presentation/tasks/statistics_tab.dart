import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';

/// Statistics tab – matches the middle screen of the reference image.
class StatisticsTab extends StatelessWidget {
  const StatisticsTab({super.key});

  @override
  Widget build(BuildContext context) {
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
                    const Text('Statistics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    const SizedBox(width: 20),
                  ],
                ),
                const SizedBox(height: 28),

                // Period toggles
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Calories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    Row(children: [_toggle('D', false), _toggle('W', true), _toggle('M', false)]),
                  ],
                ),
                const SizedBox(height: 20),

                // Bar chart
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      maxY: 120,
                      barGroups: _barGroups(),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) => Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][v.toInt()],
                                style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          ),
                        )),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32,
                          getTitlesWidget: (v, _) => Text('${v.toInt()}', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        )),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(show: true, drawVerticalLine: false,
                          getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.shade200, strokeWidth: 1)),
                      borderData: FlBorderData(show: false),
                      barTouchData: BarTouchData(enabled: false),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [_legend(AppColors.chartTarget, 'Target'), const SizedBox(width: 20), _legend(AppColors.chartReached, 'Reached'), const SizedBox(width: 20), _legend(AppColors.chartCurrent, 'Current')],
                ),
                const SizedBox(height: 28),

                // This Week Average
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('This Week Average', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    Text('+ Add New', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 16),

                // Stat cards grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _statCard('Walk Steps', '8,986', 'STEPS', Icons.directions_walk),
                    _statCard('Sleep', '8.5', 'HOUR', Icons.bedtime_outlined),
                    _statCard('Water', '2.5', 'GLASS', Icons.water_drop_outlined),
                    _statCard('Workouts', '120', 'MINUTES', Icons.fitness_center),
                  ],
                ),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  static List<BarChartGroupData> _barGroups() {
    final data = [
      [60.0, 80.0, 50.0],
      [70.0, 90.0, 60.0],
      [50.0, 70.0, 45.0],
      [80.0, 100.0, 70.0],
      [90.0, 110.0, 85.0],
      [65.0, 95.0, 55.0],
      [75.0, 85.0, 60.0],
    ];
    return List.generate(7, (i) => BarChartGroupData(
      x: i,
      barsSpace: 3,
      barRods: [
        BarChartRodData(toY: data[i][0], color: AppColors.chartTarget, width: 8, borderRadius: BorderRadius.circular(4)),
        BarChartRodData(toY: data[i][1], color: AppColors.chartReached, width: 8, borderRadius: BorderRadius.circular(4)),
        BarChartRodData(toY: data[i][2], color: AppColors.chartCurrent, width: 8, borderRadius: BorderRadius.circular(4)),
      ],
    ));
  }

  static Widget _toggle(String label, bool active) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: active ? AppColors.primaryBlue : AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(label, style: TextStyle(color: active ? Colors.white : AppColors.textMuted, fontWeight: FontWeight.w600, fontSize: 13)),
    );
  }

  static Widget _legend(Color color, String label) {
    return Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
    ]);
  }

  static Widget _statCard(String title, String value, String unit, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(title, style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            Icon(Icons.more_horiz, size: 18, color: AppColors.textMuted),
          ]),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(unit, style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
