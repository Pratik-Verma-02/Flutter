import 'package:flutter/material.dart';
import 'package:agent_prompt/core/constants/app_colors.dart';

class LoadingWidget extends StatefulWidget {
  final double size;
  final Color? color;

  const LoadingWidget({super.key, this.size = 60, this.color});

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primary;
    return SizedBox(
      width: widget.size,
      height: widget.size / 4,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (i) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final delay = i * 0.2;
              final t = (_controller.value - delay).clamp(0.0, 1.0);
              final scale = 0.5 + 0.5 * (1 - (2 * t - 1).abs());
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.size / 5,
                  height: widget.size / 5,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.5 + 0.5 * scale),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

class FullScreenLoader extends StatelessWidget {
  final String? message;

  const FullScreenLoader({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const LoadingWidget(size: 60),
          if (message != null) ...[
            const SizedBox(height: 20),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
