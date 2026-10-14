import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';

/// Centers content and caps its width on tablets / landscape.
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = Breakpoints.maxContentWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Center(
    // Size to the child vertically so it also works in unbounded slots
    // such as `Scaffold.bottomNavigationBar`.
    heightFactor: 1,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}
