import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:agent_prompt/core/constants/app_colors.dart';
import 'package:agent_prompt/core/router/route_names.dart';
import 'package:agent_prompt/core/utils/validators.dart';
import 'package:agent_prompt/core/utils/snackbar_utils.dart';
import 'package:agent_prompt/core/widgets/primary_button.dart';
import 'package:agent_prompt/core/widgets/custom_text_field.dart';
import 'package:agent_prompt/core/widgets/gradient_background.dart';
import 'package:agent_prompt/providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).signUpWithEmail(
            name: _nameCtrl.text,
            email: _emailCtrl.text,
            password: _passwordCtrl.text,
          );
      if (mounted) context.go(RouteNames.home);
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, _parseError(e.toString()));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _googleSignUp() async {
    setState(() => _isGoogleLoading = true);
    try {
      final result = await ref.read(authServiceProvider).signInWithGoogle();
      if (result != null && mounted) context.go(RouteNames.home);
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Google sign-up failed. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  String _parseError(String error) {
    if (error.contains('email-already-in-use')) return 'This email is already registered.';
    if (error.contains('weak-password')) return 'Password is too weak.';
    if (error.contains('network-request-failed')) return 'Network error. Check your connection.';
    return 'Sign up failed. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Back button
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 24),

                  Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                  ).animate(delay: 100.ms).fadeIn(duration: 500.ms),

                  const SizedBox(height: 6),

                  Text(
                    'Start generating professional development prompts',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                  ).animate(delay: 150.ms).fadeIn(duration: 500.ms),

                  const SizedBox(height: 32),

                  CustomTextField(
                    controller: _nameCtrl,
                    label: 'Full Name',
                    hint: 'John Doe',
                    prefixIcon: Icons.person_rounded,
                    validator: Validators.name,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                  ).animate(delay: 200.ms).fadeIn(duration: 500.ms).slideY(begin: 0.2),

                  const SizedBox(height: 14),

                  CustomTextField(
                    controller: _emailCtrl,
                    label: 'Email Address',
                    hint: 'you@example.com',
                    prefixIcon: Icons.email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                    textInputAction: TextInputAction.next,
                  ).animate(delay: 250.ms).fadeIn(duration: 500.ms).slideY(begin: 0.2),

                  const SizedBox(height: 14),

                  CustomTextField(
                    controller: _passwordCtrl,
                    label: 'Password',
                    hint: 'Min 8 chars, uppercase, number, symbol',
                    prefixIcon: Icons.lock_rounded,
                    obscureText: true,
                    validator: Validators.password,
                    textInputAction: TextInputAction.next,
                  ).animate(delay: 300.ms).fadeIn(duration: 500.ms).slideY(begin: 0.2),

                  const SizedBox(height: 14),

                  CustomTextField(
                    controller: _confirmCtrl,
                    label: 'Confirm Password',
                    hint: 'Re-enter your password',
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: true,
                    validator: Validators.confirmPassword(_passwordCtrl.text),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _signup(),
                  ).animate(delay: 350.ms).fadeIn(duration: 500.ms).slideY(begin: 0.2),

                  const SizedBox(height: 28),

                  PrimaryButton(
                    text: 'Create Account',
                    onPressed: _signup,
                    isLoading: _isLoading,
                    icon: Icons.rocket_launch_rounded,
                  ).animate(delay: 400.ms).fadeIn(duration: 500.ms),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'or sign up with',
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ).animate(delay: 450.ms).fadeIn(duration: 500.ms),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: _isGoogleLoading ? null : _googleSignUp,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                      ),
                      child: _isGoogleLoading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('G', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF4285F4))),
                                const SizedBox(width: 12),
                                Text(
                                  'Continue with Google',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ).animate(delay: 500.ms).fadeIn(duration: 500.ms),

                  const SizedBox(height: 28),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.pop(),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ).animate(delay: 550.ms).fadeIn(duration: 500.ms),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
