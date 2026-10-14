import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/savings_product.dart';
import '../../providers/auth/auth_cubit.dart';
import '../../screens/create_savings/create_savings_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/login/login_screen.dart';
import '../../screens/product_details/product_details_screen.dart';
import '../../screens/products/products_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/shell/app_shell.dart';
import '../../screens/splash/splash_screen.dart';
import 'app_routes.dart';
import 'go_router_refresh_stream.dart';

class AppRouter {
  AppRouter(this._authCubit);

  final AuthCubit _authCubit;

  final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  late final GoRouter router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: GoRouterRefreshStream(_authCubit.stream),
    redirect: _guard,
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: AppRoutes.home, builder: (_, _) => const DashboardScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.products,
                builder: (_, _) => const ProductsScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (_, state) => ProductDetailsScreen(
                      productId: state.pathParameters['id']!,
                      initialProduct: state.extra is SavingsProduct
                          ? state.extra! as SavingsProduct
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: AppRoutes.profile, builder: (_, _) => const ProfileScreen())],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.createSavings,
        parentNavigatorKey: _rootKey,
        builder: (_, state) =>
            CreateSavingsScreen(initialProductId: state.uri.queryParameters['productId']),
      ),
    ],
  );

  /// Keeps unauthenticated users on the login screen and signed-in users
  /// away from it.
  String? _guard(BuildContext context, GoRouterState state) {
    final location = state.matchedLocation;
    switch (_authCubit.state.status) {
      case AuthStatus.unknown:
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      case AuthStatus.unauthenticated:
        return location == AppRoutes.login ? null : AppRoutes.login;
      case AuthStatus.authenticated:
        final onAuthPage = location == AppRoutes.login || location == AppRoutes.splash;
        return onAuthPage ? AppRoutes.home : null;
    }
  }
}
