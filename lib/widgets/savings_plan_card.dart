import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';
import '../models/savings_plan.dart';
import '../utils/formatters.dart';
import 'product_visuals.dart';

class SavingsPlanCard extends StatelessWidget {
  const SavingsPlanCard({super.key, required this.plan});

  final SavingsPlan plan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final category = categoryForProductId(plan.productId);
    final percent = (plan.progress * 100).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Row(
              children: [
                CategoryIcon(category: category, size: 44),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        '${plan.frequency.label} · ${plan.productName}',
                        style: muted,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.format(plan.currentBalance),
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text('of ${CurrencyFormatter.compact(plan.targetAmount)}', style: muted),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: plan.progress),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                      builder: (_, value, _) => LinearProgressIndicator(
                        value: value,
                        minHeight: 6,
                        color: category.color,
                        backgroundColor: category.color.withValues(alpha: 0.14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text('$percent%', style: muted),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
