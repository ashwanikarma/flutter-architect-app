// ============================================================================
// member.dart — Enhanced Data Model for a Policy Member
// ============================================================================
// This model holds ALL information about one member on the policy.
// Enhanced with:
//   - VIP and LM benefit classes (from the reference app)
//   - Employee ID for linking dependents to their employee
//   - Health declaration answers (5 Yes/No questions)
//   - Expected delivery date and maternity days for pregnant females
//   - Unique ID per member for tracking in lists
//
// WHY WE NEED ALL THIS:
//   In insurance, every detail affects the premium calculation.
//   A VIP class member pays more but gets better coverage.
//   If a member has health conditions (healthDeclaration = 'Yes'),
//   the premium gets a 15% surcharge.
// ============================================================================

import 'package:flutter/foundation.dart'; // For generating unique IDs

/// Enum = a fixed set of choices. A member is either an Employee or Dependent.
/// Using an enum prevents typos — you can't accidentally write "Employe".
enum MemberType { employee, dependent }

/// Enum for marital status options
enum MaritalStatus { single, married, divorced, widowed }

/// Enum for gender options
enum Gender { male, female }

/// The 5 benefit classes available — from most expensive to cheapest.
/// VIP = top tier with international coverage.
/// LM = "Low Market" — minimum CCHI-compliant coverage.
///
/// CLASS OPTIONS LIST:
/// We keep this as a constant list so dropdowns across the app
/// all show the same choices in the same order.
const List<String> classOptions = ['VIP', 'A', 'B', 'C', 'LM'];

/// The 5 standard health declaration questions asked for each member.
/// These are regulatory requirements — the insurer needs to assess risk.
/// If a member answers "Yes" to ANY question, their premium increases by 15%.
const List<String> healthQuestions = [
  'Do you suffer from chronic diseases (e.g., diabetes, hypertension, asthma)?',
  'Have you had any surgery in the past 2 years?',
  'Are you currently on long-term medication?',
  'Have you been hospitalized in the last 12 months?',
  'Do you have any diagnosed medical conditions not listed above?',
];

/// Premium base prices per class (in SAR — Saudi Riyals).
/// These match the reference app's pricing structure.
/// VIP is the most expensive because it includes international coverage.
const Map<String, double> classPremiums = {
  'VIP': 8500,
  'A': 5500,
  'B': 3500,
  'C': 2200,
  'LM': 1200,
};

/// Benefit details for each class — used in the Quotation Summary step
/// to show the user what they're getting for their money.
class ClassBenefit {
  final String coverage;     // Maximum coverage amount
  final String hospitals;    // Which hospitals are covered
  final String maternity;    // Maternity coverage details
  final String dental;       // Dental coverage limit
  final String optical;      // Optical/vision coverage limit
  final List<String> exclusions; // What's NOT covered

  const ClassBenefit({
    required this.coverage,
    required this.hospitals,
    required this.maternity,
    required this.dental,
    required this.optical,
    required this.exclusions,
  });
}

/// Maps each class to its benefit details.
/// This data drives the expandable benefit cards in Step 4 (Quotation).
const Map<String, ClassBenefit> classBenefits = {
  'VIP': ClassBenefit(
    coverage: 'SAR 500,000',
    hospitals: 'All network hospitals including international affiliates',
    maternity: 'Full coverage including complications',
    dental: 'SAR 5,000 annual limit',
    optical: 'SAR 3,000 annual limit',
    exclusions: ['Cosmetic surgery', 'Experimental treatments'],
  ),
  'A': ClassBenefit(
    coverage: 'SAR 250,000',
    hospitals: 'All network hospitals (200+ facilities)',
    maternity: 'SAR 30,000 per event',
    dental: 'SAR 3,500 annual limit',
    optical: 'SAR 2,000 annual limit',
    exclusions: ['Cosmetic surgery', 'Experimental treatments', 'Non-emergency international care'],
  ),
  'B': ClassBenefit(
    coverage: 'SAR 150,000',
    hospitals: 'Network hospitals (150+ facilities)',
    maternity: 'SAR 20,000 per event',
    dental: 'SAR 2,500 annual limit',
    optical: 'SAR 1,500 annual limit',
    exclusions: ['Cosmetic surgery', 'Experimental treatments', 'International care', 'Alternative medicine'],
  ),
  'C': ClassBenefit(
    coverage: 'SAR 100,000',
    hospitals: 'Network hospitals (100+ facilities)',
    maternity: 'SAR 10,000 per event',
    dental: 'SAR 1,500 annual limit',
    optical: 'SAR 800 annual limit',
    exclusions: ['Cosmetic surgery', 'Experimental treatments', 'International care', 'Alternative medicine', 'Psychiatric care beyond 30 days'],
  ),
  'LM': ClassBenefit(
    coverage: 'SAR 50,000 (CCHI minimum)',
    hospitals: 'Government & select private hospitals',
    maternity: 'Emergency only',
    dental: 'Emergency extraction only',
    optical: 'Not covered',
    exclusions: ['Cosmetic surgery', 'Experimental treatments', 'International care', 'Alternative medicine', 'Elective procedures', 'Pre-existing (12-month wait)'],
  ),
};

/// IBAN Bank Mapping — used in KYC step.
/// Saudi IBANs start with "SA" followed by 2 check digits, then a 2-digit bank code.
/// Characters at positions 4-5 (0-indexed) identify the bank.
/// This lets us auto-detect the bank name when the user enters their IBAN.
const Map<String, String> bankMap = {
  '10': 'National Commercial Bank (NCB)',
  '15': 'Al Rajhi Bank',
  '20': 'Riyad Bank',
  '45': 'Saudi British Bank (SABB)',
  '55': 'Banque Saudi Fransi',
  '60': 'Bank AlJazira',
  '65': 'Saudi Investment Bank',
  '80': 'Arab National Bank',
  '05': 'Alinma Bank',
  '30': 'Arab Banking Corporation (ABC)',
  '40': 'Saudi Awwal Bank (SAB)',
  '50': 'Gulf International Bank',
  '76': 'Bank AlBilad',
};

/// Reasons for deleting a member — shown in the delete confirmation dialog.
/// This provides an audit trail and prevents accidental deletions.
const List<String> deletionReasons = [
  'Member left company',
  'Duplicate member',
  'Incorrect entry',
  'Policy downgrade',
  'Other',
];

/// The Member class holds all data about one person on the policy.
class Member {
  // ── Unique Identifier ──
  /// Every member gets a unique ID so we can track them in lists.
  /// We generate this using DateTime.now().millisecondsSinceEpoch + a counter.
  final String id;

  // ── Personal Details ──
  String name;
  MemberType type;
  String identityNumber;
  DateTime? dateOfBirth;
  Gender gender;
  MaritalStatus maritalStatus;
  String benefitClass;
  String sponsorNumber;

  /// For dependents: which employee are they linked to?
  /// This is the ID of the employee member.
  /// Dependents MUST be linked to an employee (validation in Step 2).
  String? employeeId;

  // ── Health Declaration Details ──
  double? heightCm;
  double? weightKg;
  bool isPregnant;

  /// Expected delivery date — only relevant if isPregnant is true
  DateTime? expectedDeliveryDate;

  /// Maternity leave days — optional field for pregnant members
  String? maternityDays;

  /// 'Yes' or 'No' — whether ANY health question was answered "Yes"
  /// If 'Yes', the premium gets a 15% surcharge.
  String? healthDeclaration;

  /// Individual answers to each of the 5 health questions.
  /// true = Yes (has the condition), false = No.
  /// Length should match healthQuestions.length (5).
  List<bool> healthAnswers;

  /// Constructor with all fields.
  /// [id] is auto-generated if not provided.
  Member({
    String? id,
    required this.name,
    required this.type,
    this.identityNumber = '',
    this.dateOfBirth,
    this.gender = Gender.male,
    this.maritalStatus = MaritalStatus.single,
    this.benefitClass = 'A',
    this.sponsorNumber = '',
    this.employeeId,
    this.heightCm,
    this.weightKg,
    this.isPregnant = false,
    this.expectedDeliveryDate,
    this.maternityDays,
    this.healthDeclaration,
    List<bool>? healthAnswers,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        healthAnswers = healthAnswers ?? List.filled(healthQuestions.length, false);

  /// Helper to get a human-readable type string for display
  String get typeLabel => type == MemberType.employee ? 'Employee' : 'Dependent';

  /// Helper to get a human-readable gender string
  String get genderLabel => gender == Gender.male ? 'Male' : 'Female';

  /// Calculate BMI from height and weight.
  /// BMI = weight(kg) / (height(m))²
  /// Returns null if height or weight is not set.
  double? get bmi {
    if (heightCm != null && weightKg != null && heightCm! > 0 && weightKg! > 0) {
      final heightM = heightCm! / 100;
      return weightKg! / (heightM * heightM);
    }
    return null;
  }

  /// Get the BMI category label for display
  String get bmiCategory {
    final b = bmi;
    if (b == null) return '';
    if (b < 18.5) return 'Underweight';
    if (b < 25) return 'Normal';
    if (b < 30) return 'Overweight';
    return 'Obese';
  }

  /// Calculate this member's premium based on class, type, and health declaration.
  double get premium {
    double base = classPremiums[benefitClass] ?? 3500;
    // Dependents get a 25% discount
    if (type == MemberType.dependent) base *= 0.75;
    // Health declaration surcharge: +15% if any health condition declared
    if (healthDeclaration == 'Yes') base *= 1.15;
    return base.roundToDouble();
  }
}
