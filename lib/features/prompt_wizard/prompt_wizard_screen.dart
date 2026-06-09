import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:go_router/go_router.dart';
import 'package:agent_prompt/core/constants/app_colors.dart';
import 'package:agent_prompt/core/constants/app_constants.dart';
import 'package:agent_prompt/core/router/route_names.dart';
import 'package:agent_prompt/core/utils/extensions.dart';
import 'package:agent_prompt/core/utils/validators.dart';
import 'package:agent_prompt/core/widgets/gradient_background.dart';
import 'package:agent_prompt/core/widgets/primary_button.dart';
import 'package:agent_prompt/core/widgets/custom_text_field.dart';
import 'package:agent_prompt/models/prompt_request_model.dart';
import 'package:agent_prompt/providers/user_provider.dart';

class PromptWizardScreen extends ConsumerStatefulWidget {
  const PromptWizardScreen({super.key});

  @override
  ConsumerState<PromptWizardScreen> createState() => _PromptWizardScreenState();
}

class _PromptWizardScreenState extends ConsumerState<PromptWizardScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentStep = 0;
  static const int _totalSteps = 5;

  // Step 1
  String? _selectedProjectType;

  // Step 2
  final _appNameCtrl = TextEditingController();
  final _packageNameCtrl = TextEditingController();
  final _versionCtrl = TextEditingController(text: '1.0.0');
  final _step2FormKey = GlobalKey<FormState>();

  // Step 3
  Color _primaryColor = const Color(0xFF6C63FF);
  Color _secondaryColor = const Color(0xFF00D4FF);
  Color _accentColor = const Color(0xFFFF6B6B);

  // Step 4
  final _descCtrl = TextEditingController();
  final _step4FormKey = GlobalKey<FormState>();

  bool _showPackageName(String? type) {
    return type == 'Android App' || type == 'iOS App';
  }

  static const List<Map<String, dynamic>> _projectTypes = [
    {'label': 'Android App', 'icon': Icons.phone_android_rounded, 'color': Color(0xFF3DDC84)},
    {'label': 'iOS App', 'icon': Icons.phone_iphone_rounded, 'color': Color(0xFF007AFF)},
    {'label': 'Web App', 'icon': Icons.web_rounded, 'color': Color(0xFF6C63FF)},
    {'label': 'Website', 'icon': Icons.language_rounded, 'color': Color(0xFF00D4FF)},
    {'label': 'SaaS', 'icon': Icons.cloud_rounded, 'color': Color(0xFFFF6B6B)},
    {'label': 'AI Tool', 'icon': Icons.psychology_rounded, 'color': Color(0xFFFFBD2E)},
    {'label': 'Desktop Application', 'icon': Icons.desktop_mac_rounded, 'color': Color(0xFF7B61FF)},
    {'label': 'Backend API', 'icon': Icons.dns_rounded, 'color': Color(0xFF50FA7B)},
    {'label': 'Game', 'icon': Icons.sports_esports_rounded, 'color': Color(0xFFFF5555)},
    {'label': 'Chrome Extension', 'icon': Icons.extension_rounded, 'color': Color(0xFF4285F4)},
    {'label': 'Other', 'icon': Icons.category_rounded, 'color': Color(0xFF9A9AB0)},
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _appNameCtrl.dispose();
    _packageNameCtrl.dispose();
    _versionCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0 && _selectedProjectType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a project type')),
      );
      return;
    }
    if (_currentStep == 1 && !_step2FormKey.currentState!.validate()) return;
    if (_currentStep == 3 && !_step4FormKey.currentState!.validate()) return;

    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _generate() {
    final credits = ref.read(creditsProvider).valueOrNull ?? 0;
    if (credits < AppConstants.generateCost) {
      _showInsufficientCreditsDialog();
      return;
    }

    final request = PromptRequestModel(
      projectType: _selectedProjectType!,
      appName: _appNameCtrl.text.trim(),
      packageName: _showPackageName(_selectedProjectType) ? _packageNameCtrl.text.trim() : null,
      versionName: _versionCtrl.text.trim(),
      primaryColor: _primaryColor.toHex(),
      secondaryColor: _secondaryColor.toHex(),
      accentColor: _accentColor.toHex(),
      description: _descCtrl.text.trim(),
    );

    context.push(RouteNames.generating, extra: request);
  }

  void _showInsufficientCreditsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Insufficient Credits'),
        content: Text(
          'You need ${AppConstants.generateCost} credits to generate a prompt. '
          'Your credits will reset tomorrow.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  void _showColorPicker(Color current, ValueChanged<Color> onChanged, String title) {
    showDialog(
      context: context,
      builder: (context) {
        Color tempColor = current;
        return AlertDialog(
          title: Text('Pick $title Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: current,
              onColorChanged: (c) => tempColor = c,
              enableAlpha: false,
              labelTypes: const [ColorLabelType.hex],
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                onChanged(tempColor);
                Navigator.pop(context);
              },
              child: const Text('Select'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.close_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Prompt',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'Step ${_currentStep + 1} of $_totalSteps',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Step indicator
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: List.generate(_totalSteps, (i) {
                    final isActive = i <= _currentStep;
                    return Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 4,
                        margin: EdgeInsets.only(right: i < _totalSteps - 1 ? 4 : 0),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 20),

              // Page content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStep1(isDark),
                    _buildStep2(isDark),
                    _buildStep3(isDark),
                    _buildStep4(isDark),
                    _buildStep5(isDark),
                  ],
                ),
              ),

              // Navigation buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          onPressed: _prevStep,
                          child: const Text('Previous'),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: _currentStep == _totalSteps - 1
                          ? PrimaryButton(
                              text: 'Generate Prompt (5 Credits)',
                              onPressed: _generate,
                              icon: Icons.auto_awesome_rounded,
                            )
                          : PrimaryButton(
                              text: 'Next →',
                              onPressed: _nextStep,
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What are you building?', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700))
              .animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 6),
          Text('Select your project type to get started.', style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary))
              .animate(delay: 100.ms).fadeIn(),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: _projectTypes.length,
            itemBuilder: (context, index) {
              final type = _projectTypes[index];
              final isSelected = _selectedProjectType == type['label'];
              return GestureDetector(
                onTap: () => setState(() => _selectedProjectType = type['label'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (type['color'] as Color).withOpacity(0.15)
                        : (isDark ? AppColors.darkCard : AppColors.lightCard),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? type['color'] as Color : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(type['icon'] as IconData, color: type['color'] as Color, size: 28),
                      const SizedBox(height: 6),
                      Text(
                        type['label'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? type['color'] as Color : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate(delay: (index * 40).ms).fadeIn().scale(begin: const Offset(0.8, 0.8));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep2(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Form(
        key: _step2FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Project Information', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700))
                .animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 6),
            Text('Tell us about your project.', style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary))
                .animate(delay: 100.ms).fadeIn(),
            const SizedBox(height: 24),
            CustomTextField(
              controller: _appNameCtrl,
              label: 'App Name *',
              hint: 'My Awesome App',
              prefixIcon: Icons.apps_rounded,
              validator: (v) => Validators.required(v, 'App Name'),
              textCapitalization: TextCapitalization.words,
            ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),
            if (_showPackageName(_selectedProjectType)) ...[
              const SizedBox(height: 14),
              CustomTextField(
                controller: _packageNameCtrl,
                label: 'Package Name',
                hint: 'com.example.myapp',
                prefixIcon: Icons.code_rounded,
                validator: Validators.packageName,
              ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.2),
            ],
            const SizedBox(height: 14),
            CustomTextField(
              controller: _versionCtrl,
              label: 'Version Name',
              hint: '1.0.0',
              prefixIcon: Icons.tag_rounded,
              validator: (v) => Validators.required(v, 'Version'),
            ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Color Palette', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700))
              .animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 6),
          Text('Choose your app\'s color scheme.', style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary))
              .animate(delay: 100.ms).fadeIn(),
          const SizedBox(height: 24),
          _ColorPickerRow(
            label: 'Primary Color',
            color: _primaryColor,
            onTap: () => _showColorPicker(_primaryColor, (c) => setState(() => _primaryColor = c), 'Primary'),
          ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),
          const SizedBox(height: 14),
          _ColorPickerRow(
            label: 'Secondary Color',
            color: _secondaryColor,
            onTap: () => _showColorPicker(_secondaryColor, (c) => setState(() => _secondaryColor = c), 'Secondary'),
          ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.2),
          const SizedBox(height: 14),
          _ColorPickerRow(
            label: 'Accent Color',
            color: _accentColor,
            onTap: () => _showColorPicker(_accentColor, (c) => setState(() => _accentColor = c), 'Accent'),
          ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),
          const SizedBox(height: 24),
          // Live preview
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Preview', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: Container(height: 48, decoration: BoxDecoration(color: _primaryColor, borderRadius: BorderRadius.circular(12)), child: const Center(child: Text('Primary', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12))))),
                    const SizedBox(width: 8),
                    Expanded(child: Container(height: 48, decoration: BoxDecoration(color: _secondaryColor, borderRadius: BorderRadius.circular(12)), child: const Center(child: Text('Secondary', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12))))),
                    const SizedBox(width: 8),
                    Expanded(child: Container(height: 48, decoration: BoxDecoration(color: _accentColor, borderRadius: BorderRadius.circular(12)), child: const Center(child: Text('Accent', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12))))),
                  ],
                ),
              ],
            ),
          ).animate(delay: 350.ms).fadeIn(),
        ],
      ),
    );
  }

  Widget _buildStep4(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Form(
        key: _step4FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product Description', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700))
                .animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 6),
            Text('Describe your product in detail for the best prompt.', style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary))
                .animate(delay: 100.ms).fadeIn(),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Include: Features & functionality • User flow • UI requirements • Backend requirements • Security needs • Monetization strategy',
                style: TextStyle(fontSize: 12, color: AppColors.primary, height: 1.5),
              ),
            ).animate(delay: 150.ms).fadeIn(),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _descCtrl,
              label: 'Description',
              hint: 'Describe your app\'s purpose, features, target users, technical requirements, monetization model...',
              maxLines: 12,
              minLines: 8,
              maxLength: AppConstants.maxPromptLength,
              textCapitalization: TextCapitalization.sentences,
              validator: (v) {
                if (v == null || v.trim().length < AppConstants.minDescriptionLength) {
                  return 'Please provide at least ${AppConstants.minDescriptionLength} characters';
                }
                return null;
              },
            ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _descCtrl,
                builder: (context, value, _) => Text(
                  '${value.text.length} characters',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep5(bool isDark) {
    final showPkg = _showPackageName(_selectedProjectType);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review & Generate', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700))
              .animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 6),
          Text('Review your project details before generating.', style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary))
              .animate(delay: 100.ms).fadeIn(),
          const SizedBox(height: 20),
          _ReviewCard(
            isDark: isDark,
            children: [
              _ReviewRow(label: 'Project Type', value: _selectedProjectType ?? '-'),
              _ReviewRow(label: 'App Name', value: _appNameCtrl.text.isEmpty ? '-' : _appNameCtrl.text),
              if (showPkg && _packageNameCtrl.text.isNotEmpty)
                _ReviewRow(label: 'Package Name', value: _packageNameCtrl.text),
              _ReviewRow(label: 'Version', value: _versionCtrl.text.isEmpty ? '-' : _versionCtrl.text),
            ],
          ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),
          const SizedBox(height: 12),
          _ReviewCard(
            isDark: isDark,
            children: [
              Row(
                children: [
                  Expanded(child: _ColorDot('Primary', _primaryColor)),
                  Expanded(child: _ColorDot('Secondary', _secondaryColor)),
                  Expanded(child: _ColorDot('Accent', _accentColor)),
                ],
              ),
            ],
          ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.2),
          const SizedBox(height: 12),
          _ReviewCard(
            isDark: isDark,
            children: [
              Text('Description', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary)),
              const SizedBox(height: 6),
              Text(
                _descCtrl.text.isEmpty ? '-' : _descCtrl.text.truncate(200),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5),
              ),
            ],
          ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, color: AppColors.warning),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('This will use 5 credits', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.warning)),
                      Consumer(builder: (_, ref, __) {
                        final credits = ref.watch(creditsProvider).valueOrNull ?? 0;
                        return Text('You have $credits credits remaining', style: const TextStyle(fontSize: 12, color: AppColors.warning));
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ).animate(delay: 350.ms).fadeIn(),
        ],
      ),
    );
  }
}

class _ColorPickerRow extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ColorPickerRow({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.titleSmall),
                  Text(color.toHex(), style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary)),
                ],
              ),
            ),
            Icon(Icons.colorize_rounded, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;

  const _ReviewCard({required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final String label;
  final Color color;

  const _ColorDot(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
