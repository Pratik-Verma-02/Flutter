import 'package:flutter/material.dart';
import 'package:agent_prompt/core/constants/app_colors.dart';

class CreditBadge extends StatelessWidget {
  final int credits;
  final bool showLabel;
  final double fontSize;

  const CreditBadge({
    super.key,
    required this.credits,
    this.showLabel = true,
    this.fontSize = 14,
  });

  Color get _creditColor {
    if (credits >= 7) return AppColors.success;
    if (credits >= 4) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _creditColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _creditColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt_rounded, color: _creditColor, size: 16),
          const SizedBox(width: 4),
          Text(
            showLabel ? '$credits Credits' : '$credits',
            style: TextStyle(
              color: _creditColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
