import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        if (message != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(message!, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ],
    ),
  );
}

/// Shared layout for empty and error states.
class _StatusView extends StatelessWidget {
  const _StatusView({
    required this.icon,
    required this.title,
    required this.message,
    required this.iconColor,
    this.action,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color iconColor;
  final Widget? action;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? AppSpacing.lg : AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.lg),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: compact ? 28 : 40, color: iconColor),
            ),
            SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
            Text(title, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (action != null) ...[
              SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_rounded,
    this.action,
    this.compact = false,
  });

  final String title;
  final String message;
  final IconData icon;
  final Widget? action;
  final bool compact;

  @override
  Widget build(BuildContext context) => _StatusView(
    icon: icon,
    title: title,
    message: message,
    iconColor: Theme.of(context).colorScheme.primary,
    action: action,
    compact: compact,
  );
}

class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.title = 'Something went wrong',
    this.compact = false,
  });

  final String message;
  final String title;
  final VoidCallback? onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isOffline = message.toLowerCase().contains('internet');
    return _StatusView(
      icon: isOffline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
      title: isOffline ? 'You are offline' : title,
      message: message,
      iconColor: Theme.of(context).colorScheme.error,
      compact: compact,
      action: onRetry == null
          ? null
          : OutlinedButton.icon(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(minimumSize: const Size(140, 44)),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
    );
  }
}
