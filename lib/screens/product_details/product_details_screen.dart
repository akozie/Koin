import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/savings_product.dart';
import '../../providers/product_details/product_details_cubit.dart';
import '../../providers/view_status.dart';
import '../../utils/formatters.dart';
import '../../utils/savings_calculator.dart';
import '../../widgets/animations.dart';
import '../../widgets/app_button.dart';
import '../../widgets/product_visuals.dart';
import '../../widgets/responsive_center.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/state_views.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key, required this.productId, this.initialProduct});

  final String productId;
  final SavingsProduct? initialProduct;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) {
      final cubit = ProductDetailsCubit(getIt(), initial: initialProduct);
      if (initialProduct == null) cubit.load(productId);
      return cubit;
    },
    child: _ProductDetailsView(productId: productId),
  );
}

class _ProductDetailsView extends StatelessWidget {
  const _ProductDetailsView({required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ProductDetailsCubit>().state;
    final product = state.product;

    return Scaffold(
      appBar: AppBar(title: Text(product?.name ?? 'Savings Details')),
      body: switch (state.status) {
        ViewStatus.initial || ViewStatus.loading => const _DetailsSkeleton(),
        ViewStatus.failure => ErrorView(
          message: state.errorMessage ?? 'Could not load this product.',
          onRetry: () => context.read<ProductDetailsCubit>().load(productId),
        ),
        ViewStatus.success => _Details(product: product!),
      },
      bottomNavigationBar: product == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: ResponsiveCenter(
                  child: AppButton(
                    key: const Key('create_savings_button'),
                    label: 'Create Savings',
                    icon: Icons.add_rounded,
                    onPressed: () => context.push(AppRoutes.createSavingsFor(product.id)),
                  ),
                ),
              ),
            ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.product});

  final SavingsProduct product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: ResponsiveCenter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Hero(
                  tag: 'product-icon-${product.id}',
                  child: CategoryIcon(category: product.category, size: 64),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: theme.textTheme.headlineSmall),
                      const SizedBox(height: AppSpacing.xs),
                      Text(product.description, style: muted),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            FadeSlideIn(
              child: Card(
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.label_outline_rounded,
                      label: 'Plan Name',
                      value: product.name,
                    ),
                    const Divider(height: 1),
                    _DetailRow(
                      icon: Icons.trending_up_rounded,
                      label: 'Interest Rate',
                      value: '${product.interestLabel} per annum',
                    ),
                    const Divider(height: 1),
                    _DetailRow(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Minimum Deposit',
                      value: CurrencyFormatter.format(product.minimumDeposit),
                    ),
                    const Divider(height: 1),
                    _DetailRow(
                      icon: Icons.schedule_rounded,
                      label: 'Duration',
                      value: product.durationLabel,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FadeSlideIn(index: 1, child: _ReturnsExample(product: product)),
            if (product.features.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              Text('Why you will love it', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              for (final (index, feature) in product.features.indexed)
                FadeSlideIn(
                  index: index + 2,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 20,
                          color: theme.colorScheme.secondary,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: Text(feature, style: theme.textTheme.bodyMedium)),
                      ],
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md + 2),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(value, style: theme.textTheme.titleSmall),
        ],
      ),
    );
  }
}

/// Illustrates what saving the minimum deposit every month would earn.
class _ReturnsExample extends StatelessWidget {
  const _ReturnsExample({required this.product});

  final SavingsProduct product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final months = product.durationMonths ?? 12;
    final interest = SavingsCalculator.projectedInterest(
      monthlyContribution: product.minimumDeposit,
      annualRatePercent: product.interestRate,
      months: months,
    );
    final contributions = SavingsCalculator.totalContributions(
      monthlyContribution: product.minimumDeposit,
      months: months,
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.6),
        borderRadius: AppRadius.card,
      ),
      child: Row(
        children: [
          Icon(Icons.auto_graph_rounded, color: theme.colorScheme.onSecondaryContainer),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                ),
                children: [
                  TextSpan(
                    text: 'Save ${CurrencyFormatter.format(product.minimumDeposit)} monthly ',
                  ),
                  TextSpan(text: 'for $months months and earn about '),
                  TextSpan(
                    text: CurrencyFormatter.format(interest),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text:
                        ' in interest on '
                        '${CurrencyFormatter.format(contributions)} saved.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mirrors the details layout while a deep-linked product loads.
class _DetailsSkeleton extends StatelessWidget {
  const _DetailsSkeleton();

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.all(AppSpacing.lg),
    child: ResponsiveCenter(
      child: SkeletonPulse(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                SkeletonBox(width: 64, height: 64, radius: 20),
                SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 180, height: 22, radius: 6),
                      SizedBox(height: AppSpacing.sm),
                      SkeletonBox(height: 14, radius: 4),
                      SizedBox(height: AppSpacing.xs),
                      SkeletonBox(width: 140, height: 14, radius: 4),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            const SkeletonBox(height: 220, radius: AppRadius.lg),
            const SizedBox(height: AppSpacing.lg),
            const SkeletonBox(height: 90, radius: AppRadius.lg),
            const SizedBox(height: AppSpacing.xl),
            for (var i = 0; i < 3; i++) ...[
              const SkeletonBox(width: 240, height: 16, radius: 4),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
    ),
  );
}
