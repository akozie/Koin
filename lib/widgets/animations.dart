import 'package:flutter/material.dart';

import '../utils/formatters.dart';

/// Fades and slides its child in, staggered by [index].
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({super.key, required this.child, this.index = 0});

  final Widget child;
  final int index;

  static const _base = Duration(milliseconds: 380);
  static const _step = Duration(milliseconds: 70);

  @override
  Widget build(BuildContext context) {
    final delay = _step * index.clamp(0, 8);
    final total = _base + delay;
    final start = delay.inMilliseconds / total.inMilliseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: Interval(start, 1, curve: Curves.easeOutCubic),
      builder: (_, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(offset: Offset(0, 16 * (1 - value)), child: child),
      ),
      child: child,
    );
  }
}

/// Counts up to [amount] when first shown or when the amount changes.
class AnimatedAmount extends StatelessWidget {
  const AnimatedAmount({super.key, required this.amount, this.style, this.hidden = false});

  final int amount;
  final TextStyle? style;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    if (hidden) {
      return Text('₦ • • • • • •', style: style, semanticsLabel: 'Balance hidden');
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(end: amount.toDouble()),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutCubic,
      builder: (_, value, _) => Text(
        CurrencyFormatter.format(value.round()),
        style: style,
        semanticsLabel: CurrencyFormatter.format(amount),
      ),
    );
  }
}
