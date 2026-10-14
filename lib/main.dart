import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth/auth_cubit.dart';
import 'providers/connectivity/connectivity_cubit.dart';
import 'providers/theme/theme_cubit.dart';
import 'widgets/state_views.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _registerErrorHandlers();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleFor(Brightness.light));

  await configureDependencies();

  // Restore the persisted session before the first frame so the router
  // opens directly on the right screen (login or dashboard).
  final authCubit = AuthCubit(getIt());
  await authCubit.checkSession();

  runApp(
    KoinsApp(
      authCubit: authCubit,
      themeCubit: ThemeCubit(getIt()),
      connectivityCubit: ConnectivityCubit(getIt()),
    ),
  );
}

/// Last line of defence for unexpected exceptions. In production these
/// would be forwarded to Crashlytics / Sentry.
void _registerErrorHandlers() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    developer.log('Flutter error', error: details.exception, stackTrace: details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    developer.log('Uncaught error', error: error, stackTrace: stack);
    return true;
  };

  // Replace the red error screen with a friendly message in release builds.
  if (kReleaseMode) {
    ErrorWidget.builder = (_) =>
        const Material(child: ErrorView(message: 'This section could not be displayed.'));
  }
}
