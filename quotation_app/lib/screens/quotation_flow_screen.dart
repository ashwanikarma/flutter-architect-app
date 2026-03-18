// ============================================================================
// quotation_flow_screen.dart — Main Screen that Controls the Quotation Flow
// ============================================================================
// This is the "orchestrator" — it manages which step the user is on and
// holds all the shared data (sponsor info, members list, etc.).
//
// FLUTTER CONCEPTS:
//   - StatefulWidget: A widget that CAN change over time (unlike StatelessWidget).
//     We need state because the current step and form data change as the user
//     navigates through the flow.
//   - setState(): Tells Flutter "something changed, please redraw the screen."
//     Every time we call setState(), Flutter re-runs the build() method.
//   - Scaffold: The basic screen structure with an AppBar (top bar) and body.
// ============================================================================

import 'package:flutter/material.dart';
import '../models/member.dart';
import '../widgets/step_indicator.dart';
import 'steps/step1_sponsor.dart';
import 'steps/step2_members.dart';
import 'steps/step3_health_declaration.dart';
import 'steps/step4_quotation.dart';
import 'steps/step5_kyc.dart';
import 'steps/step6_payment.dart';

class QuotationFlowScreen extends StatefulWidget {
  const QuotationFlowScreen({super.key});

  @override
  State<QuotationFlowScreen> createState() => _QuotationFlowScreenState();
}

class _QuotationFlowScreenState extends State<QuotationFlowScreen> {
  // ── State Variables ──
  // These hold the data collected across all steps.

  /// Which step the user is currently on (0-indexed, so 0 = Step 1: Sponsor)
  int _currentStep = 0;

  /// The 6 step labels shown in the stepper indicator
  final List<String> _stepLabels = [
    'Sponsor',
    'Members',
    'Health Declaration',
    'Quotation',
    'KYC',
    'Payment',
  ];

  // ── Data collected from each step ──

  /// Sponsor number entered in Step 1 (e.g., "SP12345")
  String _sponsorNumber = '';

  /// Policy effective date selected in Step 1
  DateTime? _policyDate;

  /// List of members added in Step 2
  /// We use a List<Member> — a dynamic array that can grow/shrink.
  final List<Member> _members = [];

  // ── Navigation Methods ──
  // These methods move the user forward or backward through the steps.

  /// Move to the next step. Called when user taps "Next" or "Continue".
  void _goNext() {
    // Only advance if we haven't reached the last step
    if (_currentStep < _stepLabels.length - 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  /// Move to the previous step. Called when user taps "Back".
  void _goBack() {
    // Only go back if we're not on the first step
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      // If on first step, go back to previous screen (pop the navigation stack)
      Navigator.of(context).pop();
    }
  }

  /// Called when sponsor details are saved in Step 1.
  /// This is a "callback" — Step 1 calls this function to send data back up.
  void _onSponsorSaved(String sponsorNumber, DateTime? date) {
    setState(() {
      _sponsorNumber = sponsorNumber;
      _policyDate = date;
    });
    _goNext();
  }

  /// Called when the members step is completed.
  void _onMembersContinue() {
    _goNext();
  }

  /// Called when health declarations are completed for all members.
  void _onHealthDeclarationComplete() {
    _goNext();
  }

  /// Called when the quotation is accepted.
  void _onQuotationAccepted() {
    _goNext();
  }

  /// Called when KYC documents are submitted.
  void _onKycSubmitted() {
    _goNext();
  }

  /// Called when payment is completed — shows a success dialog.
  void _onPaymentComplete() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap the button to dismiss
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 32),
            SizedBox(width: 12),
            Text('Success!'),
          ],
        ),
        content: const Text(
          'Your policy quotation has been submitted successfully. '
          'You will receive a confirmation email shortly.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Close dialog
              // Reset the flow back to step 1
              setState(() {
                _currentStep = 0;
                _sponsorNumber = '';
                _policyDate = null;
                _members.clear();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B5BFE),
              foregroundColor: Colors.white,
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  /// Returns the widget for the current step.
  /// This is like a "switch" statement — based on _currentStep, show different content.
  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        // Step 1: Sponsor Details
        return Step1Sponsor(
          initialSponsorNumber: _sponsorNumber,
          initialDate: _policyDate,
          onNext: _onSponsorSaved,
        );
      case 1:
        // Step 2: Members
        return Step2Members(
          members: _members,
          onContinue: _onMembersContinue,
          onBack: _goBack,
        );
      case 2:
        // Step 3: Health Declaration
        return Step3HealthDeclaration(
          members: _members,
          onComplete: _onHealthDeclarationComplete,
          onBack: _goBack,
        );
      case 3:
        // Step 4: Quotation Summary
        return Step4Quotation(
          sponsorNumber: _sponsorNumber,
          policyDate: _policyDate,
          members: _members,
          onAccept: _onQuotationAccepted,
          onBack: _goBack,
        );
      case 4:
        // Step 5: KYC
        return Step5Kyc(
          onSubmit: _onKycSubmitted,
          onBack: _goBack,
        );
      case 5:
        // Step 6: Payment
        return Step6Payment(
          members: _members,
          onComplete: _onPaymentComplete,
          onBack: _goBack,
        );
      default:
        return const SizedBox(); // Fallback (should never happen)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── App Bar (top bar) ──
      // Shows the title and a back button, plus the user's avatar
      appBar: AppBar(
        // The back arrow on the left
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
        // Title in the center
        title: const Text(
          'New Policy Quotation',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: false,
        // User avatar on the right side
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF3B5BFE),
              radius: 18,
              child: Text(
                'AS', // Initials of the user
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
        // Remove the shadow under the app bar for a cleaner look
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),

      // ── Body ──
      // Column = vertical layout. We stack the stepper on top and the step content below.
      body: Column(
        children: [
          // ── Step Indicator (the numbered circles at the top) ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: StepIndicator(
              currentStep: _currentStep,
              labels: _stepLabels,
            ),
          ),

          // ── Step Content ──
          // Expanded makes this take ALL remaining vertical space.
          // This is important so the step content fills the screen.
          Expanded(
            child: _buildCurrentStep(),
          ),
        ],
      ),

      // Light gray background behind everything
      backgroundColor: const Color(0xFFF7F8FC),
    );
  }
}
