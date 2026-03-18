// ============================================================================
// step1_sponsor.dart — Step 1: Sponsor Details
// ============================================================================
// This is the first step in the quotation flow. The user enters:
//   1. A sponsor number (like a company/employer ID)
//   2. A policy effective date (when coverage starts)
//
// FLUTTER CONCEPTS INTRODUCED:
//   - TextEditingController: Links a text field to a variable so we can
//     read/write its value programmatically.
//   - GlobalKey<FormState>: Lets us validate all form fields at once.
//   - Form & TextFormField: Flutter's built-in form system with validation.
//   - showDatePicker(): Opens the native date picker dialog.
//   - initState() & dispose(): Lifecycle methods — called when the widget
//     is created and destroyed. Used to set up and clean up resources.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates (e.g., "19 Mar 2026")

class Step1Sponsor extends StatefulWidget {
  /// The previously entered sponsor number (for when user navigates back)
  final String initialSponsorNumber;

  /// The previously selected date (preserved when navigating back)
  final DateTime? initialDate;

  /// Callback function — called when user taps "Next" with valid data.
  /// The parent screen receives the sponsor number and date.
  final void Function(String sponsorNumber, DateTime? date) onNext;

  const Step1Sponsor({
    super.key,
    required this.initialSponsorNumber,
    required this.initialDate,
    required this.onNext,
  });

  @override
  State<Step1Sponsor> createState() => _Step1SponsorState();
}

class _Step1SponsorState extends State<Step1Sponsor> {
  // ── Form Key ──
  // This key is attached to the Form widget. When we call
  // _formKey.currentState!.validate(), it runs ALL the validator
  // functions on every TextFormField inside that Form.
  final _formKey = GlobalKey<FormState>();

  // ── Controllers ──
  // A TextEditingController is the "bridge" between a TextField and your code.
  // You can read the current text with controller.text, or set it with
  // controller.text = "new value".
  late TextEditingController _sponsorController;

  /// The selected policy effective date (null = not yet selected)
  DateTime? _selectedDate;

  // ── Lifecycle Methods ──

  /// initState() is called ONCE when this widget is first created.
  /// Use it to initialize controllers and set default values.
  @override
  void initState() {
    super.initState();
    // Pre-fill with any previously entered values (e.g., if user went back)
    _sponsorController = TextEditingController(text: widget.initialSponsorNumber);
    _selectedDate = widget.initialDate;
  }

  /// dispose() is called when this widget is removed from the screen.
  /// ALWAYS dispose controllers to free memory (prevents memory leaks).
  @override
  void dispose() {
    _sponsorController.dispose();
    super.dispose();
  }

  /// Opens the native Material date picker dialog.
  /// The user can select a date within the allowed range.
  Future<void> _pickDate() async {
    final now = DateTime.now();

    // showDatePicker returns a Future<DateTime?> — the "?" means it can be null
    // (null = user cancelled the picker without selecting a date)
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now, // Default to today if nothing selected
      firstDate: now, // Can't select a date in the past
      lastDate: now.add(const Duration(days: 21)), // Max 21 days in the future
      // Custom styling for the date picker dialog
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3B5BFE), // Header & selected date color
            ),
          ),
          child: child!,
        );
      },
    );

    // If user selected a date (didn't cancel), update state
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the date range text for the hint
    final now = DateTime.now();
    final maxDate = now.add(const Duration(days: 21));
    final dateFormat = DateFormat('dd MMM yyyy'); // e.g., "19 Mar 2026"

    return SingleChildScrollView(
      // SingleChildScrollView makes the content scrollable if it overflows.
      // This prevents the "pixel overflow" error on small screens.
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // ── Card Container ──
          // Wraps the form in a white card with rounded corners, matching the design.
          Container(
            width: double.infinity, // Fill the full width
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              // Subtle shadow for depth
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Form(
              key: _formKey, // Attach the form key for validation
              child: Column(
                // crossAxisAlignment.start = left-align children
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Title ──
                  const Text(
                    'Sponsor Details',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Subtitle / Description ──
                  const Text(
                    'Enter the sponsor number and select the policy effective date.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B), // Muted gray
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Sponsor Number Field ──
                  const Text(
                    'Sponsor Number *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // TextFormField = a text input with built-in validation support.
                  // The "validator" function runs when we call _formKey.currentState!.validate().
                  TextFormField(
                    controller: _sponsorController, // Link to our controller
                    decoration: const InputDecoration(
                      hintText: 'e.g. SP12345', // Placeholder text
                      hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                    // Validator returns null if valid, or an error message string if invalid.
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a sponsor number';
                      }
                      return null; // null = valid
                    },
                  ),
                  const SizedBox(height: 24),

                  // ── Policy Effective Date Field ──
                  const Text(
                    'Policy Effective Date *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // GestureDetector wraps a widget and detects taps on it.
                  // We use it to make the "date field" tappable (opens date picker).
                  GestureDetector(
                    onTap: _pickDate,
                    // AbsorbPointer prevents the text field from receiving taps
                    // (so the keyboard doesn't open — we want the date picker instead).
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: _selectedDate != null
                              ? dateFormat.format(_selectedDate!)
                              : 'Select date',
                          hintStyle: TextStyle(
                            color: _selectedDate != null
                                ? const Color(0xFF0F172A) // Black if date selected
                                : const Color(0xFF94A3B8), // Gray if placeholder
                          ),
                          // Calendar icon on the left side of the field
                          prefixIcon: const Icon(
                            Icons.calendar_today_outlined,
                            color: Color(0xFF94A3B8),
                            size: 20,
                          ),
                        ),
                        validator: (_) {
                          if (_selectedDate == null) {
                            return 'Please select a policy effective date';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Date Range Hint ──
                  // Shows the valid date range in blue text
                  Text(
                    'Between ${dateFormat.format(now)} and ${dateFormat.format(maxDate)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF3B5BFE),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // ── Next Button ──
          // SizedBox with width: double.infinity makes the button full-width.
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Validate all fields in the form
                if (_formKey.currentState!.validate()) {
                  // If valid, pass data to parent and move to next step
                  widget.onNext(_sponsorController.text.trim(), _selectedDate);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B5BFE),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }
}
