import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/koins_logo.dart';

/// Hosts the bottom-level tabs. Uses a [NavigationBar] on phones and a
/// [NavigationRail] on tablets / landscape.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    (icon: Icons.home_outlined, selected: Icons.home_rounded, label: 'Home'),
    (icon: Icons.savings_outlined, selected: Icons.savings_rounded, label: 'Products'),
    (icon: Icons.person_outline_rounded, selected: Icons.person_rounded, label: 'Profile'),
  ];

  void _onSelect(int index) => navigationShell.goBranch(
    index,
    // Tapping the active tab returns it to its root.
    initialLocation: index == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    // The dashboard has no AppBar, so the shell sets the system bar style.
    value: AppTheme.overlayStyleFor(Theme.of(context).brightness),
    child: _buildScaffold(context),
  );

  Widget _buildScaffold(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= Breakpoints.medium;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onSelect,
              labelType: NavigationRailLabelType.all,
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: KoinsLogo(size: 22, showWordmark: false),
              ),
              destinations: [
                for (final d in _destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selected),
                    label: Text(d.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onSelect,
        destinations: [
          for (final d in _destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selected),
              label: d.label,
            ),
        ],
      ),
    );
  }
}
