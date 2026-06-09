import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:agent_prompt/core/constants/app_colors.dart';
import 'package:agent_prompt/core/constants/app_constants.dart';
import 'package:agent_prompt/core/router/route_names.dart';
import 'package:agent_prompt/core/widgets/gradient_background.dart';
import 'package:agent_prompt/models/prompt_request_model.dart';
import 'package:agent_prompt/providers/prompt_provider.dart';

class GeneratingScreen extends ConsumerStatefulWidget {
  final PromptRequestModel request;

  const GeneratingScreen({super.key, required this.request});

  @override
  ConsumerState<GeneratingScreen> createState() => _GeneratingScreenState();
}

class _GeneratingScreenState extends ConsumerState<GeneratingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _orbitController;
  late Timer _messageTimer;
  int _messageIndex = 0;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _orbitController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();

    _messageTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) setState(() => _messageIndex = (_messageIndex + 1) % AppConstants.statusMessages.length);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _generate());
  }

  Future<void> _generate() async {
    if (_hasStarted) return;
    _hasStarted = true;

    final prompt = await ref.read(promptGenerationProvider.notifier).generate(widget.request);

    if (!mounted) return;
    if (prompt != null) {
      context.go('${RouteNames.promptResult}/${prompt.promptId}', extra: prompt.content);
    } else {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _orbitController.dispose();
    _messageTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final genState = ref.watch(promptGenerationProvider);

    return Scaffold(
      body: AnimatedMeshGradient(
        child: SafeArea(
          child: genState is AsyncError
              ? _buildErrorState(context, genState.error.toString())
              : _buildLoadingState(context),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Orbit animation
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ring
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) => Container(
                      width: 100 + 20 * _pulseController.value,
                      height: 100 + 20 * _pulseController.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3 * (1 - _pulseController.value)),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  // Core icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)],
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 36),
                  ),
                  // Orbiting dot
                  AnimatedBuilder(
                    animation: _orbitController,
                    builder: (context, child) {
                      final angle = _orbitController.value * 2 * 3.14159;
                      return Transform.translate(
                        offset: Offset(50 * 0.866 * (angle > 3.14159 ? -1 : 1), -50 * 0.5),
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms),

            const SizedBox(height: 36),

            Text(
              'AI is crafting your prompt',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 12),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Text(
                AppConstants.statusMessages[_messageIndex],
                key: ValueKey(_messageIndex),
                style: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 60),

            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel', style: TextStyle(color: AppColors.darkTextSecondary)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 40),
            ),
            const SizedBox(height: 24),
            const Text('Generation Failed', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              error.contains('credits') ? error : 'Something went wrong. Please try again.',
              style: const TextStyle(color: AppColors.darkTextSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                ref.read(promptGenerationProvider.notifier).reset();
                _hasStarted = false;
                _generate();
              },
              child: const Text('Try Again'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back', style: TextStyle(color: AppColors.darkTextSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}
