// ============================================================================
// step3_health_declaration.dart — Step 3: Health Declaration Form
// ============================================================================
// This step collects physical details for EACH member added in Step 2:
//   - Height (cm) and Weight (kg)
//   - Pregnancy status (for female members only)
//
// Matches the reference screenshot showing member cards with their details
// (name, type, gender, class) and input fields.
//
// FLUTTER CONCEPTS INTRODUCED:
//   - ListView.separated: Like ListView.builder but adds a separator widget
//     (like a divider or spacing) between each item automatically.
//   - Radio buttons: Allow selecting one option from a group (Yes/No).
//   - TextInputType.numberWithOptions: Shows a numeric keyboard with
//     a decimal point option (for entering 170.5 cm, etc.).
//   - Shrink-wrapping a ListView: physics: NeverScrollableScrollPhysics()
//     + shrinkWrap: true makes the list take only as much space as its content
//     (useful when a ListView is inside a ScrollView).
// ============================================================================

import 'package:flutter/material.dart';
import '../../models/member.dart';

class Step3HealthDeclaration extends StatefulWidget {
  /// The list of members to fill health details for.
  final List<Member> members;

  /// Called when user completes all declarations and taps "Complete".
  final VoidCallback onComplete;

  /// Called when user taps "Back".
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
  // We need a separate height and weight controller for EACH member.
  // So we use a List of controllers, one per member.
  late List<TextEditingController> _heightControllers;
  late List<TextEditingController> _weightControllers;

  @override
  void initState() {
    super.initState();
    // Create a controller for each member, pre-filled with existing values
    _heightControllers = widget.members.map((m) {
      return TextEditingController(
        text: m.heightCm != null ? m.heightCm.toString() : '',
      );
    }).toList();

    _weightControllers = widget.members.map((m) {
      return TextEditingController(
        text: m.weightKg != null ? m.weightKg.toString() : '',
      );
    }).toList();
  }

  @override
  void dispose() {
    // ALWAYS clean up controllers to prevent memory leaks
    for (var c in _heightControllers) {
      c.dispose();
    }
    for (var c in _weightControllers) {
      c.dispose();
    }
    super.dispose();
  }

  /// Validates that all members have height and weight filled in.
  bool _validate() {
    for (int i = 0; i < widget.members.length; i++) {
      final height = double.tryParse(_heightControllers[i].text);
      final weight = double.tryParse(_weightControllers[i].text);

      if (height == null || height <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Please enter a valid height for ${widget.members[i].name}'),
          ),
        );
        return false;
      }
      if (weight == null || weight <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Please enter a valid weight for ${widget.members[i].name}'),
          ),
        );
        return false;
      }

      // Save the values back to the member model
      widget.members[i].heightCm = height;
      widget.members[i].weightKg = weight;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Scrollable Content ──
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
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
                  // ── Title & Description ──
                  const Text(
                    'Member Physical Details',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter height, weight, and maternity details (if applicable) for each member.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Member Cards ──
                  // We use ListView.separated inside a Column.
                  // shrinkWrap: true makes it take only the space it needs.
                  // NeverScrollableScrollPhysics() prevents it from scrolling
                  // independently (the parent SingleChildScrollView handles scrolling).
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.members.length,
                    // Separator = the gap between each member card
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildMemberCard(index);
                    },
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
                    onPressed: () {
                      if (_validate()) {
                        widget.onComplete();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B5BFE),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Complete declarations'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a card for one member with their health declaration fields.
  Widget _buildMemberCard(int index) {
    final member = widget.members[index];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Slightly darker background to differentiate from the outer card
        color: const Color(0xFFFAFBFD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Member Name ──
          Text(
            member.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),

          // ── Member Details Line ──
          // Shows type · gender · class (e.g., "Employee · Male · A")
          Text(
            '${member.typeLabel} · ${member.genderLabel} · ${member.benefitClass}',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),

          // ── Height & Weight Fields (side by side) ──
          Row(
            children: [
              // Height field
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Height (cm) *',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFFEF4444), // Red asterisk color
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _heightControllers[index],
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        hintText: 'e.g. 170',
                        hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Weight field
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weight (kg) *',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _weightControllers[index],
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        hintText: 'e.g. 70',
                        hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Pregnancy Question (only for female members) ──
          // The "if" keyword inside a list checks a condition before adding widgets.
          if (member.gender == Gender.female) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Is the member currently\npregnant?',
                    style: TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                  ),
                ),
                // Radio buttons for Yes/No selection
                // Radio<bool> means the value type is a boolean (true/false)
                Row(
                  children: [
                    Radio<bool>(
                      value: true, // This radio represents "Yes"
                      groupValue: member.isPregnant, // Current selection
                      activeColor: const Color(0xFF3B5BFE),
                      onChanged: (val) {
                        setState(() => member.isPregnant = val!);
                      },
                    ),
                    const Text('Yes'),
                    Radio<bool>(
                      value: false, // This radio represents "No"
                      groupValue: member.isPregnant,
                      activeColor: const Color(0xFF3B5BFE),
                      onChanged: (val) {
                        setState(() => member.isPregnant = val!);
                      },
                    ),
                    const Text('No'),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
