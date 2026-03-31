// ============================================================================
// policy_model.dart — Data Model for a Saved Policy (CRUD Entity)
// ============================================================================
// WHAT IS A MODEL?
//   A model is like a "blueprint" or "template" for data.
//   Just like a form has fields (Name, Date, Amount), a model defines
//   what fields a Policy has and what type of data each field holds.
//
// WHY DO WE NEED IT?
//   When your C# backend sends JSON data like:
//     { "id": 1, "sponsorName": "Acme Corp", "totalPremium": 5500.0 }
//   Flutter doesn't understand JSON natively. The model converts
//   that JSON into a Dart object we can easily use in our app.
//
// CRUD = Create, Read, Update, Delete
//   These are the 4 basic operations you can do with any data:
//   - CREATE: Add a new policy (like filling out a new form)
//   - READ:   View existing policies (like opening a filing cabinet)
//   - UPDATE: Edit a policy (like correcting a mistake on a form)
//   - DELETE: Remove a policy (like shredding a document)
// ============================================================================

/// Enum for policy status — think of it as a dropdown with fixed options.
/// A policy can only be in one of these states at any time.
enum PolicyStatus {
  draft,      // Still being worked on, not submitted yet
  pending,    // Submitted, waiting for approval
  approved,   // Approved by underwriting team
  rejected,   // Rejected — maybe missing info or too risky
  expired,    // Policy period has ended
}

/// The Policy model — represents one insurance policy in our system.
///
/// ANALOGY: Think of this like a row in an Excel spreadsheet.
/// Each policy is one row, and each field (id, sponsorName, etc.) is a column.
class PolicyModel {
  // ── Fields (the "columns" of our data) ──

  /// Unique identifier — like a serial number for each policy.
  /// It's a String because some databases use GUIDs (long alphanumeric IDs).
  /// Can be null when CREATING a new policy (the backend assigns the ID).
  final String? id;

  /// The sponsor (company) name — who is buying this insurance?
  final String sponsorName;

  /// Sponsor number — a unique code for the company (like a customer ID)
  final String sponsorNumber;

  /// How many people are covered under this policy
  final int memberCount;

  /// The total annual premium in SAR (Saudi Riyals)
  /// This is the yearly cost of the insurance for all members combined.
  final double totalPremium;

  /// When does the policy coverage start?
  final DateTime effectiveDate;

  /// Current status of this policy (draft, pending, approved, etc.)
  final PolicyStatus status;

  /// When was this policy record created? (auto-set by the system)
  final DateTime? createdAt;

  /// Optional notes — any additional comments about the policy
  final String? notes;

  /// Constructor — the "recipe" for creating a PolicyModel object.
  /// "required" means you MUST provide this value. No "required" means it's optional.
  PolicyModel({
    this.id,
    required this.sponsorName,
    required this.sponsorNumber,
    required this.memberCount,
    required this.totalPremium,
    required this.effectiveDate,
    this.status = PolicyStatus.draft,
    this.createdAt,
    this.notes,
  });

  // ═══════════════════════════════════════════════════════════════════
  // JSON CONVERSION — Translating between Dart objects and JSON
  // ═══════════════════════════════════════════════════════════════════
  //
  // WHY?
  //   Your C# backend speaks "JSON" (JavaScript Object Notation).
  //   Flutter speaks "Dart objects".
  //   These methods are the "translator" between the two languages.
  //
  // FLOW:
  //   C# Backend → JSON → fromJson() → Dart PolicyModel object
  //   Dart PolicyModel object → toJson() → JSON → C# Backend

  /// fromJson: Converts a JSON map (from the API) into a PolicyModel object.
  ///
  /// EXAMPLE INPUT (what the C# API sends):
  ///   {
  ///     "id": "abc123",
  ///     "sponsorName": "Acme Corp",
  ///     "sponsorNumber": "SP12345",
  ///     "memberCount": 5,
  ///     "totalPremium": 27500.0,
  ///     "effectiveDate": "2025-01-15T00:00:00",
  ///     "status": "approved",
  ///     "createdAt": "2024-12-01T10:30:00",
  ///     "notes": "Annual renewal"
  ///   }
  ///
  /// EXAMPLE OUTPUT: a Dart PolicyModel object with all those values filled in.
  factory PolicyModel.fromJson(Map<String, dynamic> json) {
    return PolicyModel(
      // The ?. operator means "if json['id'] is not null, call .toString()"
      // This prevents crashes if the API sends null for the ID
      id: json['id']?.toString(),

      // "as String" tells Dart "trust me, this value IS a String"
      // If it's not, the app will crash — so make sure your API sends correct types!
      sponsorName: json['sponsorName'] as String,
      sponsorNumber: json['sponsorNumber'] as String,

      // For numbers, we use "as int" and "as double" to ensure correct types
      memberCount: json['memberCount'] as int,

      // toDouble() handles cases where the API sends "5500" (int) instead of "5500.0" (double)
      totalPremium: (json['totalPremium'] as num).toDouble(),

      // DateTime.parse converts a date string like "2025-01-15T00:00:00" into a DateTime object
      effectiveDate: DateTime.parse(json['effectiveDate'] as String),

      // Convert the status string to our PolicyStatus enum
      // _statusFromString is a helper function defined below
      status: _statusFromString(json['status'] as String? ?? 'draft'),

      // createdAt might be null (for new policies), so we use a conditional
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,

      notes: json['notes'] as String?,
    );
  }

  /// toJson: Converts this PolicyModel object into a JSON map (to send to the API).
  ///
  /// EXAMPLE OUTPUT (what gets sent to the C# API):
  ///   {
  ///     "sponsorName": "Acme Corp",
  ///     "sponsorNumber": "SP12345",
  ///     "memberCount": 5,
  ///     ...
  ///   }
  Map<String, dynamic> toJson() {
    return {
      // Only include 'id' if it exists (for UPDATE operations)
      // For CREATE, the backend generates the ID, so we don't send it
      if (id != null) 'id': id,
      'sponsorName': sponsorName,
      'sponsorNumber': sponsorNumber,
      'memberCount': memberCount,
      'totalPremium': totalPremium,
      'effectiveDate': effectiveDate.toIso8601String(),
      'status': status.name, // .name converts enum to string: PolicyStatus.approved → "approved"
      if (notes != null) 'notes': notes,
    };
  }

  /// copyWith: Creates a COPY of this policy with some fields changed.
  ///
  /// WHY? In Dart, objects are "immutable" by convention — instead of
  /// changing a field directly, we create a new object with the change.
  /// This prevents bugs where two parts of the app accidentally share
  /// and modify the same object.
  ///
  /// EXAMPLE:
  ///   final updated = oldPolicy.copyWith(status: PolicyStatus.approved);
  ///   // oldPolicy still has its original status
  ///   // updated has the new status
  PolicyModel copyWith({
    String? id,
    String? sponsorName,
    String? sponsorNumber,
    int? memberCount,
    double? totalPremium,
    DateTime? effectiveDate,
    PolicyStatus? status,
    DateTime? createdAt,
    String? notes,
  }) {
    return PolicyModel(
      id: id ?? this.id,
      sponsorName: sponsorName ?? this.sponsorName,
      sponsorNumber: sponsorNumber ?? this.sponsorNumber,
      memberCount: memberCount ?? this.memberCount,
      totalPremium: totalPremium ?? this.totalPremium,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
    );
  }

  // ── Helper: Status Labels & Colors ──

  /// Returns a user-friendly label for the status
  String get statusLabel {
    switch (status) {
      case PolicyStatus.draft: return 'Draft';
      case PolicyStatus.pending: return 'Pending';
      case PolicyStatus.approved: return 'Approved';
      case PolicyStatus.rejected: return 'Rejected';
      case PolicyStatus.expired: return 'Expired';
    }
  }

  /// Returns the icon for each status (used in the UI)
  String get statusEmoji {
    switch (status) {
      case PolicyStatus.draft: return '📝';
      case PolicyStatus.pending: return '⏳';
      case PolicyStatus.approved: return '✅';
      case PolicyStatus.rejected: return '❌';
      case PolicyStatus.expired: return '📅';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS (private — only used inside this file)
// ═══════════════════════════════════════════════════════════════════

/// Converts a string like "approved" to PolicyStatus.approved.
/// If the string doesn't match any status, defaults to "draft".
PolicyStatus _statusFromString(String value) {
  switch (value.toLowerCase()) {
    case 'draft': return PolicyStatus.draft;
    case 'pending': return PolicyStatus.pending;
    case 'approved': return PolicyStatus.approved;
    case 'rejected': return PolicyStatus.rejected;
    case 'expired': return PolicyStatus.expired;
    default: return PolicyStatus.draft;
  }
}
