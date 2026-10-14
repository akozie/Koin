import 'package:flutter/material.dart';

/// Root messenger: snack bars shown here survive route changes (e.g. the
/// success message after creating a plan stays visible on the dashboard).
final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

enum SnackType { success, error, info }

abstract final class AppSnackBar {
  static void show(String message, {SnackType type = SnackType.info}) {
    final messenger = rootScaffoldMessengerKey.currentState;
    if (messenger == null) return;
    final (icon, color) = switch (type) {
      SnackType.success => (Icons.check_circle_rounded, const Color(0xFF2E9E5B)),
      SnackType.error => (Icons.error_rounded, const Color(0xFFD64545)),
      SnackType.info => (Icons.info_rounded, const Color(0xFF1D4C43)),
    };
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: color,
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }
}
