import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injection.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/login/login_cubit.dart';
import '../../providers/view_status.dart';
import '../../services/auth_service.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/validators.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/koins_logo.dart';
import '../../widgets/responsive_center.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => LoginCubit(getIt())..checkBiometrics(),
    child: const _LoginView(),
  );
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= Breakpoints.expanded;

    return BlocListener<LoginCubit, LoginState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == SubmitStatus.failure && state.errorMessage != null) {
          AppSnackBar.show(state.errorMessage!, type: SnackType.error);
        }
        // On success the router redirects to the dashboard automatically.
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        // Light status bar icons over the teal header; navigation bar icons
        // follow the form sheet, which uses the theme's background.
        value: AppTheme.overlayStyleFor(Brightness.dark).copyWith(
          systemNavigationBarIconBrightness: Theme.of(context).brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: AppColors.teal,
          body: isWide
              ? const Row(
                  children: [
                    Expanded(child: _BrandPanel(expanded: true)),
                    Expanded(child: _FormSheet(rounded: false)),
                  ],
                )
              : const CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _BrandPanel(expanded: false)),
                    SliverFillRemaining(hasScrollBody: false, child: _FormSheet(rounded: true)),
                  ],
                ),
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel({required this.expanded});

  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.brandGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xl,
            expanded ? AppSpacing.xxxl : AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: expanded ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              const KoinsLogo(size: 30, wordmarkColor: Colors.white, showSubtitle: true),
              SizedBox(height: expanded ? AppSpacing.xxxl : AppSpacing.xxl),
              Text('Welcome back', style: textTheme.headlineSmall?.copyWith(color: Colors.white)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Sign in to grow your savings with Koins.',
                style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormSheet extends StatelessWidget {
  const _FormSheet({required this.rounded});

  final bool rounded;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).scaffoldBackgroundColor,
      borderRadius: rounded
          ? const BorderRadius.vertical(top: Radius.circular(AppRadius.xl + 4))
          : null,
    ),
    child: const SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: ResponsiveCenter(maxWidth: 440, child: _LoginForm()),
      ),
    ),
  );
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<LoginCubit>().login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  void _fillDemoCredentials() {
    _emailController.text = MockAuthService.demoEmail;
    _passwordController.text = MockAuthService.demoPassword;
    _formKey.currentState?.validate();
  }

  void _comingSoon(String feature) =>
      AppSnackBar.show('$feature is coming soon.', type: SnackType.info);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<LoginCubit>().state;
    final isSubmitting = state.status.isSubmitting;

    return AutofillGroup(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Login', style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              key: const Key('login_email'),
              label: 'Email Address',
              hint: 'you@example.com',
              controller: _emailController,
              prefixIcon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: Validators.email,
              enabled: !isSubmitting,
              onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              key: const Key('login_password'),
              label: 'Password',
              hint: 'Enter your password',
              controller: _passwordController,
              focusNode: _passwordFocus,
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              validator: Validators.password,
              enabled: !isSubmitting,
              onFieldSubmitted: (_) => _submit(),
              suffix: IconButton(
                tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _comingSoon('Password reset'),
                child: const Text('Forgot Password?'),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    key: const Key('login_button'),
                    label: 'Login',
                    isLoading: isSubmitting,
                    onPressed: _submit,
                  ),
                ),
                if (state.canUseBiometrics) ...[
                  const SizedBox(width: AppSpacing.md),
                  SizedBox.square(
                    dimension: 52,
                    child: IconButton.outlined(
                      tooltip: 'Login with biometrics',
                      onPressed: isSubmitting
                          ? null
                          : context.read<LoginCubit>().loginWithBiometrics,
                      icon: const Icon(Icons.fingerprint_rounded, size: 28),
                      style: IconButton.styleFrom(
                        shape: const RoundedRectangleBorder(borderRadius: AppRadius.input),
                        side: BorderSide(color: theme.colorScheme.primary),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text("Don't have an account?", style: theme.textTheme.bodyMedium),
                TextButton(
                  onPressed: () => _comingSoon('Registration'),
                  child: const Text('Register'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _DemoCredentialsHint(onTap: isSubmitting ? null : _fillDemoCredentials),
          ],
        ),
      ),
    );
  }
}

/// Helps reviewers sign in quickly with the mock credentials.
class _DemoCredentialsHint extends StatelessWidget {
  const _DemoCredentialsHint({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.6),
      borderRadius: AppRadius.input,
      child: InkWell(
        borderRadius: AppRadius.input,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: theme.colorScheme.onSecondaryContainer),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Demo: ${MockAuthService.demoEmail} / ${MockAuthService.demoPassword}\n'
                  'Tap to fill',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
