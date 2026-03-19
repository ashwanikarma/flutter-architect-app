// ============================================================================
// step4_quotation.dart — Step 4: Enhanced Quotation Summary & Pricing
// ============================================================================
// ENHANCEMENTS FROM REFERENCE:
//   - Class benefit details with expandable cards (coverage, hospitals, etc.)
//   - Health declaration surcharge (+15%) applied to premiums
//   - Premium calculation using the member.premium getter
//   - SAR currency formatting
//   - Visual breakdown with member table
//   - Class distribution summary
//
// FLUTTER CONCEPTS:
//   - ExpansionPanelList: A list of collapsible panels
//   - NumberFormat.currency: Formats numbers as currency
//   - Divider: Thin horizontal separator line
// ============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/member.dart';

class Step4Quotation extends StatefulWidget {
  final String sponsorNumber;
  final DateTime? policyDate;
  final List<Member> members;
  final VoidCallback onAccept;
  final VoidCallback onBack;

  const Step4Quotation({
    super.key,
    required this.sponsorNumber,
    required this.policyDate,
    required this.members,
    required this.onAccept,
    required this.onBack,
  });

  @override
  State<Step4Quotation> createState() => _Step4QuotationState();
}

class _Step4QuotationState extends State<Step4Quotation> {
  /// Which class benefit card is expanded (null = none)
  String? _expandedClass;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: 'SAR ', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy');

    // Calculate per-member premiums using the enhanced Member.premium getter
    final totalPremium = widget.members.fold(0.0, (sum, m) => sum + m.premium);

    // Get unique classes used by members
    final usedClasses = widget.members.map((m) => m.benefitClass).toSet().toList();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // ── Premium Summary Card (gradient header) ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B5BFE), Color(0xFF6C8CFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B5BFE).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text('Total Annual Premium',
                          style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 8),
                      Text(
                        currencyFormat.format(totalPremium),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Quick stats row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildQuickStat('Members', '${widget.members.length}'),
                          _buildQuickStat('Sponsor', widget.sponsorNumber),
                          _buildQuickStat('Date', widget.policyDate != null
                              ? dateFormat.format(widget.policyDate!)
                              : '—'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Member Premium Breakdown ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.receipt_long_outlined, color: Color(0xFF3B5BFE), size: 20),
                          SizedBox(width: 8),
                          Text('Premium Breakdown',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A))),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── Per-Member Rows ──
                      ...widget.members.asMap().entries.map((entry) {
                        final i = entry.key;
                        final m = entry.value;
                        final hasHealthSurcharge = m.healthDeclaration == 'Yes';

                        return Container(
                          margin: EdgeInsets.only(bottom: i < widget.members.length - 1 ? 10 : 0),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAFBFD),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              // Index number
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3B5BFE).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text('${i + 1}',
                                      style: const TextStyle(color: Color(0xFF3B5BFE),
                                          fontWeight: FontWeight.w700, fontSize: 13)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(m.name,
                                        style: const TextStyle(fontWeight: FontWeight.w600,
                                            color: Color(0xFF0F172A), fontSize: 14)),
                                    Row(
                                      children: [
                                        Text('${m.typeLabel} · Class ${m.benefitClass}',
                                            style: const TextStyle(fontSize: 12,
                                                color: Color(0xFF64748B))),
                                        if (hasHealthSurcharge) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF97316).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text('+15%',
                                                style: TextStyle(fontSize: 10,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFFF97316))),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Text(currencyFormat.format(m.premium),
                                  style: const TextStyle(fontWeight: FontWeight.w700,
                                      fontSize: 15, color: Color(0xFF0F172A))),
                            ],
                          ),
                        );
                      }),

                      const Divider(height: 32),

                      // ── Total Row ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Annual Premium',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A))),
                          Text(currencyFormat.format(totalPremium),
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                                  color: Color(0xFF3B5BFE))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Class Benefits Section ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.shield_outlined, color: Color(0xFF22C55E), size: 20),
                          SizedBox(width: 8),
                          Text('Coverage Benefits',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A))),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text('Tap a class to see detailed benefits',
                          style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                      const SizedBox(height: 16),

                      // Expandable benefit cards for each class used
                      ...usedClasses.map((cls) => _buildBenefitCard(cls, currencyFormat)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Disclaimer ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFED7AA)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFFF97316), size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This is a preliminary quotation. Final pricing may vary based on underwriting review.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF9A3412)),
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
                    onPressed: widget.onBack,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 4,
                      shadowColor: const Color(0xFF22C55E).withOpacity(0.3),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 18),
                        SizedBox(width: 8),
                        Text('Accept Quotation'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Quick stat widget shown inside the gradient header
  Widget _buildQuickStat(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }

  /// Expandable class benefit card
  Widget _buildBenefitCard(String cls, NumberFormat fmt) {
    final benefit = classBenefits[cls];
    if (benefit == null) return const SizedBox.shrink();

    final isExpanded = _expandedClass == cls;
    final memberCount = widget.members.where((m) => m.benefitClass == cls).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded ? const Color(0xFF3B5BFE).withOpacity(0.3) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          // Header (tappable)
          InkWell(
            onTap: () => setState(() => _expandedClass = isExpanded ? null : cls),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B5BFE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(cls,
                        style: const TextStyle(color: Colors.white,
                            fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Class $cls · ${benefit.coverage}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('$memberCount member${memberCount != 1 ? 's' : ''}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF0284C7))),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                children: [
                  const Divider(),
                  _buildBenefitRow(Icons.local_hospital, 'Hospitals', benefit.hospitals),
                  _buildBenefitRow(Icons.pregnant_woman, 'Maternity', benefit.maternity),
                  _buildBenefitRow(Icons.medical_services, 'Dental', benefit.dental),
                  _buildBenefitRow(Icons.visibility, 'Optical', benefit.optical),
                  const SizedBox(height: 8),
                  // Exclusions
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Exclusions:',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                                color: Color(0xFFEF4444))),
                        const SizedBox(height: 4),
                        ...benefit.exclusions.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text('• $e',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF9A3412))),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// Single benefit row inside the expanded card
  Widget _buildBenefitRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF22C55E)),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                    color: Color(0xFF0F172A))),
          ),
        ],
      ),
    );
  }
}
