// ============================================================================
// step2_members.dart — Step 2: Members Management
// ============================================================================
// This step lets the user add, view, edit, and delete members on the policy.
// It matches the reference screenshots showing:
//   - A "Download template" icon, "Upload" button, and "+ Add" button
//   - An empty state message when no members are added
//   - A scrollable table showing added members with edit/delete actions
//   - A member count at the bottom
//
// FLUTTER CONCEPTS INTRODUCED:
//   - ListView.builder: Efficiently builds a scrollable list of items.
//     Unlike ListView(children: [...]), it only builds items that are visible
//     on screen — crucial for performance with large lists.
//   - showModalBottomSheet(): Opens a panel that slides up from the bottom.
//     We use it for the "Add Member" form instead of a new screen.
//   - Chip: A small rounded label (e.g., "Employee" in blue).
//   - DataTable: Flutter's built-in table widget with columns and rows.
// ============================================================================

import 'package:flutter/material.dart';
import '../../models/member.dart';

class Step2Members extends StatefulWidget {
  /// The shared list of members — this is the SAME list from the parent screen.
  /// Changes here are reflected everywhere because lists are passed by reference.
  final List<Member> members;

  /// Called when user taps "Continue" to move to the next step.
  final VoidCallback onContinue;

  /// Called when user taps "Back" to return to the previous step.
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
  /// Opens a bottom sheet form to add a new member or edit an existing one.
  /// [existingIndex] = null means "add new", otherwise it's the index to edit.
  void _showMemberForm({int? existingIndex}) {
    // Pre-fill fields if editing an existing member
    final isEditing = existingIndex != null;
    final member = isEditing ? widget.members[existingIndex] : null;

    // Controllers for each text field in the form
    final nameCtrl = TextEditingController(text: member?.name ?? '');
    final idCtrl = TextEditingController(text: member?.identityNumber ?? '');

    // Local state for dropdown selections
    MemberType selectedType = member?.type ?? MemberType.employee;
    Gender selectedGender = member?.gender ?? Gender.male;
    MaritalStatus selectedMarital = member?.maritalStatus ?? MaritalStatus.single;
    String selectedClass = member?.benefitClass ?? 'A';

    // showModalBottomSheet opens a panel from the bottom of the screen.
    // It returns a Future that completes when the sheet is dismissed.
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the sheet to be full-height
      // Shape with rounded top corners
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        // StatefulBuilder lets us use setState INSIDE the bottom sheet.
        // Without it, dropdown changes wouldn't visually update.
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              // MediaQuery.of(context).viewInsets.bottom gives us the keyboard height.
              // Adding it as bottom padding prevents the keyboard from covering the form.
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Shrink to fit content
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Sheet Title ──
                    Text(
                      isEditing ? 'Edit Member' : 'Add Member',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Name Field ──
                    const Text('Full Name *',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(hintText: 'e.g. John Smith'),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 16),

                    // ── Identity Number Field ──
                    const Text('Identity Number *',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: idCtrl,
                      decoration:
                          const InputDecoration(hintText: 'e.g. 9001015009087'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    // ── Member Type Dropdown ──
                    // Row places two fields side by side
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Type *',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600, fontSize: 14)),
                              const SizedBox(height: 6),
                              // DropdownButtonFormField shows a list of choices
                              DropdownButtonFormField<MemberType>(
                                value: selectedType,
                                decoration: const InputDecoration(),
                                items: MemberType.values.map((t) {
                                  return DropdownMenuItem(
                                    value: t,
                                    child: Text(t == MemberType.employee
                                        ? 'Employee'
                                        : 'Dependent'),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setSheetState(() => selectedType = val!);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // ── Benefit Class Dropdown ──
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Class *',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600, fontSize: 14)),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                value: selectedClass,
                                decoration: const InputDecoration(),
                                items: ['A', 'B', 'C', 'D'].map((c) {
                                  return DropdownMenuItem(
                                    value: c,
                                    child: Text('Class $c'),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setSheetState(() => selectedClass = val!);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Gender & Marital Status Row ──
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Gender *',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600, fontSize: 14)),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<Gender>(
                                value: selectedGender,
                                decoration: const InputDecoration(),
                                items: Gender.values.map((g) {
                                  return DropdownMenuItem(
                                    value: g,
                                    child: Text(
                                        g == Gender.male ? 'Male' : 'Female'),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setSheetState(() => selectedGender = val!);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Marital Status',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600, fontSize: 14)),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<MaritalStatus>(
                                value: selectedMarital,
                                decoration: const InputDecoration(),
                                items: MaritalStatus.values.map((m) {
                                  return DropdownMenuItem(
                                    value: m,
                                    child: Text(m.name[0].toUpperCase() +
                                        m.name.substring(1)),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setSheetState(() => selectedMarital = val!);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ── Save Button ──
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Validate required fields
                          if (nameCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Name is required')),
                            );
                            return;
                          }

                          // Create or update the member
                          final newMember = Member(
                            name: nameCtrl.text.trim(),
                            type: selectedType,
                            identityNumber: idCtrl.text.trim(),
                            gender: selectedGender,
                            maritalStatus: selectedMarital,
                            benefitClass: selectedClass,
                          );

                          // Update the parent's member list
                          setState(() {
                            if (isEditing) {
                              widget.members[existingIndex] = newMember;
                            } else {
                              widget.members.add(newMember);
                            }
                          });

                          // Close the bottom sheet
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B5BFE),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(isEditing ? 'Update Member' : 'Add Member'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Shows a confirmation dialog before deleting a member.
  void _deleteMember(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Member?'),
        content: Text(
          'Are you sure you want to remove ${widget.members[index].name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), // Cancel
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                widget.members.removeAt(index);
              });
              Navigator.pop(ctx); // Close dialog
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Scrollable Content Area ──
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
                  // ── Title ──
                  const Text(
                    'Members',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Action Buttons Row ──
                  // Download template, Upload, and Add buttons
                  Row(
                    children: [
                      // Download template icon button
                      IconButton(
                        onPressed: () {
                          // TODO: Download Excel template
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Template download coming soon')),
                          );
                        },
                        icon: const Icon(Icons.download_outlined),
                        tooltip: 'Download template',
                      ),

                      // Upload button with outline style
                      OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Upload Excel file
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Excel upload coming soon')),
                          );
                        },
                        icon: const Icon(Icons.upload_outlined, size: 18),
                        label: const Text('Upload'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Add Member button (filled blue)
                      ElevatedButton.icon(
                        onPressed: () => _showMemberForm(),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B5BFE),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Member List or Empty State ──
                  if (widget.members.isEmpty) ...[
                    // Empty state — shown when no members have been added
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Column(
                          children: [
                            const Text(
                              'No members added yet. Click "Add Member"\nor upload an Excel file.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Excel columns: MemberType, MemberName,\n'
                              'IdentityNumber, DateOfBirth, Gender,\n'
                              'MaritalStatus, Class, SponsorNumber',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // ── Members Table ──
                    // SingleChildScrollView with horizontal scrolling for the table
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        // Column headers
                        columns: const [
                          DataColumn(label: Text('Name',
                              style: TextStyle(fontWeight: FontWeight.w600))),
                          DataColumn(label: Text('Type',
                              style: TextStyle(fontWeight: FontWeight.w600))),
                          DataColumn(label: Text('Class',
                              style: TextStyle(fontWeight: FontWeight.w600))),
                          DataColumn(label: Text('Actions',
                              style: TextStyle(fontWeight: FontWeight.w600))),
                        ],
                        // Data rows — one for each member
                        rows: List.generate(widget.members.length, (i) {
                          final m = widget.members[i];
                          return DataRow(cells: [
                            // Name cell
                            DataCell(Text(m.name)),
                            // Type cell — shown as a colored chip/badge
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: m.type == MemberType.employee
                                      ? const Color(0xFFDBEAFE) // Light blue
                                      : const Color(0xFFF1F5F9), // Light gray
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  m.typeLabel,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: m.type == MemberType.employee
                                        ? const Color(0xFF3B5BFE)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ),
                            // Class cell
                            DataCell(Text(m.benefitClass)),
                            // Action buttons — edit and delete
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Edit button
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined,
                                        size: 20, color: Color(0xFF64748B)),
                                    onPressed: () =>
                                        _showMemberForm(existingIndex: i),
                                    tooltip: 'Edit member',
                                  ),
                                  // Delete button
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        size: 20, color: Colors.red),
                                    onPressed: () => _deleteMember(i),
                                    tooltip: 'Remove member',
                                  ),
                                ],
                              ),
                            ),
                          ]);
                        }),
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // ── Member Count ──
                  Text(
                    '${widget.members.length} member(s) added',
                    style: const TextStyle(
                      color: Color(0xFF3B5BFE),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Bottom Navigation Buttons ──
        // SafeArea ensures buttons aren't hidden behind the phone's navigation bar
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Back button (outlined style)
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
                // Continue button (filled blue)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Require at least one member before continuing
                      if (widget.members.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please add at least one member'),
                          ),
                        );
                        return;
                      }
                      widget.onContinue();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B5BFE),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Continue'),
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
