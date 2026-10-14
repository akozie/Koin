import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Koins brand mark (chevron + coin) with an optional wordmark.
class KoinsLogo extends StatelessWidget {
  const KoinsLogo({
    super.key,
    this.size = 36,
    this.showWordmark = true,
    this.wordmarkColor,
    this.showSubtitle = false,
  });

  final double size;
  final bool showWordmark;
  final Color? wordmarkColor;
  final bool showSubtitle;

  @override
  Widget build(BuildContext context) {
    final color = wordmarkColor ?? Theme.of(context).colorScheme.onSurface;
    final mark = Semantics(
      label: 'Koins logo',
      child: CustomPaint(size: Size(size * 1.9, size), painter: const _MarkPainter()),
    );
    if (!showWordmark) return mark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(width: size * 0.3),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Koins',
              style: TextStyle(
                fontSize: size,
                height: 1,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: -0.5,
              ),
            ),
            if (showSubtitle)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'MICROFINANCE BANK',
                  style: TextStyle(
                    fontSize: size * 0.26,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w500,
                    color: color.withValues(alpha: 0.85),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final paint = Paint()..color = AppColors.lime;
    final chevron = Path()
      ..moveTo(0.42 * h, 0)
      ..lineTo(0.74 * h, 0)
      ..lineTo(0.32 * h, 0.5 * h)
      ..lineTo(0.74 * h, h)
      ..lineTo(0.42 * h, h)
      ..lineTo(0, 0.5 * h)
      ..close();
    canvas
      ..drawPath(chevron, paint)
      ..drawCircle(Offset(1.36 * h, 0.5 * h), 0.38 * h, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
