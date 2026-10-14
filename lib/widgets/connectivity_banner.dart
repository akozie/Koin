import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/app_spacing.dart';
import '../core/theme/app_theme.dart';
import '../providers/connectivity/connectivity_cubit.dart';

/// App-wide "No internet connection" strip shown above every screen.
///
/// The child is always the same widget instance (only its [MediaQuery] padding
/// changes) so the navigator and screen state survive the banner toggling.
class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final offline = context.select((ConnectivityCubit c) => c.state.isOffline);
    final mediaQuery = MediaQuery.of(context);

    // App-wide default system bar style; screens and the banner override
    // it for the areas they cover.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyleFor(Theme.of(context).brightness),
      child: Column(
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: offline ? const _Banner() : const SizedBox(width: double.infinity),
          ),
          Expanded(
            child: MediaQuery(
              // The banner already covers the status bar area.
              data: offline
                  ? mediaQuery.copyWith(
                      padding: mediaQuery.padding.copyWith(top: 0),
                      viewPadding: mediaQuery.viewPadding.copyWith(top: 0),
                    )
                  : mediaQuery,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner();

  static const _background = Color(0xFF3A3F3E);

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: AppTheme.overlayStyleFor(Brightness.dark),
    child: Material(
      color: _background,
      child: SafeArea(
        bottom: false,
        child: Semantics(
          liveRegion: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'No internet connection',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
