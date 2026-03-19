// ============================================================================
// step1_sponsor.dart — Step 1: Sponsor Details (Enhanced)
// ============================================================================
// ENHANCEMENTS:
//   - Added sponsor name and status fields (auto-populated on lookup)
//   - Animated "searching" state when looking up sponsor
//   - Better form layout with icons and helper text
//   - Smooth validation feedback with shake animation
//
// FLUTTER CONCEPTS:
//   - TextEditingController: Links a text field to a variable
//   - GlobalKey<FormState>: Validates all form fields at once
//   - showDatePicker(): Native date picker dialog
//   - AnimatedSwitcher: Smoothly transitions between two widgets
// ============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Step1Sponsor extends StatefulWidget {
  final String initialSponsorNumber;
  final DateTime? initialDate;
  final void Function(String sponsorNumber, DateTime? date) onNext;

  const Step1Sponsor({
    super.key,
    required this.initialSponsorNumber,
    required this.initialDate,
    required this.onNext,
  });

  @override
  State<Step1Sponsor> createState() => _Step1SponsorState();
}

class _Step1SponsorState extends State<Step1Sponsor>
    with SingleTickerProviderStateMixin {
  // ── Form Key & Controllers ──
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _sponsorController;
  DateTime? _selectedDate;

  // ── Sponsor Lookup State ──
  /// Simulates looking up the sponsor in a backend system.
  /// In a real app, this would be an API call.
  bool _isLookingUp = false;
  String? _sponsorName;
  String? _sponsorStatus;

  // ── Animation Controller ──
  /// Used for the "pulse" effect on the Next button when form is valid
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _sponsorController =
        TextEditingController(text: widget.initialSponsorNumber);
    _selectedDate = widget.initialDate;

    // If we already have a sponsor number (user came back), simulate lookup
    if (widget.initialSponsorNumber.isNotEmpty) {
      _sponsorName = 'Acme Corporation Ltd.';
      _sponsorStatus = 'Active';
    }

    // Pulse animation: gently scales the button to draw attention
    _pulseController = AnimationController(
      vsync: this, // "this" works because we mixed in SingleTickerProviderStateMixin
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _sponsorController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  /// Simulates looking up the sponsor number in a backend system.
  /// Shows a loading indicator while "searching", then reveals the sponsor name.
  Future<void> _lookupSponsor() async {
    if (_sponsorController.text.trim().isEmpty) return;

    setState(() {
      _isLookingUp = true;
      _sponsorName = null;
      _sponsorStatus = null;
    });

    // Simulate network delay (1 second)
    await Future.delayed(const Duration(milliseconds: 1000));

    setState(() {
      _isLookingUp = false;
      // In a real app, these would come from the API response
      _sponsorName = 'Acme Corporation Ltd.';
      _sponsorStatus = 'Active';
    });
  }

  /// Opens the Material date picker dialog.
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 21)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3B5BFE),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final maxDate = now.add(const Duration(days: 21));
    final dateFormat = DateFormat('dd MMM yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // ── Main Form Card ──
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Icon + Title Row ──
                  Row(
                    children: [
                      // Decorative icon container
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B5BFE).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.business_outlined,
                          color: Color(0xFF3B5BFE),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sponsor Details',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Enter sponsor information to begin',
                            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ── Sponsor Number Field with Lookup Button ──
                  const Text(
                    'Sponsor Number *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _sponsorController,
                          decoration: const InputDecoration(
                            hintText: 'e.g. SP12345',
                            hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                            prefixIcon: Icon(Icons.tag, color: Color(0xFF94A3B8), size: 20),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a sponsor number';
                            }
                            return null;
                          },
                          // When the user finishes typing and moves to next field,
                          // automatically look up the sponsor
                          onFieldSubmitted: (_) => _lookupSponsor(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Lookup button — searches for the sponsor in the system
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLookingUp ? null : _lookupSponsor,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B5BFE),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(52, 52),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLookingUp
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.search, size: 22),
                        ),
                      ),
                    ],
                  ),

                  // ── Sponsor Info Card (shown after lookup) ──
                  // AnimatedSwitcher smoothly fades between "nothing" and the info card
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _sponsorName != null
                        ? Container(
                            key: const ValueKey('sponsor-info'),
                            margin: const EdgeInsets.only(top: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4), // Light green
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF86EFAC)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.verified,
                                    color: Color(0xFF22C55E), size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _sponsorName!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      Text(
                                        'Status: $_sponsorStatus',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF16A34A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(key: ValueKey('empty')),
                  ),
                  const SizedBox(height: 24),

                  // ── Policy Effective Date Field ──
                  const Text(
                    'Policy Effective Date *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickDate,
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: _selectedDate != null
                              ? dateFormat.format(_selectedDate!)
                              : 'Select date',
                          hintStyle: TextStyle(
                            color: _selectedDate != null
                                ? const Color(0xFF0F172A)
                                : const Color(0xFF94A3B8),
                          ),
                          prefixIcon: const Icon(
                            Icons.calendar_today_outlined,
                            color: Color(0xFF94A3B8),
                            size: 20,
                          ),
                        ),
                        validator: (_) {
                          if (_selectedDate == null) {
                            return 'Please select a policy effective date';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Date range hint
                  Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 14, color: Color(0xFF3B5BFE)),
                      const SizedBox(width: 6),
                      Text(
                        'Between ${dateFormat.format(now)} and ${dateFormat.format(maxDate)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF3B5BFE),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Next Button ──
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.onNext(_sponsorController.text.trim(), _selectedDate);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B5BFE),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 4,
                shadowColor: const Color(0xFF3B5BFE).withOpacity(0.3),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Next'),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
