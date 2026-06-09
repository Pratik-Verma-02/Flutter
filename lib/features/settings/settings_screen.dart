import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:agent_prompt/core/constants/app_colors.dart';
import 'package:agent_prompt/core/widgets/gradient_background.dart';
import 'package:agent_prompt/core/theme/theme_provider.dart';
import 'package:agent_prompt/services/storage_service.dart';

final _storageServiceProvider = Provider<StorageService>((ref) => StorageService());

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _promptLength = 'Standard';
  String _promptStyle = 'Balanced';
  bool _creditReminder = true;
  bool _appUpdates = true;
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadPackageInfo();
  }

  Future<void> _loadSettings() async {
    final storage = ref.read(_storageServiceProvider);
    final length = await storage.getPromptLength();
    final style = await storage.getPromptStyle();
    final creditReminder = await storage.getCreditReminder();
    final appUpdates = await storage.getAppUpdates();
    if (mounted) {
      setState(() {
        _promptLength = length;
        _promptStyle = style;
        _creditReminder = creditReminder;
        _appUpdates = appUpdates;
      });
    }
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _packageInfo = info);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w700)),
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Appearance
                      _SectionHeader(label: 'Appearance'),
                      const SizedBox(height: 12),
                      _SettingsCard(
                        isDark: isDark,
                        children: [
                          _ThemeTile(
                            label: 'System Default',
                            icon: Icons.smartphone_rounded,
                            isSelected: themeMode == ThemeMode.system,
                            onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system),
                          ),
                          const Divider(height: 1),
                          _ThemeTile(
                            label: 'Light Mode',
                            icon: Icons.light_mode_rounded,
                            isSelected: themeMode == ThemeMode.light,
                            onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light),
                          ),
                          const Divider(height: 1),
                          _ThemeTile(
                            label: 'Dark Mode',
                            icon: Icons.dark_mode_rounded,
                            isSelected: themeMode == ThemeMode.dark,
                            onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark),
                          ),
                        ],
                      ).animate().fadeIn(duration: 400.ms),

                      const SizedBox(height: 24),

                      // Prompt Preferences
                      _SectionHeader(label: 'Prompt Preferences'),
                      const SizedBox(height: 12),
                      _SettingsCard(
                        isDark: isDark,
                        children: [
                          _DropdownTile(
                            label: 'Default Length',
                            value: _promptLength,
                            items: const ['Concise', 'Standard', 'Detailed'],
                            onChanged: (v) async {
                              setState(() => _promptLength = v);
                              await ref.read(_storageServiceProvider).setPromptLength(v);
                            },
                          ),
                          const Divider(height: 1),
                          _DropdownTile(
                            label: 'Default Style',
                            value: _promptStyle,
                            items: const ['Technical', 'Balanced', 'Creative'],
                            onChanged: (v) async {
                              setState(() => _promptStyle = v);
                              await ref.read(_storageServiceProvider).setPromptStyle(v);
                            },
                          ),
                        ],
                      ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

                      const SizedBox(height: 24),

                      // Notifications
                      _SectionHeader(label: 'Notifications'),
                      const SizedBox(height: 12),
                      _SettingsCard(
                        isDark: isDark,
                        children: [
                          _SwitchTile(
                            label: 'Credit Reset Reminder',
                            subtitle: 'Get notified when daily credits reset',
                            value: _creditReminder,
                            onChanged: (v) async {
                              setState(() => _creditReminder = v);
                              await ref.read(_storageServiceProvider).setCreditReminder(v);
                            },
                          ),
                          const Divider(height: 1),
                          _SwitchTile(
                            label: 'App Updates',
                            subtitle: 'Stay up to date with new features',
                            value: _appUpdates,
                            onChanged: (v) async {
                              setState(() => _appUpdates = v);
                              await ref.read(_storageServiceProvider).setAppUpdates(v);
                            },
                          ),
                        ],
                      ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

                      const SizedBox(height: 24),

                      // About
                      _SectionHeader(label: 'About'),
                      const SizedBox(height: 12),
                      _SettingsCard(
                        isDark: isDark,
                        children: [
                          _InfoTile(label: 'App Version', value: _packageInfo?.version ?? '1.0.0'),
                          const Divider(height: 1),
                          _InfoTile(label: 'Build Number', value: _packageInfo?.buildNumber ?? '1'),
                          const Divider(height: 1),
                          _InfoTile(label: 'Package Name', value: 'com.prompt.agent'),
                        ],
                      ).animate(delay: 300.ms).fadeIn(duration: 400.ms),

                      const SizedBox(height: 32),
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

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;

  const _SettingsCard({required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(children: children),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeTile({required this.label, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.primary : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
      title: Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
      trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}

class _DropdownTile extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final void Function(String) onChanged;

  const _DropdownTile({required this.label, required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500))),
          DropdownButton<String>(
            value: value,
            underline: const SizedBox.shrink(),
            items: items.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) => v != null ? onChanged(v) : null,
          ),
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final void Function(bool) onChanged;

  const _SwitchTile({required this.label, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: value,
      activeColor: AppColors.primary,
      onChanged: onChanged,
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
          Text(value, style: TextStyle(fontSize: 14, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary)),
        ],
      ),
    );
  }
}
