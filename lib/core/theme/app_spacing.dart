import 'package:flutter/widgets.dart';

/// 4pt spacing scale used for every padding / gap in the app.
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Horizontal padding for top-level screen content.
  static const screen = EdgeInsets.symmetric(horizontal: lg);
}

abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;

  static const card = BorderRadius.all(Radius.circular(lg));
  static const input = BorderRadius.all(Radius.circular(md));
}

/// Material 3 window size classes.
abstract final class Breakpoints {
  static const double medium = 600;
  static const double expanded = 840;

  /// Forms and detail pages never grow wider than this.
  static const double maxContentWidth = 560;
}
