// ============================================================================
// step4_quotation.dart — Step 4: Quotation Summary & Pricing
// ============================================================================
// This step shows the user a summary of their policy quotation including:
//   - Sponsor information
//   - A breakdown of monthly premiums per member
//   - Total monthly premium
//   - An "Accept Quotation" button to proceed
//
// FLUTTER CONCEPTS INTRODUCED:
//   - Card: A Material Design card with elevation and rounded corners.
//   - Divider: A thin horizontal line used to separate sections.
//   - NumberFormat: From the 'intl' package, formats numbers with commas
//     and currency symbols (e.g., "R 1,250.00").
//   - Map/reduce: Dart collection methods to transform and aggregate data.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/member.dart';

class Step4Quotation extends StatelessWidget {
  /// The sponsor number from Step 1
  final String sponsorNumber;

  /// The policy effective date from Step 1
  final DateTime? policyDate;

  /// The list of members from Step 2
  final List<Member> members;

  /// Called when user accepts the quotation
  final VoidCallback onAccept;

  /// Called when user taps Back
  final VoidCallback onBack;

  const Step4Quotation({
    super.key,
    required this.sponsorNumber,
    required this.policyDate,
    required this.members,
    required this.onAccept,
    required this.onBack,
  });

  /// Calculates a demo monthly premium based on member class and type.
  /// In a real app, this would come from the backend API.
  double _calculatePremium(Member member) {
    // Base prices per class (these are demo values)
    final classPrices = {
      'A': 1250.0,
      'B': 950.0,
      'C': 750.0,
      'D': 500.0,
    };

    double base = classPrices[member.benefitClass] ?? 750.0;

    // Dependents get a 30% discount
    if (member.type == MemberType.dependent) {
      base *= 0.7;
    }

    return base;
  }

  @override
  Widget build(BuildContext context) {
    // Currency formatter for South African Rand
    final currencyFormat = NumberFormat.currency(symbol: 'R ', decimalDigits: 2);
    final dateFormat = DateFormat('dd MMM yyyy');

    // Calculate total premium by summing all member premiums
    // .fold() is like JavaScript's .reduce() — starts at 0.0 and adds each premium
    final totalPremium =
        members.fold(0.0, (sum, m) => sum + _calculatePremium(m));

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // ── Quotation Summary Card ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Title ──
                      const Text(
                        'Quotation Summary',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Review your policy details and pricing below.',
                        style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 24),

                      // ── Sponsor Info Section ──
                      _buildInfoRow('Sponsor Number', sponsorNumber),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Effective Date',
                        policyDate != null
                            ? dateFormat.format(policyDate!)
                            : 'Not set',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow('Total Members', '${members.length}'),

                      const SizedBox(height: 20),
                      const Divider(), // Horizontal line separator
                      const SizedBox(height: 20),

                      // ── Premium Breakdown Header ──
                      const Text(
                        'Monthly Premium Breakdown',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Per-Member Premium List ──
                      ...members.map((m) {
                        final premium = _calculatePremium(m);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Member name and details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      m.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    Text(
                                      '${m.typeLabel} · Class ${m.benefitClass}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Premium amount
                              Text(
                                currencyFormat.format(premium),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const Divider(),
                      const SizedBox(height: 12),

                      // ── Total Premium ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Monthly Premium',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            currencyFormat.format(totalPremium),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF3B5BFE),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Disclaimer Note ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED), // Light orange background
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFED7AA)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Color(0xFFF97316), size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This is a preliminary quotation. Final pricing may vary based on underwriting.',
                          style:
                              TextStyle(fontSize: 13, color: Color(0xFF9A3412)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Bottom Buttons ──
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onBack,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B5BFE),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Accept Quotation'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Helper widget to display a label-value pair in a row.
  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
