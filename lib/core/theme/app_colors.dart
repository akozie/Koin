import 'package:flutter/material.dart';

/// Koins brand palette (deep teal + lime green).
abstract final class AppColors {
  static const teal = Color(0xFF1D4C43);
  static const tealDark = Color(0xFF12352E);
  static const tealDeep = Color(0xFF0B2420);
  static const tealLight = Color(0xFF2F6B5F);

  static const lime = Color(0xFF8DC63F);
  static const limeDark = Color(0xFF6FA52A);
  static const limeSoft = Color(0xFFE9F5D8);

  static const success = Color(0xFF2E9E5B);
  static const warning = Color(0xFFE8A33D);
  static const error = Color(0xFFD64545);

  static const surfaceLight = Color(0xFFF6F8F7);
  static const surfaceDark = Color(0xFF0F1A18);
  static const cardDark = Color(0xFF172522);

  /// Gradient used on the balance card and the login header.
  static const brandGradient = LinearGradient(
    colors: [teal, tealDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
