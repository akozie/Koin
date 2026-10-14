import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import 'animations.dart';

/// Gradient card showing total savings with a show/hide balance toggle.
class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.totalSavings,
    required this.activePlans,
    required this.isBalanceVisible,
    required this.onToggleVisibility,
  });

  final int totalSavings;
  final int activePlans;
  final bool isBalanceVisible;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.xl)),
      ),
      child: Stack(
        children: [
          // Decorative "coin" from the brand mark.
          Positioned(
            right: -36,
            top: -36,
            child: _Circle(size: 140, color: AppColors.lime.withValues(alpha: 0.18)),
          ),
          Positioned(
            right: 40,
            bottom: -50,
            child: _Circle(size: 110, color: Colors.white.withValues(alpha: 0.06)),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.savings_rounded, color: AppColors.lime, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Total Savings',
                      style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: onToggleVisibility,
                      tooltip: isBalanceVisible ? 'Hide balance' : 'Show balance',
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        isBalanceVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: AnimatedAmount(
                    amount: totalSavings,
                    hidden: !isBalanceVisible,
                    style: textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs + 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lime.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Text(
                    '$activePlans active ${activePlans == 1 ? 'plan' : 'plans'}',
                    style: textTheme.labelMedium?.copyWith(color: AppColors.lime),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
