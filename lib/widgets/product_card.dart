import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';
import '../models/savings_product.dart';
import '../utils/formatters.dart';
import 'product_visuals.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, required this.onViewDetails});

  final SavingsProduct product;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onViewDetails,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Hero(
                    tag: 'product-icon-${product.id}',
                    child: CategoryIcon(category: product.category),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      product.name,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _RateBadge(label: '${product.interestLabel} p.a.'),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                product.description,
                style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.xs,
                children: [
                  _Meta(icon: Icons.schedule_rounded, label: product.durationLabel),
                  _Meta(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Min. ${CurrencyFormatter.format(product.minimumDeposit)}',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: onViewDetails,
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(44)),
                  child: const Text('View Details'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RateBadge extends StatelessWidget {
  const _RateBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: scheme.onSecondaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color)),
      ],
    );
  }
}
