// ============================================================================
// policy_providers.dart — Riverpod State Management for Policies
// ============================================================================
// WHAT IS RIVERPOD?
//   Imagine you have a whiteboard in your office. Anyone can look at it
//   to see the latest information. When someone updates the whiteboard,
//   everyone looking at it automatically sees the change.
//
//   Riverpod is that whiteboard for your Flutter app:
//   - "Providers" are the whiteboards (they hold and manage data)
//   - "Consumers" are the people looking at the whiteboard (widgets)
//   - When data changes, all watching widgets automatically rebuild
//
// WHY NOT JUST USE setState()?
//   setState() works for simple cases, but imagine:
//   - Screen A adds a policy → Screen B should show it immediately
//   - You need loading/error states while fetching from the API
//   - Multiple widgets need the same data
//   Riverpod handles all of this automatically!
//
// PROVIDER TYPES WE USE:
//   - Provider: A simple value that never changes (like the API service)
//   - StateNotifierProvider: A reactive state container (our policy list)
//     When the state changes, all watching widgets rebuild automatically
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/policy_model.dart';
import 'api_service.dart';

// ═══════════════════════════════════════════════════════════════════
// STEP 1: Create the API Service Provider
// ═══════════════════════════════════════════════════════════════════
// This is like putting the "waiter" (ApiService) on standby.
// Any widget can ask for the waiter using: ref.read(apiServiceProvider)

/// Global provider for the API service.
/// "Provider" means it creates the value once and reuses it everywhere.
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// ═══════════════════════════════════════════════════════════════════
// STEP 2: Define the State Class
// ═══════════════════════════════════════════════════════════════════
// This represents ALL the possible states our policy list can be in.
// At any moment, the list is either:
//   - Loading (fetching from server)
//   - Loaded (data is ready, here it is!)
//   - Error (something went wrong)

/// Represents the current state of the policy list.
///
/// WHY A SEPARATE CLASS?
///   Instead of having separate bool isLoading, String? error, List<Policy> data
///   scattered everywhere, we bundle them into one clean object.
///   This prevents impossible states like "loading AND error at the same time."
class PolicyState {
  /// Are we currently loading data from the server?
  final bool isLoading;

  /// The list of policies (empty if loading or error)
  final List<PolicyModel> policies;

  /// Error message if something went wrong (null if everything is fine)
  final String? error;

  /// Constructor with default values — starts in a "loading" state
  const PolicyState({
    this.isLoading = false,
    this.policies = const [],
    this.error,
  });

  /// copyWith — creates a new state with some fields changed.
  /// We do this because state objects should be IMMUTABLE (never modified directly).
  PolicyState copyWith({
    bool? isLoading,
    List<PolicyModel>? policies,
    String? error,
  }) {
    return PolicyState(
      isLoading: isLoading ?? this.isLoading,
      policies: policies ?? this.policies,
      error: error,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// STEP 3: Create the State Notifier
// ═══════════════════════════════════════════════════════════════════
// This is the "brain" that manages the policy list.
// It knows how to:
//   - Fetch policies from the API
//   - Add a new policy
//   - Update an existing policy
//   - Delete a policy
//   - Fall back to demo data if the API is down

/// PolicyNotifier manages the policy list state.
///
/// ANALOGY: Think of this as a "filing clerk" who:
///   - Keeps the cabinet organized (state management)
///   - Knows how to add/remove/update files (CRUD)
///   - Communicates with the backend (API calls)
///   - Notifies everyone when something changes (UI updates)
class PolicyNotifier extends StateNotifier<PolicyState> {
  final ApiService _api;

  /// Constructor — starts by fetching policies from the server
  PolicyNotifier(this._api) : super(const PolicyState(isLoading: true)) {
    // Automatically load policies when the notifier is created
    loadPolicies();
  }

  // ── READ: Load all policies ────────────────────────────────────────
  /// Fetches all policies from the C# backend.
  /// If the server is unavailable, falls back to demo data so the app
  /// still works during development without a running backend.
  Future<void> loadPolicies() async {
    // Tell the UI "we're loading" — this shows a spinner
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Try to fetch from the real API
      final policies = await _api.getPolicies();
      // Success! Update state with the fetched data
      state = state.copyWith(isLoading: false, policies: policies);
    } catch (e) {
      // ────────────────────────────────────────────────────────────────
      // API is down — use DEMO DATA so the app still works!
      // ────────────────────────────────────────────────────────────────
      // In a real app, you might show the error to the user instead.
      // But for development/demo, this is super helpful.
      final demoPolicies = [
        PolicyModel(
          id: '1',
          sponsorName: 'Acme Corporation Ltd.',
          sponsorNumber: 'SP10045',
          memberCount: 12,
          totalPremium: 66000,
          effectiveDate: DateTime(2025, 2, 1),
          status: PolicyStatus.approved,
          createdAt: DateTime(2024, 12, 15),
          notes: 'Annual renewal — 12 employees, Class B coverage',
        ),
        PolicyModel(
          id: '2',
          sponsorName: 'Gulf Trading & Logistics',
          sponsorNumber: 'SP20078',
          memberCount: 5,
          totalPremium: 27500,
          effectiveDate: DateTime(2025, 3, 15),
          status: PolicyStatus.pending,
          createdAt: DateTime(2025, 1, 8),
          notes: 'New policy — awaiting underwriting approval',
        ),
        PolicyModel(
          id: '3',
          sponsorName: 'Saudi Fresh Foods',
          sponsorNumber: 'SP30112',
          memberCount: 25,
          totalPremium: 137500,
          effectiveDate: DateTime(2025, 1, 1),
          status: PolicyStatus.approved,
          createdAt: DateTime(2024, 11, 20),
          notes: 'VIP + Class A members. Includes 5 dependents.',
        ),
        PolicyModel(
          id: '4',
          sponsorName: 'Riyadh Tech Solutions',
          sponsorNumber: 'SP40200',
          memberCount: 3,
          totalPremium: 10500,
          effectiveDate: DateTime(2025, 4, 1),
          status: PolicyStatus.draft,
          createdAt: DateTime(2025, 1, 20),
        ),
        PolicyModel(
          id: '5',
          sponsorName: 'Al Madinah Construction',
          sponsorNumber: 'SP50088',
          memberCount: 40,
          totalPremium: 220000,
          effectiveDate: DateTime(2024, 6, 1),
          status: PolicyStatus.expired,
          createdAt: DateTime(2024, 5, 10),
          notes: 'Policy expired — pending renewal discussion',
        ),
      ];

      state = state.copyWith(isLoading: false, policies: demoPolicies);
    }
  }

  // ── CREATE: Add a new policy ───────────────────────────────────────
  /// Creates a new policy and adds it to the list.
  ///
  /// FLOW:
  ///   1. Try to send the new policy to the C# backend
  ///   2. If successful, the server returns the policy with a new ID
  ///   3. Add the new policy to our local list
  ///   4. All widgets watching this provider automatically update!
  Future<bool> addPolicy(PolicyModel policy) async {
    try {
      final created = await _api.createPolicy(policy);
      // Add the new policy to the FRONT of the list (most recent first)
      state = state.copyWith(
        policies: [created, ...state.policies],
      );
      return true;
    } catch (e) {
      // API unavailable — create locally with a generated ID
      final localPolicy = policy.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
      );
      state = state.copyWith(
        policies: [localPolicy, ...state.policies],
      );
      return true;
    }
  }

  // ── UPDATE: Edit an existing policy ────────────────────────────────
  /// Updates a policy and replaces it in the list.
  ///
  /// FLOW:
  ///   1. Try to update on the server
  ///   2. Find the old policy in our list by ID
  ///   3. Replace it with the updated version
  ///   4. All widgets rebuild with the new data!
  Future<bool> updatePolicy(String id, PolicyModel policy) async {
    try {
      final updated = await _api.updatePolicy(id, policy);
      // Replace the old policy with the updated one in our list
      state = state.copyWith(
        policies: state.policies.map((p) => p.id == id ? updated : p).toList(),
      );
      return true;
    } catch (e) {
      // API unavailable — update locally
      state = state.copyWith(
        policies: state.policies.map((p) => p.id == id ? policy : p).toList(),
      );
      return true;
    }
  }

  // ── DELETE: Remove a policy ────────────────────────────────────────
  /// Deletes a policy and removes it from the list.
  ///
  /// FLOW:
  ///   1. Try to delete on the server
  ///   2. Remove from our local list using .where() filter
  ///   3. All widgets update — the deleted policy disappears!
  Future<bool> deletePolicy(String id) async {
    try {
      await _api.deletePolicy(id);
      state = state.copyWith(
        policies: state.policies.where((p) => p.id != id).toList(),
      );
      return true;
    } catch (e) {
      // API unavailable — delete locally
      state = state.copyWith(
        policies: state.policies.where((p) => p.id != id).toList(),
      );
      return true;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
// STEP 4: Create the Provider (the "whiteboard")
// ═══════════════════════════════════════════════════════════════════
// This connects the PolicyNotifier (the brain) to the widget tree.
// Any widget can now:
//   - Watch the state: ref.watch(policyProvider)
//   - Call actions: ref.read(policyProvider.notifier).addPolicy(...)

/// The main provider for policy CRUD operations.
///
/// USAGE IN WIDGETS:
///   // Watch (rebuilds when data changes):
///   final policyState = ref.watch(policyProvider);
///
///   // Read the notifier (to call methods):
///   ref.read(policyProvider.notifier).addPolicy(newPolicy);
///   ref.read(policyProvider.notifier).deletePolicy('abc123');
final policyProvider =
    StateNotifierProvider<PolicyNotifier, PolicyState>((ref) {
  // Get the API service from the other provider
  final api = ref.read(apiServiceProvider);
  // Create and return the notifier
  return PolicyNotifier(api);
});
