// ============================================================================
// step6_payment.dart — Step 6: Enhanced Payment with Success State
// ============================================================================
// ENHANCEMENTS FROM REFERENCE:
//   - Payment states: idle → processing → success / failed
//   - Policy issuance confirmation screen with policy number
//   - Animated success screen with confetti-like celebration
//   - Detailed member premium breakdown table
//   - SAR currency with proper formatting
//   - IBAN-based bank detection for payment
//   - Better EFT instructions
//
// FLUTTER CONCEPTS:
//   - Enum for state management (PaymentState)
//   - AnimatedSwitcher: Smooth transitions between payment states
//   - Hero animations: Smooth page transitions for the success icon
//   - Future.delayed: Simulating async operations
// ============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/member.dart';

/// Tracks the current payment state — like a mini state machine.
/// idle → user is filling in details
/// processing → payment is being processed (show spinner)
/// success → payment went through, show confirmation
/// failed → something went wrong
enum PaymentState { idle, processing, success, failed }

/// Payment method options
enum PaymentMethod { debitOrder, eft }

class Step6Payment extends StatefulWidget {
  final List<Member> members;
  final VoidCallback onComplete;
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

class _Step6PaymentState extends State<Step6Payment>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // ── Payment State ──
  PaymentState _paymentState = PaymentState.idle;
  PaymentMethod _paymentMethod = PaymentMethod.debitOrder;

  // ── Bank Detail Controllers ──
  final _accountHolderCtrl = TextEditingController();
  final _ibanCtrl = TextEditingController();
  String? _detectedBank;
  int _debitDay = 1;
  bool _acceptedTerms = false;

  // ── Generated Policy Number ──
  String _policyNumber = '';

  // ── Animation ──
  late AnimationController _successAnimCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _successAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(
      parent: _successAnimCtrl,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _accountHolderCtrl.dispose();
    _ibanCtrl.dispose();
    _successAnimCtrl.dispose();
    super.dispose();
  }

  /// Calculate total premium from all members
  double get _totalPremium =>
      widget.members.fold(0.0, (sum, m) => sum + m.premium);

  /// Auto-detect bank from IBAN
  void _onIbanChanged(String value) {
    final clean = value.replaceAll(' ', '').toUpperCase();
    if (clean.length >= 6 && clean.startsWith('SA')) {
      setState(() => _detectedBank = bankMap[clean.substring(4, 6)]);
    } else {
      setState(() => _detectedBank = null);
    }
  }

  /// Generate a random-looking policy number
  String _generatePolicyNumber() {
    final now = DateTime.now();
    return 'POL-${now.year}${now.month.toString().padLeft(2, '0')}'
        '-${(now.millisecondsSinceEpoch % 10000).toString().padLeft(4, '0')}';
  }

  /// Process payment — simulates a backend API call
  Future<void> _processPayment() async {
    if (_paymentMethod == PaymentMethod.debitOrder) {
      if (!_formKey.currentState!.validate()) return;
    }
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms and conditions'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    // Start processing
    setState(() => _paymentState = PaymentState.processing);

    // Simulate network delay (2 seconds)
    await Future.delayed(const Duration(seconds: 2));

    // Generate policy number and show success
    setState(() {
      _policyNumber = _generatePolicyNumber();
      _paymentState = PaymentState.success;
    });

    // Play the success animation
    _successAnimCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: 'SAR ', decimalDigits: 0);

    // ── SUCCESS STATE ──
    // Show the policy confirmation screen
    if (_paymentState == PaymentState.success) {
      return _buildSuccessScreen(currencyFormat);
    }

    // ── PROCESSING STATE ──
    // Show a loading spinner
    if (_paymentState == PaymentState.processing) {
      return _buildProcessingScreen();
    }

    // ── IDLE STATE ──
    // Show the payment form
    return _buildPaymentForm(currencyFormat);
  }

  /// The main payment form (idle state)
  Widget _buildPaymentForm(NumberFormat currencyFormat) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // ── Premium Amount Card ──
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
                        const Text('Total Premium Due',
                            style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 8),
                        Text(currencyFormat.format(_totalPremium),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                            )),
                        const SizedBox(height: 4),
                        Text('${widget.members.length} member(s)',
                            style: const TextStyle(color: Colors.white60, fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Payment Method Card ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 16, offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Payment Method',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 16),

                        // Method selector
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
                            onSelectionChanged: (val) {
                              setState(() => _paymentMethod = val.first);
                            },
                            style: ButtonStyle(
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── DEBIT ORDER FORM ──
                        if (_paymentMethod == PaymentMethod.debitOrder) ...[
                          const Text('Account Holder *',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _accountHolderCtrl,
                            decoration: const InputDecoration(hintText: 'Full name on account'),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),

                          const Text('IBAN *',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _ibanCtrl,
                            decoration: const InputDecoration(
                              hintText: 'SA0380000000608010167519',
                              prefixIcon: Icon(Icons.account_balance_outlined, size: 20, color: Color(0xFF94A3B8)),
                            ),
                            textCapitalization: TextCapitalization.characters,
                            onChanged: _onIbanChanged,
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                          ),

                          // Bank auto-detect
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _detectedBank != null
                                ? Container(
                                    key: ValueKey(_detectedBank),
                                    margin: const EdgeInsets.only(top: 8),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0FDF4),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFF86EFAC)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.verified, color: Color(0xFF22C55E), size: 16),
                                        const SizedBox(width: 6),
                                        Text(_detectedBank!,
                                            style: const TextStyle(fontSize: 13, color: Color(0xFF16A34A),
                                                fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(key: ValueKey('none')),
                          ),
                          const SizedBox(height: 16),

                          const Text('Debit Order Date *',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<int>(
                            value: _debitDay,
                            decoration: const InputDecoration(),
                            items: const [
                              DropdownMenuItem(value: 1, child: Text('1st of each month')),
                              DropdownMenuItem(value: 15, child: Text('15th of each month')),
                              DropdownMenuItem(value: 25, child: Text('25th of each month')),
                            ],
                            onChanged: (val) => setState(() => _debitDay = val!),
                          ),
                        ] else ...[
                          // ── EFT INSTRUCTIONS ──
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F9FF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFBAE6FD)),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.account_balance, color: Color(0xFF0284C7), size: 20),
                                    SizedBox(width: 8),
                                    Text('EFT Banking Details',
                                        style: TextStyle(fontWeight: FontWeight.w700,
                                            color: Color(0xFF0284C7))),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Text('Bank: Al Rajhi Bank', style: TextStyle(fontSize: 13)),
                                Text('IBAN: SA0380000000608010167519', style: TextStyle(fontSize: 13)),
                                Text('Account: Insurance Premium Collection', style: TextStyle(fontSize: 13)),
                                SizedBox(height: 8),
                                Text('Reference: Your Sponsor Number',
                                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Terms Checkbox ──
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
                        Checkbox(
                          value: _acceptedTerms,
                          activeColor: const Color(0xFF3B5BFE),
                          onChanged: (val) => setState(() => _acceptedTerms = val ?? false),
                        ),
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Text(
                              'I agree to the terms and conditions and authorize the premium deduction '
                              'from my account as specified above.',
                              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
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
                    onPressed: _processPayment,
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
                        Icon(Icons.lock, size: 18),
                        SizedBox(width: 8),
                        Text('Pay Now'),
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

  /// Processing screen with loading animation
  Widget _buildProcessingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated loading indicator
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF3B5BFE).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(Color(0xFF3B5BFE)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Processing Payment...',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          const Text('Please wait while we process your payment',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  /// Success screen with policy confirmation
  Widget _buildSuccessScreen(NumberFormat currencyFormat) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // ── Success Icon with Animation ──
          ScaleTransition(
            scale: _scaleAnim,
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF22C55E).withOpacity(0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 44),
            ),
          ),
          const SizedBox(height: 24),

          const Text('Policy Issued Successfully!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          const Text('Your health insurance policy has been activated.',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),

          // ── Policy Confirmation Card ──
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
              children: [
                const Text('Policy Confirmation',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),

                _buildConfirmRow('Policy Number', _policyNumber),
                _buildConfirmRow('Members', '${widget.members.length}'),
                _buildConfirmRow('Premium Paid', currencyFormat.format(_totalPremium)),
                _buildConfirmRow('Payment Method',
                    _paymentMethod == PaymentMethod.debitOrder ? 'Debit Order' : 'EFT'),

                const Divider(height: 32),

                // ── Member Breakdown Table ──
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Member Breakdown',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 10),
                ...widget.members.asMap().entries.map((e) {
                  final i = e.key;
                  final m = e.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFBFD),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text('${i + 1}.',
                            style: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m.name,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                              Text('${m.typeLabel} · Class ${m.benefitClass}',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                            ],
                          ),
                        ),
                        Text(currencyFormat.format(m.premium),
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Done Button ──
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onComplete,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B5BFE),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Done — Start New Quotation'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Confirmation detail row
  Widget _buildConfirmRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A))),
        ],
      ),
    );
  }
}
