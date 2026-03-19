// ============================================================================
// step5_kyc.dart — Step 5: Enhanced KYC (Know Your Customer)
// ============================================================================
// ENHANCEMENTS FROM REFERENCE:
//   - National Address form (7 fields: building, additional, unit, postal,
//     street, district, city)
//   - Business Details (type, revenue, employees, tax registration, IBAN)
//   - IBAN auto-detect bank name from Saudi bank codes
//   - Compliance section (PEP, board members, shareholders)
//   - Board member and shareholder CRUD with dynamic lists
//   - Terms & conditions acceptance checkbox
//   - Form validation with inline errors
//
// FLUTTER CONCEPTS:
//   - TabController & TabBar: Organize content into tabs
//   - ListView.builder inside ExpansionTile: Dynamic lists
//   - TextFormField.onChanged: Real-time validation/detection
// ============================================================================

import 'package:flutter/material.dart';
import '../../models/member.dart';

class Step5Kyc extends StatefulWidget {
  final VoidCallback onSubmit;
  final VoidCallback onBack;

  const Step5Kyc({
    super.key,
    required this.onSubmit,
    required this.onBack,
  });

  @override
  State<Step5Kyc> createState() => _Step5KycState();
}

class _Step5KycState extends State<Step5Kyc> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // ── Tab Controller ──
  late TabController _tabController;

  // ── National Address Fields ──
  final _buildingCtrl = TextEditingController();
  final _additionalCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  // ── Business Details ──
  String _businessType = '';
  String _revenueRange = '';
  String _employeeRange = '';
  final _taxRegCtrl = TextEditingController();
  final _ibanCtrl = TextEditingController();
  String? _detectedBank; // Auto-detected from IBAN

  // ── Compliance ──
  bool? _isPEP; // Politically Exposed Person
  bool? _isBoardMember;
  bool? _hasMajorShareholder;
  bool _termsAccepted = false;

  // ── Board Members & Shareholders (dynamic lists) ──
  final List<Map<String, String>> _boardMembers = [];
  final List<Map<String, String>> _shareholders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _buildingCtrl.dispose();
    _additionalCtrl.dispose();
    _unitCtrl.dispose();
    _postalCtrl.dispose();
    _streetCtrl.dispose();
    _districtCtrl.dispose();
    _cityCtrl.dispose();
    _taxRegCtrl.dispose();
    _ibanCtrl.dispose();
    super.dispose();
  }

  /// Auto-detect bank from Saudi IBAN.
  /// Saudi IBAN format: SA + 2 check digits + 2 digit bank code + 18 digit account
  /// Characters at positions 4-5 (0-indexed) are the bank code.
  void _onIbanChanged(String value) {
    final clean = value.replaceAll(' ', '').toUpperCase();
    if (clean.length >= 6 && clean.startsWith('SA')) {
      final bankCode = clean.substring(4, 6);
      setState(() {
        _detectedBank = bankMap[bankCode];
      });
    } else {
      setState(() => _detectedBank = null);
    }
  }

  /// Validate the form and submit
  void _submit() {
    if (!_formKey.currentState!.validate()) {
      // Switch to the tab with the first error
      return;
    }
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms and conditions'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }
    widget.onSubmit();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Tab Bar ──
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF3B5BFE),
            unselectedLabelColor: const Color(0xFF94A3B8),
            indicatorColor: const Color(0xFF3B5BFE),
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            tabs: const [
              Tab(text: 'Address'),
              Tab(text: 'Business'),
              Tab(text: 'Compliance'),
            ],
          ),
        ),

        // ── Tab Content ──
        Expanded(
          child: Form(
            key: _formKey,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAddressTab(),
                _buildBusinessTab(),
                _buildComplianceTab(),
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
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B5BFE),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Submit KYC'),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 18),
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

  // ═══════════════════════════════════════════════════════════════════
  // TAB 1: NATIONAL ADDRESS
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildAddressTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B5BFE).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.location_on_outlined, color: Color(0xFF3B5BFE), size: 22),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('National Address', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    Text('Saudi national address details', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Building & Additional Number row
            Row(
              children: [
                Expanded(child: _buildField('Building No. *', _buildingCtrl, 'e.g. 4521')),
                const SizedBox(width: 12),
                Expanded(child: _buildField('Additional No.', _additionalCtrl, 'e.g. 7892')),
              ],
            ),
            const SizedBox(height: 16),

            // Unit Number & Postal Code row
            Row(
              children: [
                Expanded(child: _buildField('Unit No.', _unitCtrl, 'e.g. 3')),
                const SizedBox(width: 12),
                Expanded(child: _buildField('Postal Code *', _postalCtrl, 'e.g. 12345')),
              ],
            ),
            const SizedBox(height: 16),

            _buildField('Street Name *', _streetCtrl, 'e.g. King Fahd Road'),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: _buildField('District *', _districtCtrl, 'e.g. Al Olaya')),
                const SizedBox(width: 12),
                Expanded(child: _buildField('City *', _cityCtrl, 'e.g. Riyadh')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // TAB 2: BUSINESS DETAILS
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildBusinessTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.business_outlined, color: Color(0xFF8B5CF6), size: 22),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Business Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    Text('Company information & banking', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Business Type
            const Text('Business Type *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _businessType.isEmpty ? null : _businessType,
              decoration: const InputDecoration(hintText: 'Select type'),
              items: const ['LLC', 'Sole Proprietorship', 'Partnership', 'Corporation']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (val) => setState(() => _businessType = val ?? ''),
            ),
            const SizedBox(height: 16),

            // Revenue & Employees row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Revenue *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _revenueRange.isEmpty ? null : _revenueRange,
                        decoration: const InputDecoration(hintText: 'Select'),
                        isExpanded: true,
                        items: const ['< 1 Million', '1M – 10M', '10M – 50M', '50M+']
                            .map((r) => DropdownMenuItem(value: r, child: Text(r, overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (val) => setState(() => _revenueRange = val ?? ''),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Employees *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _employeeRange.isEmpty ? null : _employeeRange,
                        decoration: const InputDecoration(hintText: 'Select'),
                        items: const ['1–10', '11–50', '51–100', '100+']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (val) => setState(() => _employeeRange = val ?? ''),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tax Registration
            _buildField('Tax Registration No. *', _taxRegCtrl, 'e.g. 310123456700003'),
            const SizedBox(height: 16),

            // IBAN with auto-detect
            const Text('IBAN Number *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _ibanCtrl,
              decoration: const InputDecoration(
                hintText: 'e.g. SA0380000000608010167519',
                prefixIcon: Icon(Icons.account_balance_outlined, size: 20, color: Color(0xFF94A3B8)),
              ),
              textCapitalization: TextCapitalization.characters,
              onChanged: _onIbanChanged,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'IBAN is required' : null,
            ),

            // Auto-detected bank display
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _detectedBank != null
                  ? Container(
                      key: ValueKey(_detectedBank),
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF86EFAC)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.account_balance, color: Color(0xFF22C55E), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Bank detected: $_detectedBank',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                                  color: Color(0xFF16A34A)),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('no-bank')),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // TAB 3: COMPLIANCE
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildComplianceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF97316).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.gavel_outlined, color: Color(0xFFF97316), size: 22),
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Compliance', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                        Text('Regulatory requirements', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // PEP Question
                _buildYesNoQuestion(
                  'Is the applicant a Politically Exposed Person (PEP)?',
                  _isPEP,
                  (val) => setState(() => _isPEP = val),
                ),
                const SizedBox(height: 16),

                // Board Member Question
                _buildYesNoQuestion(
                  'Is the applicant a board member of any company?',
                  _isBoardMember,
                  (val) => setState(() => _isBoardMember = val),
                ),

                // Board Members List (if yes)
                if (_isBoardMember == true) ...[
                  const SizedBox(height: 12),
                  _buildDynamicList(
                    title: 'Board Members',
                    items: _boardMembers,
                    fields: ['Name', 'Identity Number', 'Address'],
                  ),
                ],
                const SizedBox(height: 16),

                // Major Shareholder Question
                _buildYesNoQuestion(
                  'Does the company have shareholders with 25%+ ownership?',
                  _hasMajorShareholder,
                  (val) => setState(() => _hasMajorShareholder = val),
                ),

                // Shareholders List (if yes)
                if (_hasMajorShareholder == true) ...[
                  const SizedBox(height: 12),
                  _buildDynamicList(
                    title: 'Shareholders',
                    items: _shareholders,
                    fields: ['Name', 'Address', 'Contribution %'],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Terms & Conditions ──
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
                  value: _termsAccepted,
                  activeColor: const Color(0xFF3B5BFE),
                  onChanged: (val) => setState(() => _termsAccepted = val ?? false),
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      'I confirm that all information provided is accurate and complete. '
                      'I understand that providing false information may result in policy '
                      'cancellation or claim rejection.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // HELPER WIDGETS
  // ═══════════════════════════════════════════════════════════════════

  /// Reusable labeled text field
  Widget _buildField(String label, TextEditingController ctrl, String hint) {
    final isRequired = label.contains('*');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          decoration: InputDecoration(hintText: hint),
          validator: isRequired
              ? (v) => (v == null || v.trim().isEmpty) ? 'This field is required' : null
              : null,
        ),
      ],
    );
  }

  /// Yes/No question with radio buttons
  Widget _buildYesNoQuestion(String question, bool? value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(fontSize: 14, color: Color(0xFF334155))),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildRadioOption('Yes', value == true, () => onChanged(true)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRadioOption('No', value == false, () => onChanged(false)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF3B5BFE) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? const Color(0xFF3B5BFE) : const Color(0xFFCBD5E1),
          ),
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : const Color(0xFF64748B),
              )),
        ),
      ),
    );
  }

  /// Dynamic list for board members or shareholders
  Widget _buildDynamicList({
    required String title,
    required List<Map<String, String>> items,
    required List<String> fields,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  items.add({for (var f in fields) f: ''});
                });
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add'),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF3B5BFE)),
            ),
          ],
        ),
        ...items.asMap().entries.map((entry) {
          final i = entry.key;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                ...fields.map((field) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: field,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onChanged: (val) => items[i][field] = val,
                  ),
                )),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => setState(() => items.removeAt(i)),
                    icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
