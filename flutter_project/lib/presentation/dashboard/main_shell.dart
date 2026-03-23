import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'home_tab.dart';
import '../tasks/statistics_tab.dart';
import '../tasks/schedule_tab.dart';
import '../profile/profile_tab.dart';

/// Main app shell with bottom navigation — updated for purple theme.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _pages = const [
    HomeTab(),
    StatisticsTab(),
    SizedBox(), // placeholder for FAB
    ScheduleTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          if (i == 2) return;
          setState(() => _currentIndex = i);
        },
        items: [
          const BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: ''),
          const BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded), label: ''),
          BottomNavigationBarItem(
            icon: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primaryPurple.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
            label: '',
          ),
          const BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_rounded), label: ''),
          const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded), label: ''),
        ],
      ),
    );
  }
}
