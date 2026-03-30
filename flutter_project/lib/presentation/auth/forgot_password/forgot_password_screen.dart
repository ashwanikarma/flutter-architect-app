import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';

/// ═══════════════════════════════════════════════════════════════════════
/// FORGOT PASSWORD SCREEN
/// ═══════════════════════════════════════════════════════════════════════
///
/// This screen lets the user enter their email to receive a password
/// reset link. It simulates sending the email and shows a success state.
///
/// Flow: Login → Forgot Password → (enter email) → success message → back
///
/// Key Flutter concepts used:
///   - AnimationController: drives entrance animation
///   - AnimatedSwitcher: toggles between form and success state
///   - Form + TextFormField: validates email input
///   - BoxDecoration with gradient: purple header matching app theme
/// ═══════════════════════════════════════════════════════════════════════
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  // ── State ──
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _sent = false; // toggles to success view after "sending"

  // ── Animation ──
  late AnimationController _animCtrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    // Entrance animation: slide up + fade in over 800ms
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
    );
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  /// Simulate sending a password reset email
  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    // Simulate network delay (replace with real API call later)
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    setState(() {
      _loading = false;
      _sent = true; // switch to success view
    });
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
              // ── Purple gradient header (top 40%) ──
              Container(
                height: size.height * 0.40,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: AppColors.splashGradient,
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      // Back button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Lock icon with glow
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.1),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          size: 38,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Reset Password',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'We\'ll send you a reset link',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // ── Form / Success card ──
              Positioned(
                top: size.height * 0.36,
                left: 0,
                right: 0,
                bottom: 0,
                child: SlideTransition(
                  position: _slideAnim,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.backgroundOf(context),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(28, 36, 28, 20),
                      // AnimatedSwitcher smoothly toggles between form & success
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child: _sent ? _buildSuccess() : _buildForm(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ── Email form view ──
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('form'), // needed by AnimatedSwitcher
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Forgot your password?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textMainOf(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the email address associated with your account '
            'and we\'ll send you a link to reset your password.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMutedOf(context),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          // Email input field
          TextFormField(
            controller: _emailCtrl,
            validator: Validators.email,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Email address',
              prefixIcon: Icon(
                Icons.email_outlined,
                color: AppColors.primaryPurple.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Send button with gradient
          _loading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryPurple,
                  ),
                )
              : Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPurple.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _sendResetLink,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Send Reset Link',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
          const SizedBox(height: 24),

          // Back to login link
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text.rich(
                TextSpan(
                  text: 'Remember your password? ',
                  style: TextStyle(
                    color: AppColors.textMutedOf(context),
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: 'Sign In',
                      style: TextStyle(
                        color: AppColors.primaryPurple,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ── Success view (after email sent) ──
  Widget _buildSuccess() {
    return Column(
      key: const ValueKey('success'), // needed by AnimatedSwitcher
      children: [
        const SizedBox(height: 20),
        // Animated checkmark circle
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (_, value, child) {
            return Transform.scale(scale: value, child: child);
          },
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withOpacity(0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.mark_email_read_rounded,
              size: 44,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Check Your Email',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textMainOf(context),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'We\'ve sent a password reset link to',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textMutedOf(context),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _emailCtrl.text.trim(),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryPurple,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please check your inbox and spam folder.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textMutedOf(context),
          ),
        ),
        const SizedBox(height: 36),

        // Back to login button
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Back to Sign In',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Resend option
        TextButton(
          onPressed: () {
            setState(() => _sent = false);
          },
          child: Text(
            'Didn\'t receive it? Try again',
            style: TextStyle(
              color: AppColors.primaryPurple,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
