import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../dashboard/main_shell.dart';

/// OTP verification screen.
/// Accepts dummy code **9090** to proceed to the dashboard.
/// Features:
///  - 4-digit OTP input boxes with auto-focus
///  - Countdown timer for resend
///  - Purple gradient header consistent with login/signup
///  - Animated transitions and error feedback
class OtpScreen extends StatefulWidget {
  /// The email address the OTP was "sent" to
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  // 4 controllers for 4 OTP digit boxes
  final List<TextEditingController> _otpCtrls =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  bool _loading = false;
  bool _hasError = false;
  int _resendSeconds = 30;

  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.elasticOut),
    );
    _animCtrl.forward();
    _startResendTimer();
  }

  /// Countdown timer for "Resend OTP" button
  void _startResendTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _resendSeconds--);
      return _resendSeconds > 0;
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    for (final c in _otpCtrls) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  /// Combines the 4 digit values into a single OTP string
  String get _otpValue => _otpCtrls.map((c) => c.text).join();

  /// Verify the entered OTP — only "9090" is accepted
  Future<void> _verifyOtp() async {
    final otp = _otpValue;
    if (otp.length < 4) {
      setState(() => _hasError = true);
      return;
    }

    setState(() {
      _loading = true;
      _hasError = false;
    });

    // Simulate network verification
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    if (otp == '9090') {
      // ✅ Success — navigate to dashboard with a nice transition
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainShell(),
          transitionsBuilder: (_, anim, __, child) {
            return FadeTransition(
              opacity: anim,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOut),
                ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
        (_) => false,
      );
    } else {
      // ❌ Wrong OTP — shake animation & error state
      setState(() {
        _loading = false;
        _hasError = true;
      });
      // Clear fields
      for (final c in _otpCtrls) {
        c.clear();
      }
      _focusNodes[0].requestFocus();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invalid OTP. Hint: use 9090'),
          backgroundColor: AppColors.accentCoral,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Stack(
            children: [
              // ── Gradient header ──
              Container(
                height: size.height * 0.40,
                width: double.infinity,
                decoration:
                    const BoxDecoration(gradient: AppColors.splashGradient),
                child: SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_rounded,
                              color: Colors.white),
                        ),
                      ),
                      const Spacer(),
                      // Lock icon with subtle glow
                      ScaleTransition(
                        scale: _scaleAnim,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.1),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.lock_open_rounded,
                              size: 38, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Verify OTP',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Enter the 4-digit code sent to',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.8)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.email,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // ── OTP form card ──
              Positioned(
                top: size.height * 0.36,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundOf(context),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  padding: const EdgeInsets.fromLTRB(28, 40, 28, 20),
                  child: Column(
                    children: [
                      // ── OTP input boxes ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (i) {
                          return Container(
                            width: 64,
                            height: 64,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: TextFormField(
                              controller: _otpCtrls[i],
                              focusNode: _focusNodes[i],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: _hasError
                                    ? AppColors.accentCoral
                                    : AppColors.primaryPurple,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                counterText: '', // hide counter
                                filled: true,
                                fillColor: _hasError
                                    ? AppColors.accentCoral.withOpacity(0.08)
                                    : AppColors.surfaceOf(context),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: _hasError
                                        ? AppColors.accentCoral
                                        : AppColors.primaryPurple
                                            .withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: _hasError
                                        ? AppColors.accentCoral
                                        : AppColors.primaryPurple,
                                    width: 2.5,
                                  ),
                                ),
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (value) {
                                if (_hasError) setState(() => _hasError = false);
                                if (value.isNotEmpty && i < 3) {
                                  // Auto-advance to next box
                                  _focusNodes[i + 1].requestFocus();
                                }
                                if (value.isEmpty && i > 0) {
                                  // Go back on delete
                                  _focusNodes[i - 1].requestFocus();
                                }
                                // Auto-verify when all 4 digits entered
                                if (_otpValue.length == 4) {
                                  _verifyOtp();
                                }
                              },
                            ),
                          );
                        }),
                      ),

                      if (_hasError) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Incorrect code. Hint: use 9090',
                          style: TextStyle(
                            color: AppColors.accentCoral,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Verify button
                      _loading
                          ? Column(
                              children: [
                                const CircularProgressIndicator(
                                  color: AppColors.primaryPurple,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Verifying...',
                                  style: TextStyle(
                                    color: AppColors.textMutedOf(context),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            )
                          : Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryPurple
                                        .withOpacity(0.4),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _verifyOtp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Verify & Continue',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                      const SizedBox(height: 28),

                      // Resend timer / button
                      _resendSeconds > 0
                          ? Text.rich(
                              TextSpan(
                                text: 'Resend code in ',
                                style: TextStyle(
                                  color: AppColors.textMutedOf(context),
                                  fontSize: 14,
                                ),
                                children: [
                                  TextSpan(
                                    text: '00:${_resendSeconds.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      color: AppColors.primaryPurple,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : TextButton(
                              onPressed: () {
                                setState(() => _resendSeconds = 30);
                                _startResendTimer();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        const Text('OTP resent successfully!'),
                                    backgroundColor: AppColors.primaryPurple,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                );
                              },
                              child: Text(
                                'Resend OTP',
                                style: TextStyle(
                                  color: AppColors.primaryPurple,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ),

                      const Spacer(),

                      // Hint text for demo
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurple.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primaryPurple.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                color: AppColors.primaryPurple, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Demo mode: Enter 9090 to proceed',
                                style: TextStyle(
                                  color: AppColors.primaryPurple,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
