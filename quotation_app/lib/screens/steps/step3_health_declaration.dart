// ============================================================================
// step3_health_declaration.dart — Step 3: Enhanced Health Declaration
// ============================================================================
// ENHANCEMENTS FROM REFERENCE:
//   - Live BMI calculation with color-coded category (Normal/Overweight/Obese)
//   - 5 health declaration questions per member (Yes/No toggles)
//   - Expected delivery date picker for pregnant females
//   - Maternity leave days input for pregnant females
//   - Health declaration summary ('Yes' if any question answered Yes)
//   - Expandable member cards with smooth animations
//
// FLUTTER CONCEPTS:
//   - ExpansionTile: A collapsible/expandable section with a title
//   - Switch: A toggle button (like iOS switch)
//   - AnimatedCrossFade: Smoothly transitions between two widgets based on a condition
// ============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/member.dart';

class Step3HealthDeclaration extends StatefulWidget {
  final List<Member> members;
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const Step3HealthDeclaration({
    super.key,
    required this.members,
    required this.onComplete,
    required this.onBack,
  });

  @override
  State<Step3HealthDeclaration> createState() => _Step3HealthDeclarationState();
}

class _Step3HealthDeclarationState extends State<Step3HealthDeclaration> {
  // ── Controllers ──
  // One height and weight controller per member
  late List<TextEditingController> _heightControllers;
  late List<TextEditingController> _weightControllers;
  late List<TextEditingController> _maternityDaysControllers;

  @override
  void initState() {
    super.initState();
    _heightControllers = widget.members.map((m) {
      return TextEditingController(text: m.heightCm?.toString() ?? '');
    }).toList();
    _weightControllers = widget.members.map((m) {
      return TextEditingController(text: m.weightKg?.toString() ?? '');
    }).toList();
    _maternityDaysControllers = widget.members.map((m) {
      return TextEditingController(text: m.maternityDays ?? '');
    }).toList();
  }

  @override
  void dispose() {
    for (var c in _heightControllers) { c.dispose(); }
    for (var c in _weightControllers) { c.dispose(); }
    for (var c in _maternityDaysControllers) { c.dispose(); }
    super.dispose();
  }

  /// Updates the member's BMI in real-time as the user types height/weight
  void _updateBmi(int index) {
    final h = double.tryParse(_heightControllers[index].text);
    final w = double.tryParse(_weightControllers[index].text);
    setState(() {
      widget.members[index].heightCm = h;
      widget.members[index].weightKg = w;
    });
  }

  /// Validates all members have height and weight
  bool _validate() {
    for (int i = 0; i < widget.members.length; i++) {
      final height = double.tryParse(_heightControllers[i].text);
      final weight = double.tryParse(_weightControllers[i].text);

      if (height == null || height <= 0) {
        _showError('Please enter a valid height for ${widget.members[i].name}');
        return false;
      }
      if (weight == null || weight <= 0) {
        _showError('Please enter a valid weight for ${widget.members[i].name}');
        return false;
      }

      // Save values to the member model
      widget.members[i].heightCm = height;
      widget.members[i].weightKg = weight;
      widget.members[i].maternityDays = _maternityDaysControllers[i].text;

      // Set health declaration based on answers
      final hasYes = widget.members[i].healthAnswers.any((a) => a);
      widget.members[i].healthDeclaration = hasYes ? 'Yes' : 'No';
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: const Color(0xFFEF4444)),
    );
  }

  /// Returns a color based on BMI value
  Color _bmiColor(double bmi) {
    if (bmi < 18.5) return const Color(0xFF3B82F6); // Blue - underweight
    if (bmi < 25) return const Color(0xFF22C55E);    // Green - normal
    if (bmi < 30) return const Color(0xFFF97316);    // Orange - overweight
    return const Color(0xFFEF4444);                    // Red - obese
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Section 1: Physical Details ──
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
                      // Title with icon
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B5BFE).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.monitor_heart_outlined,
                                color: Color(0xFF3B5BFE), size: 22),
                          ),
                          const SizedBox(width: 14),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Member Physical Details',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A))),
                              Text('Height, weight & maternity info',
                                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Per-Member Physical Details Cards ──
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.members.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) => _buildPhysicalCard(index),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Section 2: Health Questions ──
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
                      // Title
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF97316).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.assignment_outlined,
                                color: Color(0xFFF97316), size: 22),
                          ),
                          const SizedBox(width: 14),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Health Declaration',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A))),
                              Text('Answer for each member',
                                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Answering "Yes" to any question will add a 15% health surcharge to the member\'s premium.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      ),
                      const SizedBox(height: 16),

                      // ── Per-Member Health Questions ──
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.members.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _buildHealthQuestionsCard(index),
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
                    onPressed: () {
                      if (_validate()) widget.onComplete();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B5BFE),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Complete Declarations'),
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

  /// Physical details card for one member (height, weight, BMI, pregnancy)
  Widget _buildPhysicalCard(int index) {
    final member = widget.members[index];
    final bmi = member.bmi;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Member Header ──
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B5BFE).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    member.name.isNotEmpty ? member.name[0] : '?',
                    style: const TextStyle(color: Color(0xFF3B5BFE),
                        fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(member.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A))),
                    Text('${member.typeLabel} · ${member.genderLabel} · ${member.benefitClass}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Height & Weight ──
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Height (cm) *',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF0F172A))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _heightControllers[index],
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(hintText: 'e.g. 170'),
                      onChanged: (_) => _updateBmi(index),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Weight (kg) *',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF0F172A))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _weightControllers[index],
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(hintText: 'e.g. 70'),
                      onChanged: (_) => _updateBmi(index),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── BMI Display (animated) ──
          // Shows only when both height and weight are filled in
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: bmi != null
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: bmi != null ? _bmiColor(bmi).withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: bmi != null ? _bmiColor(bmi).withOpacity(0.3) : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.monitor_weight_outlined,
                      size: 18, color: bmi != null ? _bmiColor(bmi) : Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'BMI: ${bmi?.toStringAsFixed(1) ?? '—'}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: bmi != null ? _bmiColor(bmi) : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    member.bmiCategory,
                    style: TextStyle(
                      fontSize: 13,
                      color: bmi != null ? _bmiColor(bmi) : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),

          // ── Pregnancy Section (female only) ──
          if (member.gender == Gender.female) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Text('Is the member currently pregnant?',
                      style: TextStyle(fontSize: 13, color: Color(0xFF0F172A))),
                ),
                Switch(
                  value: member.isPregnant,
                  activeColor: const Color(0xFF3B5BFE),
                  onChanged: (val) {
                    setState(() => member.isPregnant = val);
                  },
                ),
              ],
            ),
            // ── Pregnancy Details (if pregnant) ──
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: member.isPregnant
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Expected Delivery *',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: member.expectedDeliveryDate ?? DateTime.now().add(const Duration(days: 90)),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 300)),
                                builder: (ctx, child) => Theme(
                                  data: Theme.of(ctx).copyWith(
                                    colorScheme: const ColorScheme.light(primary: Color(0xFF3B5BFE)),
                                  ),
                                  child: child!,
                                ),
                              );
                              if (picked != null) {
                                setState(() => member.expectedDeliveryDate = picked);
                              }
                            },
                            child: AbsorbPointer(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  hintText: member.expectedDeliveryDate != null
                                      ? DateFormat('dd MMM yyyy').format(member.expectedDeliveryDate!)
                                      : 'Select date',
                                  hintStyle: TextStyle(
                                    fontSize: 13,
                                    color: member.expectedDeliveryDate != null
                                        ? const Color(0xFF0F172A)
                                        : const Color(0xFF94A3B8),
                                  ),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Maternity Days',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _maternityDaysControllers[index],
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'e.g. 70',
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ],
        ],
      ),
    );
  }

  /// Health questions card for one member — expandable with 5 Yes/No questions
  Widget _buildHealthQuestionsCard(int index) {
    final member = widget.members[index];
    final yesCount = member.healthAnswers.where((a) => a).length;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: yesCount > 0
              ? const Color(0xFFFED7AA)  // Orange border if any "Yes"
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Theme(
        // Remove the default divider line in ExpansionTile
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          // ── Header: Member name with health status ──
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: yesCount > 0
                  ? const Color(0xFFF97316).withOpacity(0.1)
                  : const Color(0xFF22C55E).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              yesCount > 0 ? Icons.warning_amber : Icons.check_circle_outline,
              size: 18,
              color: yesCount > 0 ? const Color(0xFFF97316) : const Color(0xFF22C55E),
            ),
          ),
          title: Text(member.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          subtitle: Text(
            yesCount > 0
                ? '$yesCount condition(s) declared — +15% surcharge'
                : 'No conditions declared',
            style: TextStyle(
              fontSize: 12,
              color: yesCount > 0 ? const Color(0xFFF97316) : const Color(0xFF22C55E),
            ),
          ),

          // ── Body: 5 Health Questions ──
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          children: [
            ...List.generate(healthQuestions.length, (qi) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: member.healthAnswers[qi]
                        ? const Color(0xFFFFF7ED)
                        : const Color(0xFFFAFBFD),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: member.healthAnswers[qi]
                          ? const Color(0xFFFED7AA)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          healthQuestions[qi],
                          style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Yes/No toggle
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildAnswerChip('Yes', member.healthAnswers[qi], true, () {
                            setState(() => member.healthAnswers[qi] = true);
                          }),
                          const SizedBox(width: 6),
                          _buildAnswerChip('No', !member.healthAnswers[qi], false, () {
                            setState(() => member.healthAnswers[qi] = false);
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Builds a small Yes/No chip button
  Widget _buildAnswerChip(String label, bool isSelected, bool isYes, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isYes ? const Color(0xFFF97316) : const Color(0xFF22C55E))
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? (isYes ? const Color(0xFFF97316) : const Color(0xFF22C55E))
                : const Color(0xFFCBD5E1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
