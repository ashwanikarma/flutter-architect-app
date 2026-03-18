// ============================================================================
// member.dart — Data Model for a Policy Member
// ============================================================================
// A "model" is a Dart class that represents a piece of data in your app.
// Think of it like a row in a database table or a JSON object from an API.
//
// This model holds all the information about one member on the policy:
//   - Their personal details (name, ID, gender, etc.)
//   - Their health info (height, weight, pregnancy status)
//   - Their type (Employee or Dependent) and class (A, B, C, etc.)
// ============================================================================

/// Enum = a fixed set of choices. A member is either an Employee or Dependent.
/// Using an enum prevents typos — you can't accidentally write "Employe".
enum MemberType { employee, dependent }

/// Enum for marital status options
enum MaritalStatus { single, married, divorced, widowed }

/// Enum for gender options
enum Gender { male, female }

/// The Member class holds all data about one person on the policy.
/// We use a "class" so we can group related data together and pass it around.
class Member {
  // ── Personal Details ──

  /// Full name of the member (e.g., "John Smith")
  String name;

  /// Whether this person is the main employee or a dependent (spouse/child)
  MemberType type;

  /// South African ID number (13 digits) or passport number
  String identityNumber;

  /// Date the member was born — used for age-based pricing
  DateTime? dateOfBirth;

  /// Male or Female — affects health declaration questions
  Gender gender;

  /// Marital status — may affect dependent eligibility
  MaritalStatus maritalStatus;

  /// Benefit class (A, B, C, etc.) — determines coverage level & pricing
  String benefitClass;

  /// The sponsor number this member belongs to
  String sponsorNumber;

  // ── Health Declaration Details ──

  /// Height in centimeters — used for BMI calculation
  double? heightCm;

  /// Weight in kilograms — used for BMI calculation
  double? weightKg;

  /// Whether a female member is currently pregnant
  bool isPregnant;

  /// Constructor — the "recipe" for creating a new Member object.
  /// Required fields use "required:" keyword. Optional fields have defaults.
  Member({
    required this.name,
    required this.type,
    this.identityNumber = '',
    this.dateOfBirth,
    this.gender = Gender.male,
    this.maritalStatus = MaritalStatus.single,
    this.benefitClass = 'A',
    this.sponsorNumber = '',
    this.heightCm,
    this.weightKg,
    this.isPregnant = false,
  });

  /// Helper to get a human-readable type string for display
  String get typeLabel => type == MemberType.employee ? 'Employee' : 'Dependent';

  /// Helper to get a human-readable gender string
  String get genderLabel => gender == Gender.male ? 'Male' : 'Female';
}
