// ============================================================================
// policy_crud_screen.dart — Beautiful Policy CRUD Screen
// ============================================================================
// THIS IS THE MAIN SCREEN where you can:
//   ✅ CREATE a new policy (tap the + button)
//   ✅ READ / view all policies (the main list)
//   ✅ UPDATE / edit a policy (tap on a policy card, then edit)
//   ✅ DELETE a policy (swipe left or tap delete in the form)
//
// FLUTTER CONCEPTS USED:
//   - ConsumerStatefulWidget: A widget that uses BOTH setState AND Riverpod
//   - ref.watch(): Subscribes to a provider — rebuilds when data changes
//   - ref.read(): Reads a provider once (for calling methods, not watching)
//   - showModalBottomSheet: Slide-up panel for the add/edit form
//   - Dismissible: Swipe-to-delete on list items
//   - AnimatedList: Animated insertions/removals (smooth UX)
//   - SnackBar: Toast-like messages at the bottom of the screen
//
// STATE FLOW:
//   1. Screen opens → policyProvider loads data (shows spinner)
//   2. Data loaded → cards appear with animation
//   3. User taps + → bottom sheet form appears
//   4. User fills form → taps Save → policy added to list
//   5. User taps card → bottom sheet with pre-filled data
//   6. User swipes card left → delete confirmation dialog
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/policy_model.dart';
import '../services/policy_providers.dart';

/// The main CRUD screen — uses ConsumerStatefulWidget because we need
/// both Riverpod (ref.watch) AND local state (form controllers).
class PolicyCrudScreen extends ConsumerStatefulWidget {
  const PolicyCrudScreen({super.key});

  @override
  ConsumerState<PolicyCrudScreen> createState() => _PolicyCrudScreenState();
}

class _PolicyCrudScreenState extends ConsumerState<PolicyCrudScreen>
    with SingleTickerProviderStateMixin {
  // ── Animation ──
  /// Controls the staggered entry animation for the policy cards
  late AnimationController _animController;

  // ── Search / Filter ──
  /// Current search query text
  String _searchQuery = '';

  /// Currently selected status filter (null = show all)
  PolicyStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  /// Opens the add/edit form as a bottom sheet.
  ///
  /// [existingPolicy] — if not null, we're EDITING. If null, we're CREATING.
  ///
  /// BOTTOM SHEET = a panel that slides up from the bottom of the screen.
  /// It's great for forms because:
  ///   - It doesn't navigate away from the current screen
  ///   - The user can dismiss it by swiping down
  ///   - It feels natural on mobile devices
  void _showPolicyForm({PolicyModel? existingPolicy}) {
    final isEditing = existingPolicy != null;

    // ── Form Controllers ──
    // Each TextEditingController manages one text field.
    // If editing, pre-fill with existing data.
    final nameCtrl = TextEditingController(
        text: existingPolicy?.sponsorName ?? '');
    final numberCtrl = TextEditingController(
        text: existingPolicy?.sponsorNumber ?? '');
    final membersCtrl = TextEditingController(
        text: existingPolicy?.memberCount.toString() ?? '');
    final premiumCtrl = TextEditingController(
        text: existingPolicy?.totalPremium.toStringAsFixed(0) ?? '');
    final notesCtrl = TextEditingController(
        text: existingPolicy?.notes ?? '');

    // Local state for dropdowns and date picker
    DateTime selectedDate = existingPolicy?.effectiveDate ?? DateTime.now();
    PolicyStatus selectedStatus = existingPolicy?.status ?? PolicyStatus.draft;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,          // Allows the sheet to be taller
      backgroundColor: Colors.transparent, // So we can add rounded corners
      builder: (ctx) {
        // StatefulBuilder lets us use setState INSIDE the bottom sheet
        // (normally bottom sheets are stateless)
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.92,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Drag Handle ──
                  // The little gray bar users can grab to drag the sheet
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // ── Header ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Row(
                      children: [
                        // Icon container
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B5BFE), Color(0xFF6C8CFF)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            isEditing ? Icons.edit_note_rounded : Icons.add_circle_outline,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEditing ? 'Edit Policy' : 'Create New Policy',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              isEditing
                                  ? 'Update the policy details below'
                                  : 'Fill in the details to create a policy',
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Scrollable Form ──
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: 24,
                        right: 24,
                        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Sponsor Name ──
                          _formLabel('Sponsor Name *'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: nameCtrl,
                            decoration: _inputDeco(
                              hint: 'e.g. Acme Corporation Ltd.',
                              icon: Icons.business_outlined,
                            ),
                            textCapitalization: TextCapitalization.words,
                          ),
                          const SizedBox(height: 18),

                          // ── Sponsor Number & Member Count ──
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _formLabel('Sponsor No. *'),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: numberCtrl,
                                      decoration: _inputDeco(
                                        hint: 'SP12345',
                                        icon: Icons.tag,
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
                                    _formLabel('Members *'),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: membersCtrl,
                                      decoration: _inputDeco(
                                        hint: '10',
                                        icon: Icons.people_outline,
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // ── Premium & Status Row ──
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _formLabel('Premium (SAR) *'),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: premiumCtrl,
                                      decoration: _inputDeco(
                                        hint: '50000',
                                        icon: Icons.payments_outlined,
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _formLabel('Status'),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<PolicyStatus>(
                                      value: selectedStatus,
                                      decoration: _inputDeco(hint: '', icon: null),
                                      items: PolicyStatus.values.map((s) {
                                        return DropdownMenuItem(
                                          value: s,
                                          child: Text(
                                            s.name[0].toUpperCase() +
                                                s.name.substring(1),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        setSheetState(
                                            () => selectedStatus = val!);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // ── Effective Date ──
                          _formLabel('Policy Effective Date *'),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime(2024),
                                lastDate: DateTime(2030),
                                builder: (ctx, child) => Theme(
                                  data: Theme.of(ctx).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: Color(0xFF3B5BFE),
                                    ),
                                  ),
                                  child: child!,
                                ),
                              );
                              if (picked != null) {
                                setSheetState(() => selectedDate = picked);
                              }
                            },
                            child: AbsorbPointer(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  hintText: DateFormat('dd MMM yyyy')
                                      .format(selectedDate),
                                  hintStyle: const TextStyle(
                                      color: Color(0xFF0F172A)),
                                  prefixIcon: const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 20,
                                    color: Color(0xFF94A3B8),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF5F7FA),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFE2E8F0)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFE2E8F0)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // ── Notes (optional) ──
                          _formLabel('Notes (optional)'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: notesCtrl,
                            decoration: _inputDeco(
                              hint: 'Any additional notes...',
                              icon: Icons.notes_outlined,
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 28),

                          // ── Save / Delete Buttons ──
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _savePolicy(
                                context: context,
                                isEditing: isEditing,
                                existingId: existingPolicy?.id,
                                nameCtrl: nameCtrl,
                                numberCtrl: numberCtrl,
                                membersCtrl: membersCtrl,
                                premiumCtrl: premiumCtrl,
                                notesCtrl: notesCtrl,
                                selectedDate: selectedDate,
                                selectedStatus: selectedStatus,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B5BFE),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 4,
                                shadowColor:
                                    const Color(0xFF3B5BFE).withOpacity(0.3),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isEditing
                                        ? Icons.save_outlined
                                        : Icons.add_circle_outline,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isEditing ? 'Save Changes' : 'Create Policy',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Delete button (only when editing)
                          if (isEditing) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _confirmDelete(existingPolicy!);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFEF4444),
                                  side: const BorderSide(
                                      color: Color(0xFFEF4444)),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.delete_outline, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Delete Policy',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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

  /// Validates and saves the policy (create or update).
  void _savePolicy({
    required BuildContext context,
    required bool isEditing,
    String? existingId,
    required TextEditingController nameCtrl,
    required TextEditingController numberCtrl,
    required TextEditingController membersCtrl,
    required TextEditingController premiumCtrl,
    required TextEditingController notesCtrl,
    required DateTime selectedDate,
    required PolicyStatus selectedStatus,
  }) {
    // ── Validation ──
    if (nameCtrl.text.trim().isEmpty || numberCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    final memberCount = int.tryParse(membersCtrl.text) ?? 0;
    final premium = double.tryParse(premiumCtrl.text) ?? 0;

    if (memberCount <= 0 || premium <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Members and premium must be greater than zero'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    // Build the policy object
    final policy = PolicyModel(
      id: existingId,
      sponsorName: nameCtrl.text.trim(),
      sponsorNumber: numberCtrl.text.trim(),
      memberCount: memberCount,
      totalPremium: premium,
      effectiveDate: selectedDate,
      status: selectedStatus,
      notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
    );

    // ── Call the appropriate CRUD operation ──
    if (isEditing) {
      ref.read(policyProvider.notifier).updatePolicy(existingId!, policy);
    } else {
      ref.read(policyProvider.notifier).addPolicy(policy);
    }

    Navigator.pop(context);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEditing ? '✅ Policy updated!' : '✅ Policy created!'),
        backgroundColor: const Color(0xFF22C55E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Shows a confirmation dialog before deleting a policy.
  void _confirmDelete(PolicyModel policy) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 28),
            SizedBox(width: 10),
            Text('Delete Policy?'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete the policy for "${policy.sponsorName}"?\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(policyProvider.notifier).deletePolicy(policy.id!);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('🗑️ Policy deleted'),
                  backgroundColor: const Color(0xFFEF4444),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ── Watch the policy state ──
    // ref.watch() subscribes to changes — whenever policyProvider updates,
    // this entire build method re-runs automatically!
    final policyState = ref.watch(policyProvider);

    // ── Filter & Search ──
    // Apply search query and status filter to the policy list
    final filtered = policyState.policies.where((p) {
      final matchesSearch = _searchQuery.isEmpty ||
          p.sponsorName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.sponsorNumber.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter =
          _filterStatus == null || p.status == _filterStatus;
      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),

      // ── App Bar ──
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Policy Management',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                ref.read(policyProvider.notifier).loadPolicies(),
            tooltip: 'Refresh from server',
          ),
        ],
      ),

      // ── Body ──
      body: policyState.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B5BFE)))
          : Column(
              children: [
                // ── Stats Header ──
                _buildStatsHeader(policyState.policies),

                // ── Search Bar ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Search by sponsor name or number...',
                      hintStyle: const TextStyle(
                          color: Color(0xFF94A3B8), fontSize: 14),
                      prefixIcon: const Icon(Icons.search,
                          color: Color(0xFF94A3B8), size: 20),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Status Filter Chips ──
                _buildFilterChips(),
                const SizedBox(height: 8),

                // ── Policy List ──
                Expanded(
                  child: filtered.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _buildPolicyCard(filtered[index], index);
                          },
                        ),
                ),
              ],
            ),

      // ── FAB: Add New Policy ──
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPolicyForm(),
        backgroundColor: const Color(0xFF3B5BFE),
        foregroundColor: Colors.white,
        elevation: 6,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Policy',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // UI BUILDER METHODS
  // ═══════════════════════════════════════════════════════════════════

  /// Stats cards at the top showing totals
  Widget _buildStatsHeader(List<PolicyModel> policies) {
    final totalPremium = policies.fold(0.0, (sum, p) => sum + p.totalPremium);
    final approved = policies.where((p) => p.status == PolicyStatus.approved).length;
    final pending = policies.where((p) => p.status == PolicyStatus.pending).length;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B5BFE), Color(0xFF6C8CFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B5BFE).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('Total', '${policies.length}', Icons.description_outlined),
          Container(width: 1, height: 40, color: Colors.white30),
          _statItem('Approved', '$approved', Icons.check_circle_outline),
          Container(width: 1, height: 40, color: Colors.white30),
          _statItem(
            'Premium',
            'SAR ${NumberFormat.compact().format(totalPremium)}',
            Icons.payments_outlined,
          ),
          Container(width: 1, height: 40, color: Colors.white30),
          _statItem('Pending', '$pending', Icons.hourglass_empty_rounded),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16)),
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }

  /// Horizontal scrollable status filter chips
  Widget _buildFilterChips() {
    final statuses = [null, ...PolicyStatus.values];
    final labels = ['All', 'Draft', 'Pending', 'Approved', 'Rejected', 'Expired'];
    final colors = [
      const Color(0xFF3B5BFE),
      const Color(0xFF64748B),
      const Color(0xFFF59E0B),
      const Color(0xFF22C55E),
      const Color(0xFFEF4444),
      const Color(0xFF94A3B8),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(statuses.length, (i) {
          final isSelected = _filterStatus == statuses[i];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(labels[i]),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              backgroundColor: Colors.white,
              selectedColor: colors[i],
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isSelected ? colors[i] : const Color(0xFFE2E8F0),
                ),
              ),
              onSelected: (_) {
                setState(() {
                  _filterStatus = isSelected ? null : statuses[i];
                });
              },
            ),
          );
        }),
      ),
    );
  }

  /// Individual policy card
  Widget _buildPolicyCard(PolicyModel policy, int index) {
    final currencyFormat = NumberFormat.currency(symbol: 'SAR ', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy');

    // Status color mapping
    final statusColors = {
      PolicyStatus.draft: const Color(0xFF64748B),
      PolicyStatus.pending: const Color(0xFFF59E0B),
      PolicyStatus.approved: const Color(0xFF22C55E),
      PolicyStatus.rejected: const Color(0xFFEF4444),
      PolicyStatus.expired: const Color(0xFF94A3B8),
    };
    final statusColor = statusColors[policy.status] ?? const Color(0xFF64748B);

    return Dismissible(
      key: ValueKey(policy.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text('Delete', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        _confirmDelete(policy);
        return false; // We handle deletion in the dialog
      },
      child: GestureDetector(
        onTap: () => _showPolicyForm(existingPolicy: policy),
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            final delay = (index * 0.1).clamp(0.0, 0.5);
            final animValue = Curves.easeOutCubic.transform(
              ((_animController.value - delay) / (1 - delay)).clamp(0.0, 1.0),
            );
            return Transform.translate(
              offset: Offset(0, 30 * (1 - animValue)),
              child: Opacity(
                opacity: animValue,
                child: child,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top Row: Name + Status ──
                Row(
                  children: [
                    // Sponsor initial avatar
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            statusColor.withOpacity(0.15),
                            statusColor.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          policy.sponsorName.isNotEmpty
                              ? policy.sponsorName[0]
                              : '?',
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            policy.sponsorName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${policy.sponsorNumber} · ${policy.memberCount} members',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        policy.statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Bottom Row: Premium + Date ──
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.payments_outlined,
                          size: 16, color: Color(0xFF3B5BFE)),
                      const SizedBox(width: 6),
                      Text(
                        currencyFormat.format(policy.totalPremium),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Color(0xFF3B5BFE),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.calendar_today_outlined,
                          size: 14, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 6),
                      Text(
                        dateFormat.format(policy.effectiveDate),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Notes (if any) ──
                if (policy.notes != null && policy.notes!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.notes_outlined,
                          size: 14, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          policy.notes!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Empty state when no policies match the filter
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF3B5BFE).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.description_outlined,
              size: 40,
              color: Color(0xFF3B5BFE),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No policies found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the + button to create your first policy',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  // ── Reusable UI helpers ──

  /// Form field label
  Widget _formLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: Color(0xFF0F172A),
      ),
    );
  }

  /// Standard input decoration
  InputDecoration _inputDeco({required String hint, IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
      prefixIcon:
          icon != null ? Icon(icon, size: 20, color: const Color(0xFF94A3B8)) : null,
      filled: true,
      fillColor: const Color(0xFFF5F7FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3B5BFE), width: 2),
      ),
    );
  }
}

/// AnimatedBuilder — like AnimatedBuilder but with a cleaner name.
/// (In real Flutter it's called AnimatedBuilder, we just re-export it here)
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
    this.child,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }

  Animation<double> get animation => listenable as Animation<double>;
}
