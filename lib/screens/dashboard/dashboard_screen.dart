import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/auth/auth_cubit.dart';
import '../../providers/dashboard/dashboard_cubit.dart';
import '../../providers/quotes/quotes_cubit.dart';
import '../../providers/view_status.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/greeting.dart';
import '../../widgets/animations.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/quick_action_button.dart';
import '../../widgets/reconnect_listener.dart';
import '../../widgets/responsive_center.dart';
import '../../widgets/savings_plan_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/state_views.dart';
import 'widgets/quotes_section.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => DashboardCubit(getIt())..load()),
      BlocProvider(create: (_) => QuotesCubit(getIt())..load()),
    ],
    child: const _DashboardView(),
  );
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  Future<void> _refresh(BuildContext context) =>
      Future.wait([context.read<DashboardCubit>().load(), context.read<QuotesCubit>().load()]);

  @override
  Widget build(BuildContext context) => ReconnectListener(
    onReconnect: () => _refresh(context),
    child: Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => _refresh(context),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                sliver: SliverToBoxAdapter(
                  child: ResponsiveCenter(
                    maxWidth: 720,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _Header(),
                        const SizedBox(height: AppSpacing.xl),
                        const FadeSlideIn(child: _Balance()),
                        const SizedBox(height: AppSpacing.lg),
                        const FadeSlideIn(index: 1, child: _QuickActions()),
                        const SizedBox(height: AppSpacing.xl),
                        SectionHeader(
                          title: 'Recent Savings',
                          actionLabel: 'New plan',
                          onAction: () => context.push(AppRoutes.createSavings),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const _RecentSavings(),
                        const SizedBox(height: AppSpacing.xl),
                        const QuotesSection(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.select((AuthCubit cubit) => cubit.state.user);
    final name = user?.fullName ?? 'there';

    return Row(
      children: [
        GestureDetector(
          onTap: () => context.go(AppRoutes.profile),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.primary,
            child: Text(
              user?.initials ?? '?',
              style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${Greeting.forTime(DateTime.now())},',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                name,
                style: theme.textTheme.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Notifications',
          onPressed: () => AppSnackBar.show('You have no new notifications.'),
          icon: const Icon(Icons.notifications_none_rounded),
        ),
      ],
    );
  }
}

class _Balance extends StatelessWidget {
  const _Balance();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DashboardCubit>().state;
    if (state.status == ViewStatus.initial || (state.status.isLoading && state.plans.isEmpty)) {
      return const SkeletonPulse(child: SkeletonBox(height: 168, radius: AppRadius.xl));
    }
    return BalanceCard(
      totalSavings: state.totalSavings,
      activePlans: state.plans.length,
      isBalanceVisible: state.isBalanceVisible,
      onToggleVisibility: context.read<DashboardCubit>().toggleBalanceVisibility,
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: QuickActionButton(
          icon: Icons.add_circle_outline_rounded,
          label: 'Create Savings',
          onTap: () => context.push(AppRoutes.createSavings),
        ),
      ),
      const SizedBox(width: AppSpacing.md),
      Expanded(
        child: QuickActionButton(
          icon: Icons.grid_view_rounded,
          label: 'View Products',
          onTap: () => context.go(AppRoutes.products),
        ),
      ),
    ],
  );
}

class _RecentSavings extends StatelessWidget {
  const _RecentSavings();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DashboardCubit>().state;

    if (state.status.isFailure && state.plans.isEmpty) {
      return Card(
        child: ErrorView(
          compact: true,
          message: state.errorMessage ?? 'Could not load your savings.',
          onRetry: context.read<DashboardCubit>().load,
        ),
      );
    }

    if (state.status == ViewStatus.initial || (state.status.isLoading && state.plans.isEmpty)) {
      return SkeletonPulse(
        child: Column(
          children: [
            for (var i = 0; i < DashboardState.recentLimit; i++)
              const Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: SkeletonBox(height: 104, radius: AppRadius.lg),
              ),
          ],
        ),
      );
    }

    if (state.plans.isEmpty) {
      return Card(
        child: EmptyView(
          compact: true,
          icon: Icons.savings_outlined,
          title: 'No savings yet',
          message: 'Create your first savings plan to start growing your money.',
          action: FilledButton.tonal(
            onPressed: () => context.push(AppRoutes.createSavings),
            child: const Text('Create Savings'),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final (index, plan) in state.recentPlans.indexed)
          Padding(
            // Keyed on the outermost widget so existing cards keep their
            // state (and don't re-animate) when a new plan is prepended.
            key: ValueKey(plan.id),
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: FadeSlideIn(
              index: index + 2,
              child: SavingsPlanCard(plan: plan),
            ),
          ),
      ],
    );
  }
}
