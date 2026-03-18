// ============================================================================
// step6_payment.dart — Step 6: Payment Details
// ============================================================================
// The final step in the quotation flow. The user enters payment details:
//   - Payment method selection (Debit Order or EFT)
//   - Bank details (bank name, account number, branch code)
//   - Debit order date selection
//   - Terms & conditions acceptance
//
// FLUTTER CONCEPTS INTRODUCED:
//   - SegmentedButton: A Material 3 widget that shows a group of choices
//     where the user selects one (like tabs, but for forms).
//   - Checkbox: A toggleable square checkbox widget.
//   - Form validation across multiple fields.
//   - IgnorePointer: Prevents all interactions with its child widget tree.
//     Used to "disable" a section without graying out individual widgets.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/member.dart';

/// Payment method options
enum PaymentMethod { debitOrder, eft }

class Step6Payment extends StatefulWidget {
  /// The list of members — used to calculate the total premium
  final List<Member> members;

  /// Called when payment is completed successfully
  final VoidCallback onComplete;

  /// Called when user taps Back
  final VoidCallback onBack;

  const Step6Payment({
    super.key,
    required this.members,
    required this.onComplete,
    required this.onBack,
  });

  @override
  State<Step6Payment> createState() => _Step6PaymentState();
}

class _Step6PaymentState extends State<Step6Payment> {
  // ── Form State ──
  final _formKey = GlobalKey<FormState>();

  /// Currently selected payment method
  PaymentMethod _paymentMethod = PaymentMethod.debitOrder;

  /// Text controllers for bank detail fields
  final _bankNameCtrl = TextEditingController();
  final _accountCtrl = TextEditingController();
  final _branchCtrl = TextEditingController();
  final _accountHolderCtrl = TextEditingController();

  /// Selected debit order date (1st or 25th of month)
  int _debitDay = 1;

  /// Whether the user has accepted terms & conditions
  bool _acceptedTerms = false;

  /// Whether a payment is being processed (shows loading indicator)
  bool _isProcessing = false;

  @override
  void dispose() {
    // Clean up all controllers
    _bankNameCtrl.dispose();
    _accountCtrl.dispose();
    _branchCtrl.dispose();
    _accountHolderCtrl.dispose();
    super.dispose();
  }

  /// Calculates total premium (same logic as Step 4)
  double get _totalPremium {
    return widget.members.fold(0.0, (sum, m) {
      final classPrices = {'A': 1250.0, 'B': 950.0, 'C': 750.0, 'D': 500.0};
      double base = classPrices[m.benefitClass] ?? 750.0;
      if (m.type == MemberType.dependent) base *= 0.7;
      return sum + base;
    });
  }

  /// Simulates payment processing
  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms and conditions'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    // Show loading state
    setState(() => _isProcessing = true);

    // Simulate a network call (2 seconds delay)
    await Future.delayed(const Duration(seconds: 2));

    // Hide loading state
    setState(() => _isProcessing = false);

    // Notify parent that payment is complete
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: 'R ', decimalDigits: 2);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // ── Payment Amount Card ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      // Gradient background for the amount card
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B5BFE), Color(0xFF6C8CFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Monthly Premium',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currencyFormat.format(_totalPremium),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.members.length} member(s)',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Payment Method & Bank Details Card ──
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
                        const Text(
                          'Payment Method',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Payment Method Selector ──
                        // SegmentedButton is Material 3's replacement for toggle buttons
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<PaymentMethod>(
                            segments: const [
                              ButtonSegment(
                                value: PaymentMethod.debitOrder,
                                label: Text('Debit Order'),
                                icon: Icon(Icons.account_balance, size: 18),
                              ),
                              ButtonSegment(
                                value: PaymentMethod.eft,
                                label: Text('EFT'),
                                icon: Icon(Icons.send, size: 18),
                              ),
                            ],
                            selected: {_paymentMethod},
                            onSelectionChanged: (Set<PaymentMethod> selected) {
                              setState(() {
                                _paymentMethod = selected.first;
                              });
                            },
                            style: ButtonStyle(
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Bank Details Section ──
                        // Only shown for Debit Order payment method
                        if (_paymentMethod == PaymentMethod.debitOrder) ...[
                          const Text(
                            'Bank Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Account Holder Name
                          const Text('Account Holder *',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _accountHolderCtrl,
                            decoration: const InputDecoration(
                                hintText: 'Full name on bank account'),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // Bank Name
                          const Text('Bank Name *',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _bankNameCtrl,
                            decoration: const InputDecoration(
                                hintText: 'e.g. FNB, Standard Bank'),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // Account Number & Branch Code side by side
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Account Number *',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13)),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _accountCtrl,
                                      decoration: const InputDecoration(
                                          hintText: 'e.g. 62123456789'),
                                      keyboardType: TextInputType.number,
                                      validator: (v) =>
                                          (v == null || v.trim().isEmpty)
                                              ? 'Required'
                                              : null,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Branch Code *',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13)),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _branchCtrl,
                                      decoration: const InputDecoration(
                                          hintText: 'e.g. 250655'),
                                      keyboardType: TextInputType.number,
                                      validator: (v) =>
                                          (v == null || v.trim().isEmpty)
                                              ? 'Required'
                                              : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ── Debit Order Date Selection ──
                          const Text('Debit Order Date *',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<int>(
                            value: _debitDay,
                            decoration: const InputDecoration(),
                            items: const [
                              DropdownMenuItem(
                                  value: 1, child: Text('1st of each month')),
                              DropdownMenuItem(
                                  value: 15, child: Text('15th of each month')),
                              DropdownMenuItem(
                                  value: 25, child: Text('25th of each month')),
                            ],
                            onChanged: (val) {
                              setState(() => _debitDay = val!);
                            },
                          ),
                        ] else ...[
                          // ── EFT Instructions ──
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F9FF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xFFBAE6FD)),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.account_balance,
                                        color: Color(0xFF0284C7), size: 20),
                                    SizedBox(width: 8),
                                    Text('EFT Banking Details',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF0284C7))),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Text('Bank: First National Bank',
                                    style: TextStyle(fontSize: 13)),
                                Text('Account: 62987654321',
                                    style: TextStyle(fontSize: 13)),
                                Text('Branch: 250655',
                                    style: TextStyle(fontSize: 13)),
                                Text('Reference: Your Sponsor Number',
                                    style: TextStyle(fontSize: 13)),
                                SizedBox(height: 8),
                                Text(
                                  'Please use your sponsor number as payment reference.',
                                  style: TextStyle(
                                      fontSize: 12, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Terms & Conditions Checkbox ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Checkbox widget — a simple boolean toggle
                        Checkbox(
                          value: _acceptedTerms,
                          activeColor: const Color(0xFF3B5BFE),
                          onChanged: (val) {
                            setState(() => _acceptedTerms = val ?? false);
                          },
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Text(
                              'I agree to the terms and conditions, privacy policy, '
                              'and authorize the monthly debit order from the account provided above.',
                              style: TextStyle(
                                  fontSize: 13, color: Color(0xFF64748B)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
                    onPressed: _isProcessing ? null : widget.onBack,
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
                    onPressed: _isProcessing ? null : _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50), // Green for payment
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFCBD5E1),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    // Show a spinner while processing, otherwise show text
                    child: _isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Complete Payment'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
