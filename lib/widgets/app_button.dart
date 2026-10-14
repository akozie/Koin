import 'package:flutter/material.dart';

/// Primary call-to-action with a built-in loading state.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final child = AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isLoading
          ? SizedBox.square(
              key: const ValueKey('loading'),
              dimension: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: scheme.onPrimary),
            )
          : Row(
              key: const ValueKey('label'),
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
                Text(label),
              ],
            ),
    );

    return Semantics(
      button: true,
      label: isLoading ? '$label, loading' : label,
      excludeSemantics: true,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: isLoading
            ? FilledButton.styleFrom(disabledBackgroundColor: scheme.primary.withValues(alpha: 0.8))
            : null,
        child: child,
      ),
    );
  }
}
