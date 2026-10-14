import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/quote.dart';
import '../../../providers/quotes/quotes_cubit.dart';
import '../../../providers/view_status.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/section_header.dart';
import '../../../widgets/skeleton.dart';
import '../../../widgets/state_views.dart';

/// "Daily Motivation" feed: the dataset retrieved from the public API.
class QuotesSection extends StatelessWidget {
  const QuotesSection({super.key});

  static const _height = 176.0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<QuotesCubit>().state;

    final Widget content = switch (state.status) {
      // Keep showing data we already have (fresh or cached) while reloading.
      _ when state.quotes.isNotEmpty => Column(
        key: const ValueKey('quotes'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.isShowingCachedData || state.status.isFailure)
            _StaleDataNote(savedAt: state.savedAt),
          SizedBox(
            height: _height,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: state.quotes.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (_, i) => _QuoteCard(quote: state.quotes[i], highlighted: i.isEven),
            ),
          ),
        ],
      ),
      ViewStatus.initial || ViewStatus.loading => SkeletonPulse(
        child: SizedBox(
          height: _height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 2,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (_, _) => const SkeletonBox(width: 280, height: _height),
          ),
        ),
      ),
      ViewStatus.failure => Card(
        child: ErrorView(
          compact: true,
          title: 'Could not load quotes',
          message: state.errorMessage ?? 'Please try again.',
          onRetry: context.read<QuotesCubit>().load,
        ),
      ),
      ViewStatus.success => const Card(
        child: EmptyView(
          compact: true,
          icon: Icons.format_quote_rounded,
          title: 'Nothing here yet',
          message: 'Check back later for fresh inspiration.',
        ),
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Daily Motivation'),
        const SizedBox(height: AppSpacing.sm),
        AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: content),
      ],
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.quote, required this.highlighted});

  final Quote quote;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = highlighted ? AppColors.limeSoft : theme.colorScheme.surface;
    final foreground = highlighted ? AppColors.tealDark : theme.colorScheme.onSurface;

    return Container(
      width: 280,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.card,
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.format_quote_rounded, color: AppColors.limeDark, size: 28),
          const SizedBox(height: AppSpacing.xs),
          Expanded(
            child: Text(
              quote.text,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(color: foreground, height: 1.4),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '— ${quote.author}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(color: foreground.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }
}

/// Tells the user they are looking at saved data rather than live data.
class _StaleDataNote extends StatelessWidget {
  const _StaleDataNote({required this.savedAt});

  final DateTime? savedAt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;
    final saved = savedAt;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(Icons.history_rounded, size: 16, color: color),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              saved == null
                  ? "Couldn't refresh. Showing the last quotes loaded."
                  : 'Showing saved quotes from ${DateFormatter.timestamp(saved)}',
              style: theme.textTheme.bodySmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
