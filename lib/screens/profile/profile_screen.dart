import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_constants.dart';
import '../../core/di/injection.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/app_theme_mode.dart';
import '../../models/user.dart';
import '../../providers/auth/auth_cubit.dart';
import '../../providers/settings/biometric_settings_cubit.dart';
import '../../providers/theme/theme_cubit.dart';
import '../../utils/app_snackbar.dart';
import '../../widgets/responsive_center.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => BiometricSettingsCubit(getIt())..load(),
    child: const _ProfileView(),
  );
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.logout_rounded, color: Theme.of(context).colorScheme.error),
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to access your savings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      // The router redirects to the login screen once the session ends.
      await context.read<AuthCubit>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthCubit cubit) => cubit.state.user);
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ResponsiveCenter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProfileHeader(user: user),
              const SizedBox(height: AppSpacing.xl),
              const _GroupLabel('Personal information'),
              Card(
                child: Column(
                  children: [
                    _InfoTile(
                      icon: Icons.person_outline_rounded,
                      label: 'Full Name',
                      value: user.fullName,
                    ),
                    const Divider(height: 1, indent: 56),
                    _InfoTile(icon: Icons.mail_outline_rounded, label: 'Email', value: user.email),
                    const Divider(height: 1, indent: 56),
                    _InfoTile(icon: Icons.phone_outlined, label: 'Phone Number', value: user.phone),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const _GroupLabel('Appearance'),
              const Card(child: _ThemeModeTile()),
              const SizedBox(height: AppSpacing.xl),
              const _GroupLabel('Security'),
              const Card(child: _BiometricTile()),
              const SizedBox(height: AppSpacing.xl),
              OutlinedButton.icon(
                key: const Key('logout_button'),
                onPressed: () => _confirmLogout(context),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Logout'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  side: BorderSide(color: Theme.of(context).colorScheme.error),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                '${AppConstants.appName} · v1.0.0',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.xl)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.lime,
            child: Text(
              user.initials,
              style: textTheme.headlineSmall?.copyWith(color: AppColors.tealDeep),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(user.fullName, style: textTheme.titleLarge?.copyWith(color: Colors.white)),
          const SizedBox(height: AppSpacing.xxs),
          Text(user.email, style: textTheme.bodyMedium?.copyWith(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
    child: Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        letterSpacing: 0.8,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
  );
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
      subtitle: Text(value, style: theme.textTheme.bodyLarge),
    );
  }
}

class _BiometricTile extends StatelessWidget {
  const _BiometricTile();

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<BiometricSettingsCubit, BiometricSettingsState>(
        listenWhen: (prev, curr) =>
            curr.errorMessage != null && prev.errorMessage != curr.errorMessage,
        listener: (_, state) => AppSnackBar.show(state.errorMessage!, type: SnackType.error),
        builder: (context, state) => SwitchListTile(
          secondary: Icon(Icons.fingerprint_rounded, color: Theme.of(context).colorScheme.primary),
          title: const Text('Biometric login'),
          subtitle: Text(
            state.isAvailable
                ? 'Sign in with your fingerprint or face'
                : 'Not available on this device',
          ),
          value: state.isEnabled,
          onChanged: state.isAvailable
              ? (enabled) => context.read<BiometricSettingsCubit>().toggle(enabled: enabled)
              : null,
        ),
      );
}

class _ThemeModeTile extends StatelessWidget {
  const _ThemeModeTile();

  static const _icons = {
    AppThemeMode.system: Icons.brightness_auto_rounded,
    AppThemeMode.light: Icons.light_mode_rounded,
    AppThemeMode.dark: Icons.dark_mode_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<ThemeCubit>().state;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: AppSpacing.lg),
              Text('Theme', style: theme.textTheme.bodyLarge),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<AppThemeMode>(
              key: const Key('theme_mode_selector'),
              showSelectedIcon: false,
              segments: [
                for (final m in AppThemeMode.values)
                  ButtonSegment(value: m, icon: Icon(_icons[m]), label: Text(m.label)),
              ],
              selected: {mode},
              onSelectionChanged: (selection) =>
                  context.read<ThemeCubit>().setMode(selection.first),
            ),
          ),
        ],
      ),
    );
  }
}
