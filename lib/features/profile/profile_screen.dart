import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:agent_prompt/core/constants/app_colors.dart';
import 'package:agent_prompt/core/router/route_names.dart';
import 'package:agent_prompt/core/utils/extensions.dart';
import 'package:agent_prompt/core/utils/snackbar_utils.dart';
import 'package:agent_prompt/core/widgets/gradient_background.dart';
import 'package:agent_prompt/core/widgets/shimmer_loading.dart';
import 'package:agent_prompt/providers/auth_provider.dart';
import 'package:agent_prompt/providers/user_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: userAsync.when(
                  data: (user) {
                    if (user == null) return const ShimmerProfile();
                    return Column(
                      children: [
                        const SizedBox(height: 24),
                        // Profile header
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                                ),
                                child: Center(
                                  child: Text(
                                    user.initials,
                                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                                    const SizedBox(height: 3),
                                    Text(user.email, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Member since ${user.createdAt.formattedDate}',
                                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),

                        const SizedBox(height: 20),

                        // Stats row
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(child: _StatCard(label: 'Credits Left', value: '${user.credits}', icon: Icons.bolt_rounded, color: user.credits >= 7 ? AppColors.success : (user.credits >= 4 ? AppColors.warning : AppColors.error))),
                              const SizedBox(width: 10),
                              Expanded(child: _StatCard(label: 'Prompts Made', value: '${user.totalPrompts}', icon: Icons.description_rounded, color: AppColors.primary)),
                              const SizedBox(width: 10),
                              Expanded(child: _StatCard(label: 'Daily Limit', value: '10', icon: Icons.refresh_rounded, color: AppColors.secondary)),
                            ],
                          ),
                        ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

                        const SizedBox(height: 24),

                        // Menu items
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              _MenuItem(
                                icon: Icons.settings_rounded,
                                label: 'Settings',
                                color: AppColors.primary,
                                onTap: () => context.push(RouteNames.settings),
                              ),
                              _MenuItem(
                                icon: Icons.info_rounded,
                                label: 'About AgentPrompt',
                                color: AppColors.secondary,
                                onTap: () {},
                              ),
                              _MenuItem(
                                icon: Icons.security_rounded,
                                label: 'Privacy Policy',
                                color: AppColors.accent,
                                onTap: () {},
                              ),
                              _MenuItem(
                                icon: Icons.description_outlined,
                                label: 'Terms of Service',
                                color: const Color(0xFF7B61FF),
                                onTap: () {},
                              ),
                              _MenuItem(
                                icon: Icons.star_rounded,
                                label: 'Rate App',
                                color: AppColors.warning,
                                onTap: () {},
                              ),
                            ].asMap().entries.map((e) => e.value.animate(delay: ((e.key + 2) * 50).ms).fadeIn().slideX(begin: 0.2)).toList(),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Logout button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (c) => AlertDialog(
                                    title: const Text('Sign Out?'),
                                    content: const Text('You will need to sign in again to use the app.'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                                      ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Sign Out')),
                                    ],
                                  ),
                                );
                                if (confirm == true && context.mounted) {
                                  await ref.read(authServiceProvider).signOut();
                                  if (context.mounted) context.go(RouteNames.login);
                                }
                              },
                              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                              label: const Text('Sign Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.error, width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ).animate(delay: 400.ms).fadeIn(),

                        const SizedBox(height: 12),

                        TextButton(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (c) => AlertDialog(
                                title: const Text('Delete Account?'),
                                content: const Text('This action is permanent and cannot be undone. All your data will be deleted.'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(c, true),
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                    child: const Text('Delete Account'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true && context.mounted) {
                              try {
                                await ref.read(authServiceProvider).deleteAccount();
                                if (context.mounted) context.go(RouteNames.login);
                              } catch (e) {
                                if (context.mounted) SnackbarUtils.showError(context, 'Failed to delete account. Please re-login and try again.');
                              }
                            }
                          },
                          child: const Text('Delete Account', style: TextStyle(color: AppColors.error, fontSize: 12)),
                        ).animate(delay: 450.ms).fadeIn(),

                        const SizedBox(height: 32),
                      ],
                    );
                  },
                  loading: () => const Padding(padding: EdgeInsets.all(24), child: ShimmerProfile()),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600))),
            Icon(Icons.chevron_right_rounded, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}
