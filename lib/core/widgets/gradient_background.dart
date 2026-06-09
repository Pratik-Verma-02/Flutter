import 'package:flutter/material.dart';
import 'package:agent_prompt/core/constants/app_colors.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const GradientBackground({
    super.key,
    required this.child,
    this.colors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: colors ??
              (isDark
                  ? const [
                      Color(0xFF0A0A1A),
                      Color(0xFF0D0D2B),
                      Color(0xFF12103A),
                    ]
                  : const [
                      Color(0xFFF0F1FF),
                      Color(0xFFF8F9FE),
                      Color(0xFFFFFFFF),
                    ]),
        ),
      ),
      child: child,
    );
  }
}

class AnimatedMeshGradient extends StatefulWidget {
  final Widget child;

  const AnimatedMeshGradient({super.key, required this.child});

  @override
  State<AnimatedMeshGradient> createState() => _AnimatedMeshGradientState();
}

class _AnimatedMeshGradientState extends State<AnimatedMeshGradient>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.lerp(
                    Alignment.topLeft,
                    Alignment.topRight,
                    _animation.value,
                  ) ??
                  Alignment.topLeft,
              end: Alignment.lerp(
                    Alignment.bottomRight,
                    Alignment.bottomLeft,
                    _animation.value,
                  ) ??
                  Alignment.bottomRight,
              colors: const [
                Color(0xFF0A0A2E),
                Color(0xFF1A1050),
                Color(0xFF6C63FF),
                Color(0xFF00D4FF),
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class SplashGradientBackground extends StatelessWidget {
  final Widget child;

  const SplashGradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.splashGradient,
      ),
      child: child,
    );
  }
}
