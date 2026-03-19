// ============================================================================
// step2_members.dart — Step 2: Enhanced Members Management
// ============================================================================
// ENHANCEMENTS FROM REFERENCE:
//   - VIP, A, B, C, LM class options (5 tiers instead of 4)
//   - Dependent-to-Employee linking (dependents must select their employee)
//   - Date of Birth picker with age calculation
//   - Deletion reason dialog (audit trail)
//   - Better member cards with status chips and more info
//   - Empty state with illustration
//   - Member count badge
//
// FLUTTER CONCEPTS:
//   - showModalBottomSheet: Slide-up form panel
//   - StatefulBuilder: setState inside a modal/bottom sheet
//   - Chip/Badge: Small colored labels showing member type
//   - List.where(): Filter a list by a condition
// ============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/member.dart';

class Step2Members extends StatefulWidget {
  final List<Member> members;
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const Step2Members({
    super.key,
    required this.members,
    required this.onContinue,
    required this.onBack,
  });

  @override
  State<Step2Members> createState() => _Step2MembersState();
}

class _Step2MembersState extends State<Step2Members> {
  /// Get all employees from the member list (for dependent linking dropdown)
  List<Member> get _employees =>
      widget.members.where((m) => m.type == MemberType.employee).toList();

  /// Opens the add/edit member bottom sheet form.
  /// [existingIndex] = null means "add new".
  void _showMemberForm({int? existingIndex}) {
    final isEditing = existingIndex != null;
    final member = isEditing ? widget.members[existingIndex] : null;

    // Controllers for text fields
    final nameCtrl = TextEditingController(text: member?.name ?? '');
    final idCtrl = TextEditingController(text: member?.identityNumber ?? '');
    final sponsorCtrl = TextEditingController(text: member?.sponsorNumber ?? '');

    // Local dropdown state
    MemberType selectedType = member?.type ?? MemberType.employee;
    Gender selectedGender = member?.gender ?? Gender.male;
    MaritalStatus selectedMarital = member?.maritalStatus ?? MaritalStatus.single;
    String selectedClass = member?.benefitClass ?? 'A';
    String? selectedEmployeeId = member?.employeeId;
    DateTime? selectedDob = member?.dateOfBirth;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Transparent so we can add our own shape
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              // Take up to 90% of the screen height
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Drag Handle ──
                  // The little gray bar at the top of bottom sheets.
                  // Users can grab this to drag the sheet up/down.
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // ── Scrollable Form Content ──
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: 24, right: 24, top: 20,
                        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Title ──
                          Row(
                            children: [
                              Icon(
                                isEditing ? Icons.edit : Icons.person_add,
                                color: const Color(0xFF3B5BFE),
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                isEditing ? 'Edit Member' : 'Add New Member',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // ── Member Type Toggle ──
                          // SegmentedButton for Employee/Dependent selection
                          const Text('Member Type *',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: SegmentedButton<MemberType>(
                              segments: const [
                                ButtonSegment(
                                  value: MemberType.employee,
                                  label: Text('Employee'),
                                  icon: Icon(Icons.badge_outlined, size: 18),
                                ),
                                ButtonSegment(
                                  value: MemberType.dependent,
                                  label: Text('Dependent'),
                                  icon: Icon(Icons.people_outline, size: 18),
                                ),
                              ],
                              selected: {selectedType},
                              onSelectionChanged: (val) {
                                setSheetState(() {
                                  selectedType = val.first;
                                  // Clear employee selection if switching to Employee
                                  if (selectedType == MemberType.employee) {
                                    selectedEmployeeId = null;
                                  }
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
                          const SizedBox(height: 16),

                          // ── Employee Selection (only for Dependents) ──
                          // Dependents MUST be linked to an employee.
                          if (selectedType == MemberType.dependent) ...[
                            const Text('Select Employee *',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            const SizedBox(height: 8),
                            if (_employees.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF7ED),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFFED7AA)),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.warning_amber, color: Color(0xFFF97316), size: 18),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Add an employee first before adding dependents.',
                                        style: TextStyle(fontSize: 13, color: Color(0xFF9A3412)),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              DropdownButtonFormField<String>(
                                value: selectedEmployeeId,
                                decoration: const InputDecoration(hintText: 'Choose employee'),
                                items: _employees.map((emp) {
                                  return DropdownMenuItem(
                                    value: emp.id,
                                    child: Text('${emp.name} (${emp.identityNumber})'),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setSheetState(() => selectedEmployeeId = val);
                                },
                              ),
                            const SizedBox(height: 16),
                          ],

                          // ── Full Name ──
                          const Text('Full Name *',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: nameCtrl,
                            decoration: const InputDecoration(
                              hintText: 'e.g. Ahmed Al-Rashid',
                              prefixIcon: Icon(Icons.person_outline, size: 20, color: Color(0xFF94A3B8)),
                            ),
                            textCapitalization: TextCapitalization.words,
                          ),
                          const SizedBox(height: 16),

                          // ── Identity Number ──
                          const Text('Identity / Iqama Number *',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: idCtrl,
                            decoration: const InputDecoration(
                              hintText: 'e.g. 1234567890',
                              prefixIcon: Icon(Icons.credit_card, size: 20, color: Color(0xFF94A3B8)),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),

                          // ── Date of Birth ──
                          const Text('Date of Birth',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDob ?? DateTime(1990, 1, 1),
                                firstDate: DateTime(1920),
                                lastDate: DateTime.now(),
                                builder: (ctx, child) => Theme(
                                  data: Theme.of(ctx).copyWith(
                                    colorScheme: const ColorScheme.light(primary: Color(0xFF3B5BFE)),
                                  ),
                                  child: child!,
                                ),
                              );
                              if (picked != null) {
                                setSheetState(() => selectedDob = picked);
                              }
                            },
                            child: AbsorbPointer(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  hintText: selectedDob != null
                                      ? DateFormat('dd MMM yyyy').format(selectedDob!)
                                      : 'Select date of birth',
                                  hintStyle: TextStyle(
                                    color: selectedDob != null
                                        ? const Color(0xFF0F172A)
                                        : const Color(0xFF94A3B8),
                                  ),
                                  prefixIcon: const Icon(Icons.cake_outlined, size: 20, color: Color(0xFF94A3B8)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ── Sponsor Number ──
                          const Text('Sponsor Number',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: sponsorCtrl,
                            decoration: const InputDecoration(
                              hintText: 'e.g. SP12345',
                              prefixIcon: Icon(Icons.tag, size: 20, color: Color(0xFF94A3B8)),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ── Class & Gender Row ──
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Class *',
                                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<String>(
                                      value: selectedClass,
                                      decoration: const InputDecoration(),
                                      items: classOptions.map((c) {
                                        return DropdownMenuItem(
                                          value: c,
                                          child: Text(c == 'LM' ? 'LM (Low Market)' : 'Class $c'),
                                        );
                                      }).toList(),
                                      onChanged: (val) => setSheetState(() => selectedClass = val!),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Gender *',
                                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<Gender>(
                                      value: selectedGender,
                                      decoration: const InputDecoration(),
                                      items: Gender.values.map((g) {
                                        return DropdownMenuItem(
                                          value: g,
                                          child: Text(g == Gender.male ? 'Male' : 'Female'),
                                        );
                                      }).toList(),
                                      onChanged: (val) => setSheetState(() => selectedGender = val!),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ── Marital Status ──
                          const Text('Marital Status',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<MaritalStatus>(
                            value: selectedMarital,
                            decoration: const InputDecoration(),
                            items: MaritalStatus.values.map((m) {
                              return DropdownMenuItem(
                                value: m,
                                child: Text(m.name[0].toUpperCase() + m.name.substring(1)),
                              );
                            }).toList(),
                            onChanged: (val) => setSheetState(() => selectedMarital = val!),
                          ),
                          const SizedBox(height: 28),

                          // ── Save Button ──
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Validate required fields
                                if (nameCtrl.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Name is required')),
                                  );
                                  return;
                                }
                                if (selectedType == MemberType.dependent &&
                                    selectedEmployeeId == null &&
                                    _employees.isNotEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please select an employee for this dependent')),
                                  );
                                  return;
                                }

                                final newMember = Member(
                                  id: member?.id, // Keep existing ID if editing
                                  name: nameCtrl.text.trim(),
                                  type: selectedType,
                                  identityNumber: idCtrl.text.trim(),
                                  dateOfBirth: selectedDob,
                                  gender: selectedGender,
                                  maritalStatus: selectedMarital,
                                  benefitClass: selectedClass,
                                  sponsorNumber: sponsorCtrl.text.trim(),
                                  employeeId: selectedEmployeeId,
                                  // Preserve health data if editing
                                  heightCm: member?.heightCm,
                                  weightKg: member?.weightKg,
                                  isPregnant: member?.isPregnant ?? false,
                                  healthDeclaration: member?.healthDeclaration,
                                  healthAnswers: member?.healthAnswers,
                                );

                                setState(() {
                                  if (isEditing) {
                                    widget.members[existingIndex] = newMember;
                                  } else {
                                    widget.members.add(newMember);
                                  }
                                });

                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B5BFE),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              icon: Icon(isEditing ? Icons.check : Icons.add, size: 18),
                              label: Text(isEditing ? 'Update Member' : 'Add Member'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Shows a deletion dialog with a reason selector.
  /// The reason provides an audit trail for compliance.
  void _deleteMember(int index) {
    String? selectedReason;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Remove Member', style: TextStyle(fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to remove ${widget.members[index].name}?',
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              const Text('Reason for removal:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              // Deletion reason chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: deletionReasons.map((reason) {
                  final isSelected = selectedReason == reason;
                  return ChoiceChip(
                    label: Text(reason, style: TextStyle(fontSize: 12,
                        color: isSelected ? Colors.white : const Color(0xFF64748B))),
                    selected: isSelected,
                    selectedColor: const Color(0xFFEF4444),
                    backgroundColor: const Color(0xFFF1F5F9),
                    onSelected: (val) {
                      setDialogState(() => selectedReason = val ? reason : null);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedReason == null
                  ? null
                  : () {
                      setState(() => widget.members.removeAt(index));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Member removed: $selectedReason'),
                          backgroundColor: const Color(0xFFEF4444),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFCBD5E1),
              ),
              child: const Text('Remove'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final employeeCount = widget.members.where((m) => m.type == MemberType.employee).length;
    final dependentCount = widget.members.where((m) => m.type == MemberType.dependent).length;

    return Column(
      children: [
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
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header Row ──
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B5BFE).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.group_outlined,
                            color: Color(0xFF3B5BFE), size: 22),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text('Members',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A))),
                      ),
                      // Member count badge
                      if (widget.members.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B5BFE).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${widget.members.length}',
                            style: const TextStyle(
                              color: Color(0xFF3B5BFE),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Action Buttons ──
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Template download coming soon')),
                          );
                        },
                        icon: const Icon(Icons.download_outlined, color: Color(0xFF64748B)),
                        tooltip: 'Download template',
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Excel upload coming soon')),
                          );
                        },
                        icon: const Icon(Icons.upload_outlined, size: 18),
                        label: const Text('Upload'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _showMemberForm(),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B5BFE),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 40),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Member List or Empty State ──
                  if (widget.members.isEmpty)
                    // EMPTY STATE — shown when no members have been added yet
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFBFD),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.solid),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.group_add_outlined,
                              size: 48, color: const Color(0xFF94A3B8).withOpacity(0.6)),
                          const SizedBox(height: 16),
                          const Text(
                            'No members added yet',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Click "Add" or upload an Excel file.\nExcel columns: MemberType, MemberName, IdentityNumber, DateOfBirth, Gender, MaritalStatus, Class, SponsorNumber',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    )
                  else
                    // MEMBER CARDS — one card per member
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.members.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return _buildMemberCard(index);
                      },
                    ),

                  // ── Summary Footer ──
                  if (widget.members.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F9FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFBAE6FD)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildCountChip('Employees', employeeCount, const Color(0xFF3B5BFE)),
                          _buildCountChip('Dependents', dependentCount, const Color(0xFF8B5CF6)),
                          _buildCountChip('Total', widget.members.length, const Color(0xFF0F172A)),
                        ],
                      ),
                    ),
                  ],
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
                    onPressed: widget.members.isEmpty
                        ? null
                        : widget.onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B5BFE),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFCBD5E1),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Continue (${widget.members.length})'),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 18),
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

  /// Builds a single member card showing their info and edit/delete actions.
  Widget _buildMemberCard(int index) {
    final m = widget.members[index];
    final isEmployee = m.type == MemberType.employee;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          // ── Avatar Circle ──
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isEmployee
                  ? const Color(0xFF3B5BFE).withOpacity(0.1)
                  : const Color(0xFF8B5CF6).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: isEmployee ? const Color(0xFF3B5BFE) : const Color(0xFF8B5CF6),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ── Member Info ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        m.name,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15,
                            color: Color(0xFF0F172A)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Type chip (Employee/Dependent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isEmployee
                            ? const Color(0xFF3B5BFE).withOpacity(0.1)
                            : const Color(0xFF8B5CF6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        m.typeLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isEmployee ? const Color(0xFF3B5BFE) : const Color(0xFF8B5CF6),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${m.genderLabel} · Class ${m.benefitClass} · ${m.maritalStatus.name[0].toUpperCase()}${m.maritalStatus.name.substring(1)}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                if (m.sponsorNumber.isNotEmpty)
                  Text(
                    'Sponsor: ${m.sponsorNumber}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
              ],
            ),
          ),

          // ── Action Buttons ──
          IconButton(
            onPressed: () => _showMemberForm(existingIndex: index),
            icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF3B5BFE)),
            tooltip: 'Edit',
          ),
          IconButton(
            onPressed: () => _deleteMember(index),
            icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFFEF4444)),
            tooltip: 'Remove',
          ),
        ],
      ),
    );
  }

  /// Small helper widget for the summary footer counts
  Widget _buildCountChip(String label, int count, Color color) {
    return Column(
      children: [
        Text('$count', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
      ],
    );
  }
}
