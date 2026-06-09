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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).signInWithEmail(
            email: _emailCtrl.text,
            password: _passwordCtrl.text,
          );
      if (mounted) context.go(RouteNames.home);
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, _parseAuthError(e.toString()));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => _isGoogleLoading = true);
    try {
      final result = await ref.read(authServiceProvider).signInWithGoogle();
      if (result != null && mounted) context.go(RouteNames.home);
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Google sign-in failed. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  String _parseAuthError(String error) {
    if (error.contains('user-not-found')) return 'No account found with this email.';
    if (error.contains('wrong-password')) return 'Incorrect password. Please try again.';
    if (error.contains('too-many-requests')) return 'Too many attempts. Please try later.';
    if (error.contains('network-request-failed')) return 'Network error. Check your connection.';
    return 'Sign in failed. Please check your credentials.';
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
                  const SizedBox(height: 40),

                  // Logo
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 36),
                    ),
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.3),

                  const SizedBox(height: 32),

                  // Header
                  Text(
                    'Welcome Back',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                  ).animate(delay: 100.ms).fadeIn(duration: 500.ms).slideX(begin: -0.2),

                  const SizedBox(height: 6),

                  Text(
                    'Sign in to continue building amazing prompts',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                  ).animate(delay: 150.ms).fadeIn(duration: 500.ms),

                  const SizedBox(height: 36),

                  // Email field
                  CustomTextField(
                    controller: _emailCtrl,
                    label: 'Email Address',
                    hint: 'you@example.com',
                    prefixIcon: Icons.email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                    textInputAction: TextInputAction.next,
                  ).animate(delay: 200.ms).fadeIn(duration: 500.ms).slideY(begin: 0.2),

                  const SizedBox(height: 16),

                  // Password field
                  CustomTextField(
                    controller: _passwordCtrl,
                    label: 'Password',
                    hint: '••••••••',
                    prefixIcon: Icons.lock_rounded,
                    obscureText: true,
                    validator: (v) => v?.isEmpty == true ? 'Password is required' : null,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _login(),
                  ).animate(delay: 250.ms).fadeIn(duration: 500.ms).slideY(begin: 0.2),

                  const SizedBox(height: 12),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push(RouteNames.forgotPassword),
                      child: const Text('Forgot Password?'),
                    ),
                  ).animate(delay: 300.ms).fadeIn(duration: 500.ms),

                  const SizedBox(height: 24),

                  // Login button
                  PrimaryButton(
                    text: 'Sign In',
                    onPressed: _login,
                    isLoading: _isLoading,
                  ).animate(delay: 350.ms).fadeIn(duration: 500.ms).slideY(begin: 0.2),

                  const SizedBox(height: 20),

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'or continue with',
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ).animate(delay: 400.ms).fadeIn(duration: 500.ms),

                  const SizedBox(height: 20),

                  // Google Sign-In
                  _GoogleSignInButton(
                    isLoading: _isGoogleLoading,
                    onPressed: _googleSignIn,
                  ).animate(delay: 450.ms).fadeIn(duration: 500.ms).slideY(begin: 0.2),

                  const SizedBox(height: 32),

                  // Sign up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push(RouteNames.signup),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ).animate(delay: 500.ms).fadeIn(duration: 500.ms),

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

class _GoogleSignInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _GoogleSignInButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google G icon
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      'G',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4285F4),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
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
    );
  }
}
