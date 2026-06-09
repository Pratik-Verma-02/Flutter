import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:agent_prompt/core/constants/app_colors.dart';

class ShimmerCard extends StatelessWidget {
  final double? height;
  final double? width;
  final double borderRadius;

  const ShimmerCard({
    super.key,
    this.height = 120,
    this.width,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF1A1A3E) : const Color(0xFFE8E8F0),
      highlightColor: isDark ? const Color(0xFF2A2A5A) : const Color(0xFFF5F5FF),
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const ShimmerList({super.key, this.itemCount = 5, this.itemHeight = 100});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => ShimmerCard(height: itemHeight),
    );
  }
}

class ShimmerProfile extends StatelessWidget {
  const ShimmerProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF1A1A3E) : const Color(0xFFE8E8F0),
      highlightColor: isDark ? const Color(0xFF2A2A5A) : const Color(0xFFF5F5FF),
      child: Column(
        children: [
          const CircleAvatar(radius: 50, backgroundColor: Colors.white),
          const SizedBox(height: 16),
          Container(height: 20, width: 140, color: Colors.white, margin: const EdgeInsets.symmetric(horizontal: 80)),
          const SizedBox(height: 8),
          Container(height: 14, width: 200, color: Colors.white, margin: const EdgeInsets.symmetric(horizontal: 60)),
        ],
      ),
    );
  }
}

class ShimmerHomeCard extends StatelessWidget {
  const ShimmerHomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF1A1A3E) : const Color(0xFFE8E8F0),
      highlightColor: isDark ? const Color(0xFF2A2A5A) : const Color(0xFFF5F5FF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 160, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Container(height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)))),
              const SizedBox(width: 12),
              Expanded(child: Container(height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)))),
            ],
          ),
        ],
      ),
    );
  }
}
