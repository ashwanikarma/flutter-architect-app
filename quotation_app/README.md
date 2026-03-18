# Policy Quotation Flow — Flutter App

A complete 6-step insurance policy quotation flow built with Flutter.

## Steps

| Step | Screen | Description |
|------|--------|-------------|
| 1 | Sponsor | Enter sponsor number & policy effective date |
| 2 | Members | Add/edit/delete members (employees & dependents) |
| 3 | Health Declaration | Height, weight, pregnancy status per member |
| 4 | Quotation | Premium breakdown & total pricing |
| 5 | KYC | Upload identity & address documents |
| 6 | Payment | Bank details, debit order or EFT |

## Getting Started

```bash
cd quotation_app
flutter pub get
flutter run
```

## Project Structure

```
lib/
├── main.dart                          # App entry point & theme
├── models/
│   └── member.dart                    # Member data model
├── screens/
│   ├── quotation_flow_screen.dart     # Main flow controller with stepper
│   └── steps/
│       ├── step1_sponsor.dart         # Sponsor details form
│       ├── step2_members.dart         # Members CRUD
│       ├── step3_health_declaration.dart # Health details per member
│       ├── step4_quotation.dart       # Pricing summary
│       ├── step5_kyc.dart             # Document upload
│       └── step6_payment.dart         # Payment & submission
└── widgets/
    └── step_indicator.dart            # Custom stepper UI
```

## Features
- Custom step indicator with completion checkmarks
- Form validation on each step
- Add/edit/delete members with bottom sheet forms
- Health declaration with conditional pregnancy question
- Premium calculation with class-based pricing
- KYC document upload simulation
- Payment with debit order or EFT options
- Success dialog on completion
