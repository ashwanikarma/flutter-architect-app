// ============================================================================
// main.dart — Entry Point for the Quotation Flow App (Enhanced)
// ============================================================================
// WHAT CHANGED:
//   1. Added ProviderScope — wraps the entire app so Riverpod works everywhere
//   2. Added a Home Screen with navigation to both the Quotation Flow AND
//      the new Policy CRUD screen
//   3. Updated theme to match the blue design system
//
// NEW CONCEPT — ProviderScope:
//   Think of ProviderScope like plugging in a power strip before using
//   electrical devices. All Riverpod providers need this "power source"
//   to function. Without it, ref.watch() and ref.read() won't work.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/quotation_flow_screen.dart';
import 'screens/policy_crud_screen.dart';

/// The main() function is where Dart starts executing.
/// runApp() takes a Widget and makes it the root of your app.
void main() {
  // ProviderScope MUST wrap everything for Riverpod to work.
  // It's like turning on the main power switch for state management.
  runApp(const ProviderScope(child: QuotationApp()));
}

/// QuotationApp — root widget that sets up the theme and home screen.
class QuotationApp extends StatelessWidget {
  const QuotationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Policy Quotation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B5BFE),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5F7FA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3B5BFE), width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      // Start at the Home Screen (not directly at the quotation flow)
      home: const HomeScreen(),
    );
  }
}

// ============================================================================
// HomeScreen — Landing Page with Navigation Cards
// ============================================================================
// This is the FIRST screen the user sees.
// It provides two main navigation options:
//   1. Create a new quotation (the 6-step flow)
//   2. Manage policies (CRUD operations)

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ── Welcome Header ──
              Row(
                children: [
                  // User avatar
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B5BFE), Color(0xFF6C8CFF)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        'AS',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back 👋',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Ashwani Karma',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Notifications bell
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: Color(0xFF0F172A),
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ── Quick Stats Bar ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B5BFE), Color(0xFF6C8CFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B5BFE).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _QuickStat(icon: Icons.description_outlined, value: '24', label: 'Total\nPolicies'),
                    _QuickStat(icon: Icons.check_circle_outline, value: '18', label: 'Approved'),
                    _QuickStat(icon: Icons.hourglass_empty, value: '4', label: 'Pending'),
                    _QuickStat(icon: Icons.people_outline, value: '156', label: 'Members'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Section Title ──
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),

              // ── Navigation Card 1: New Quotation ──
              _buildActionCard(
                context: context,
                title: 'Create New Quotation',
                subtitle: '6-step flow: Sponsor → Members → Health → Quote → KYC → Payment',
                icon: Icons.add_circle_outline_rounded,
                gradient: const [Color(0xFF3B5BFE), Color(0xFF6C8CFF)],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const QuotationFlowScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              // ── Navigation Card 2: Policy CRUD ──
              _buildActionCard(
                context: context,
                title: 'Manage Policies',
                subtitle: 'View, create, edit & delete policies (CRUD with Riverpod + Dio)',
                icon: Icons.folder_open_rounded,
                gradient: const [Color(0xFF8B5CF6), Color(0xFFB07CFF)],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PolicyCrudScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              // ── Navigation Card 3: Reports ──
              _buildActionCard(
                context: context,
                title: 'Reports & Analytics',
                subtitle: 'Premium summaries, member statistics, and renewal tracking',
                icon: Icons.bar_chart_rounded,
                gradient: const [Color(0xFF22C55E), Color(0xFF6EE7B7)],
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('📊 Reports module coming soon!'),
                      backgroundColor: const Color(0xFF22C55E),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // ── CRUD Explainer Section ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: Color(0xFFF59E0B), size: 22),
                        SizedBox(width: 10),
                        Text(
                          'What is CRUD?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _crudExplainerRow('C', 'Create', 'Add new data (like filling a new form)', const Color(0xFF22C55E)),
                    _crudExplainerRow('R', 'Read', 'View existing data (like opening a filing cabinet)', const Color(0xFF3B5BFE)),
                    _crudExplainerRow('U', 'Update', 'Edit data (like correcting a mistake on a form)', const Color(0xFFF59E0B)),
                    _crudExplainerRow('D', 'Delete', 'Remove data (like shredding a document)', const Color(0xFFEF4444)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a navigation action card with gradient background
  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  /// CRUD explainer row for the info card
  Widget _crudExplainerRow(String letter, String word, String explanation, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                letter,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(word, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                Text(explanation, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick stat widget for the header
class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _QuickStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
        const SizedBox(height: 2),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, fontSize: 10)),
      ],
    );
  }
}
