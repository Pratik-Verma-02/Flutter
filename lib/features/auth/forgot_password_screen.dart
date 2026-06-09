import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:agent_prompt/core/constants/app_colors.dart';
import 'package:agent_prompt/core/utils/validators.dart';
import 'package:agent_prompt/core/utils/snackbar_utils.dart';
import 'package:agent_prompt/core/widgets/primary_button.dart';
import 'package:agent_prompt/core/widgets/custom_text_field.dart';
import 'package:agent_prompt/core/widgets/gradient_background.dart';
import 'package:agent_prompt/providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).resetPassword(_emailCtrl.text);
      if (mounted) setState(() => _emailSent = true);
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Failed to send reset email. Please check the address.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 32),
                if (_emailSent)
                  _buildSuccessState(context, isDark)
                else
                  _buildFormState(context, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessState(BuildContext context, bool isDark) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.mark_email_read_rounded, color: AppColors.success, size: 40),
        ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
        const SizedBox(height: 24),
        Text(
          'Check Your Email',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ).animate(delay: 200.ms).fadeIn(),
        const SizedBox(height: 8),
        Text(
          'We sent a password reset link to\n${_emailCtrl.text}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
        ).animate(delay: 300.ms).fadeIn(),
        const SizedBox(height: 32),
        PrimaryButton(
          text: 'Back to Sign In',
          onPressed: () => context.pop(),
        ).animate(delay: 400.ms).fadeIn(),
      ],
    );
  }

  Widget _buildFormState(BuildContext context, bool isDark) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reset Password',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 8),
          Text(
            'Enter your email and we\'ll send you a reset link.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
          ).animate(delay: 100.ms).fadeIn(),
          const SizedBox(height: 32),
          CustomTextField(
            controller: _emailCtrl,
            label: 'Email Address',
            hint: 'you@example.com',
            prefixIcon: Icons.email_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _sendReset(),
          ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),
          const SizedBox(height: 28),
          PrimaryButton(
            text: 'Send Reset Link',
            onPressed: _sendReset,
            isLoading: _isLoading,
            icon: Icons.send_rounded,
          ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),
        ],
      ),
    );
  }
}
