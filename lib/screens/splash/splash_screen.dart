import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/koins_logo.dart';

/// Shown only while the session is being restored.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: AppColors.teal,
    body: Center(child: KoinsLogo(size: 44, wordmarkColor: Colors.white, showSubtitle: true)),
  );
}
