import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/auth/login/login_screen.dart';

void main() {
  runApp(const ProviderScope(child: FitnessDashboardApp()));
}

class FitnessDashboardApp extends StatelessWidget {
  const FitnessDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Dashboard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const LoginScreen(),
    );
  }
}
