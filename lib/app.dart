import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'models/app_theme_mode.dart';
import 'providers/auth/auth_cubit.dart';
import 'providers/connectivity/connectivity_cubit.dart';
import 'providers/theme/theme_cubit.dart';
import 'utils/app_snackbar.dart';
import 'widgets/connectivity_banner.dart';

class KoinsApp extends StatefulWidget {
  const KoinsApp({
    super.key,
    required this.authCubit,
    required this.themeCubit,
    required this.connectivityCubit,
  });

  final AuthCubit authCubit;
  final ThemeCubit themeCubit;
  final ConnectivityCubit connectivityCubit;

  @override
  State<KoinsApp> createState() => _KoinsAppState();
}

class _KoinsAppState extends State<KoinsApp> {
  late final _appRouter = AppRouter(widget.authCubit);

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider.value(value: widget.authCubit),
      BlocProvider.value(value: widget.themeCubit),
      BlocProvider.value(value: widget.connectivityCubit),
    ],
    child: BlocBuilder<ThemeCubit, AppThemeMode>(
      builder: (context, mode) => MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: mode.toThemeMode(),
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        routerConfig: _appRouter.router,
        builder: (_, child) => ConnectivityBanner(child: child!),
      ),
    ),
  );
}

extension on AppThemeMode {
  ThemeMode toThemeMode() => switch (this) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };
}
