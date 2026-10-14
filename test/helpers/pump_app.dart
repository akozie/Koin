import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:koins/core/network/network_info.dart';
import 'package:koins/core/theme/app_theme.dart';
import 'package:koins/providers/connectivity/connectivity_cubit.dart';
import 'package:koins/utils/app_snackbar.dart';

import 'mocks.dart';

extension PumpApp on WidgetTester {
  /// Pumps [screen] inside a minimal router so `context.go/push` work, with
  /// the app-wide [ConnectivityCubit] available (online unless [networkInfo]
  /// says otherwise).
  Future<void> pumpScreen(Widget screen, {NetworkInfo? networkInfo}) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => screen),
        GoRoute(
          path: '/home',
          builder: (_, _) => const Scaffold(body: Text('Home')),
        ),
      ],
    );
    await pumpWidget(
      BlocProvider(
        create: (_) => ConnectivityCubit(networkInfo ?? FakeNetworkInfo()),
        child: MaterialApp.router(
          theme: AppTheme.light,
          scaffoldMessengerKey: rootScaffoldMessengerKey,
          routerConfig: router,
        ),
      ),
    );
    await pump();
  }
}
