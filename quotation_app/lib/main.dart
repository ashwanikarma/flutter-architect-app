// ============================================================================
// main.dart — Entry point for the Quotation Flow App
// ============================================================================
// This is the FIRST file Flutter runs. It sets up:
//   1. The app theme (colors, fonts, styling)
//   2. The starting screen (our quotation flow)
//
// Think of this like the "index.html" of a web app — it bootstraps everything.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/quotation_flow_screen.dart';

/// The main() function is where Dart starts executing.
/// runApp() takes a Widget and makes it the root of your app.
void main() {
  runApp(const QuotationApp());
}

/// QuotationApp is a "StatelessWidget" — meaning it doesn't change over time.
/// It simply configures the MaterialApp (Flutter's app wrapper) with:
///   - A title for the OS task switcher
///   - A theme (colors, fonts)
///   - The home screen to show first
class QuotationApp extends StatelessWidget {
  const QuotationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Title shown in the OS task switcher / recent apps
      title: 'Policy Quotation',

      // Hides the red "DEBUG" banner in the top-right corner
      debugShowCheckedModeBanner: false,

      // Theme controls the default look of ALL widgets in the app.
      // We use a blue color scheme to match the reference designs.
      theme: ThemeData(
        useMaterial3: true, // Use the latest Material Design 3 styling
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B5BFE), // Our primary blue
          brightness: Brightness.light,
        ),
        // Google Fonts gives us access to 1000+ fonts. "Inter" is clean & modern.
        textTheme: GoogleFonts.interTextTheme(),
        // Style all ElevatedButtons globally
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
        // Style all input fields globally
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

      // The first screen the user sees
      home: const QuotationFlowScreen(),
    );
  }
}
