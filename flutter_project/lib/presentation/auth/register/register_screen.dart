import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';

/// Beautiful sign-up screen with purple gradient header
/// and smooth animations matching the login screen design.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _agreeTerms = false;
  double _passwordStrength = 0; // 0.0 to 1.0

  late AnimationController _animCtrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Passwords do not match'),
          backgroundColor: AppColors.accentCoral,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please agree to Terms & Conditions'),
          backgroundColor: AppColors.accentCoral,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('🎉 Account created! Please login.'),
        backgroundColor: AppColors.accentGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.pop(context);
  }

  /// Calculate password strength from 0.0 to 1.0
  /// Checks: length, uppercase, lowercase, digit, special char
  double _calcStrength(String password) {
    if (password.isEmpty) return 0;
    double score = 0;
    if (password.length >= 6) score += 0.2;
    if (password.length >= 10) score += 0.1;
    if (RegExp(r'[a-z]').hasMatch(password)) score += 0.15;
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 0.2;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 0.15;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) score += 0.2;
    return score.clamp(0.0, 1.0);
  }

  /// Color based on current strength
  Color get _strengthColor {
    if (_passwordStrength < 0.35) return AppColors.accentCoral;
    if (_passwordStrength < 0.75) return AppColors.accentGold;
    return AppColors.accentGreen;
  }

  /// Label based on current strength
  String get _strengthLabel {
    if (_passwordStrength < 0.35) return 'Weak — add uppercase, numbers & symbols';
    if (_passwordStrength < 0.75) return 'Medium — almost there!';
    return 'Strong password ✓';
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
              // ── Purple gradient header ──
              Container(
                height: size.height * 0.35,
                width: double.infinity,
                decoration: const BoxDecoration(gradient: AppColors.splashGradient),
                child: SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      // Back button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_rounded,
                              color: Colors.white),
                        ),
                      ),
                      const Spacer(),
                      // Icon + title
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3), width: 1.5),
                        ),
                        child: const Icon(Icons.person_add_rounded,
                            size: 34, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Start your fitness journey today',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),

              // ── Form card ──
              Positioned(
                top: size.height * 0.30,
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
                            top: Radius.circular(32)),
                      ),
                      padding: const EdgeInsets.fromLTRB(28, 32, 28, 20),
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Full name
                              TextFormField(
                                controller: _nameCtrl,
                                validator: Validators.required,
                                textCapitalization: TextCapitalization.words,
                                decoration: InputDecoration(
                                  hintText: 'Full Name',
                                  prefixIcon: Icon(Icons.person_outline,
                                      color: AppColors.primaryPurple
                                          .withOpacity(0.7)),
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Email
                              TextFormField(
                                controller: _emailCtrl,
                                validator: Validators.email,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  hintText: 'Email address',
                                  prefixIcon: Icon(Icons.email_outlined,
                                      color: AppColors.primaryPurple
                                          .withOpacity(0.7)),
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Password with strength indicator
                              TextFormField(
                                controller: _passCtrl,
                                validator: Validators.password,
                                obscureText: _obscurePass,
                                onChanged: (value) {
                                  setState(() => _passwordStrength = _calcStrength(value));
                                },
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  prefixIcon: Icon(Icons.lock_outline,
                                      color: AppColors.primaryPurple
                                          .withOpacity(0.7)),
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(
                                        () => _obscurePass = !_obscurePass),
                                    icon: Icon(
                                      _obscurePass
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: AppColors.textMutedOf(context),
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                              // ── Password strength indicator ──
                              if (_passCtrl.text.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                // Animated progress bar
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    height: 6,
                                    child: LinearProgressIndicator(
                                      value: _passwordStrength,
                                      backgroundColor: AppColors.primaryPurple.withOpacity(0.1),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        _strengthColor,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      _passwordStrength >= 0.75
                                          ? Icons.check_circle_rounded
                                          : Icons.info_outline_rounded,
                                      size: 14,
                                      color: _strengthColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _strengthLabel,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _strengthColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 14),

                              // Confirm password
                              TextFormField(
                                controller: _confirmCtrl,
                                validator: Validators.password,
                                obscureText: _obscureConfirm,
                                decoration: InputDecoration(
                                  hintText: 'Confirm Password',
                                  prefixIcon: Icon(Icons.lock_outline,
                                      color: AppColors.primaryPurple
                                          .withOpacity(0.7)),
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(() =>
                                        _obscureConfirm = !_obscureConfirm),
                                    icon: Icon(
                                      _obscureConfirm
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: AppColors.textMutedOf(context),
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Terms checkbox
                              Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: _agreeTerms,
                                      onChanged: (v) =>
                                          setState(() => _agreeTerms = v!),
                                      activeColor: AppColors.primaryPurple,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text.rich(
                                      TextSpan(
                                        text: 'I agree to the ',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color:
                                              AppColors.textMutedOf(context),
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'Terms & Conditions',
                                            style: TextStyle(
                                              color: AppColors.primaryPurple,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Sign Up button with gradient
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
                                        borderRadius:
                                            BorderRadius.circular(16),
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
                                        onPressed: _register,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                        ),
                                        child: const Text(
                                          'Create Account',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                              const SizedBox(height: 20),

                              // Login link
                              Center(
                                child: TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text.rich(
                                    TextSpan(
                                      text: 'Already have an account? ',
                                      style: TextStyle(
                                        color:
                                            AppColors.textMutedOf(context),
                                        fontSize: 14,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Log In',
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
                        ),
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
}
