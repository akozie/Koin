import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/savings_plan.dart';
import '../../models/savings_product.dart';
import '../../providers/connectivity/connectivity_cubit.dart';
import '../../providers/create_savings/create_savings_cubit.dart';
import '../../providers/view_status.dart';
import '../../repositories/savings_repository.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/currency_input_formatter.dart';
import '../../utils/formatters.dart';
import '../../utils/savings_calculator.dart';
import '../../utils/validators.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/product_visuals.dart';
import '../../widgets/responsive_center.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/state_views.dart';

class CreateSavingsScreen extends StatelessWidget {
  const CreateSavingsScreen({super.key, this.initialProductId});

  final String? initialProductId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        CreateSavingsCubit(productRepository: getIt(), savingsRepository: getIt())
          ..init(initialProductId: initialProductId),
    child: const _CreateSavingsView(),
  );
}

class _CreateSavingsView extends StatelessWidget {
  const _CreateSavingsView();

  @override
  Widget build(BuildContext context) => BlocListener<CreateSavingsCubit, CreateSavingsState>(
    listenWhen: (prev, curr) => prev.submitStatus != curr.submitStatus,
    listener: (context, state) {
      switch (state.submitStatus) {
        case SubmitStatus.success:
          AppSnackBar.show('Savings Created Successfully', type: SnackType.success);
          context.go(AppRoutes.home);
        case SubmitStatus.failure:
          AppSnackBar.show(
            state.errorMessage ?? 'Could not create savings plan.',
            type: SnackType.error,
          );
        case SubmitStatus.idle || SubmitStatus.submitting:
          break;
      }
    },
    child: Scaffold(
      appBar: AppBar(title: const Text('Create Savings')),
      body: BlocBuilder<CreateSavingsCubit, CreateSavingsState>(
        buildWhen: (prev, curr) =>
            prev.productsStatus != curr.productsStatus || prev.errorMessage != curr.errorMessage,
        builder: (context, state) => switch (state.productsStatus) {
          ViewStatus.initial || ViewStatus.loading => const _FormSkeleton(),
          ViewStatus.failure => ErrorView(
            message: state.errorMessage ?? 'Could not load products.',
            onRetry: context.read<CreateSavingsCubit>().init,
          ),
          ViewStatus.success => _CreateSavingsForm(
            products: state.products,
            initialProduct: state.selectedProduct,
          ),
        },
      ),
    ),
  );
}

class _CreateSavingsForm extends StatefulWidget {
  const _CreateSavingsForm({required this.products, this.initialProduct});

  final List<SavingsProduct> products;
  final SavingsProduct? initialProduct;

  @override
  State<_CreateSavingsForm> createState() => _CreateSavingsFormState();
}

class _CreateSavingsFormState extends State<_CreateSavingsForm> {
  static const _flexibleDurations = [3, 6, 9, 12, 18, 24];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _contributionController = TextEditingController();

  SavingsProduct? _product;
  int? _durationMonths;

  @override
  void initState() {
    super.initState();
    _selectProduct(widget.initialProduct, notify: false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _contributionController.dispose();
    super.dispose();
  }

  void _selectProduct(SavingsProduct? product, {bool notify = true}) {
    _product = product;
    // Fixed-tenor products dictate the duration; flexible ones let the user pick.
    if (product?.durationMonths != null) {
      _durationMonths = product!.durationMonths;
    } else if (!_flexibleDurations.contains(_durationMonths)) {
      _durationMonths = null;
    }
    if (notify) {
      setState(() {});
      context.read<CreateSavingsCubit>().selectProduct(product);
    }
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<CreateSavingsCubit>().submit(
      CreateSavingsRequest(
        name: _nameController.text,
        productId: _product!.id,
        targetAmount: CurrencyFormatter.parse(_targetController.text)!,
        monthlyContribution: CurrencyFormatter.parse(_contributionController.text)!,
        durationMonths: _durationMonths!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.select(
      (CreateSavingsCubit cubit) => cubit.state.submitStatus.isSubmitting,
    );
    final isOffline = context.select((ConnectivityCubit cubit) => cubit.state.isOffline);
    final product = _product;
    final durations = product?.durationMonths != null
        ? [product!.durationMonths!]
        : _flexibleDurations;

    return SingleChildScrollView(
      // Keep the Create button clear of the system navigation bar.
      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ).add(EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom)),
      child: ResponsiveCenter(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                key: const Key('savings_name'),
                label: 'Savings Name',
                hint: 'e.g. New Car Fund',
                controller: _nameController,
                prefixIcon: Icons.edit_note_rounded,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                enabled: !isSubmitting,
                validator: (v) => Validators.required(v, field: 'Savings name'),
              ),
              const SizedBox(height: AppSpacing.lg),
              _LabeledDropdown<SavingsProduct>(
                fieldKey: const Key('product_type'),
                label: 'Product Type',
                hint: 'Select a savings product',
                icon: Icons.category_outlined,
                initialValue: product,
                enabled: !isSubmitting,
                items: [
                  for (final p in widget.products)
                    DropdownMenuItem(
                      value: p,
                      child: Row(
                        children: [
                          Icon(p.category.icon, size: 20, color: p.category.color),
                          const SizedBox(width: AppSpacing.sm),
                          Flexible(
                            child: Text(
                              '${p.name} · ${p.interestLabel}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
                onChanged: _selectProduct,
                validator: (v) => v == null ? 'Product type is required' : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                key: const Key('target_amount'),
                label: 'Target Amount',
                hint: '0',
                prefixText: '₦ ',
                controller: _targetController,
                prefixIcon: Icons.flag_outlined,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: const [CurrencyInputFormatter()],
                enabled: !isSubmitting,
                validator: (v) =>
                    Validators.amount(v, field: 'Target amount', min: product?.minimumDeposit),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                key: const Key('monthly_contribution'),
                label: 'Monthly Contribution',
                hint: '0',
                prefixText: '₦ ',
                controller: _contributionController,
                prefixIcon: Icons.calendar_month_outlined,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: const [CurrencyInputFormatter()],
                enabled: !isSubmitting,
                helperText: product == null
                    ? null
                    : 'Minimum ${CurrencyFormatter.format(product.minimumDeposit)}',
                validator: (v) => Validators.amount(
                  v,
                  field: 'Monthly contribution',
                  min: product?.minimumDeposit,
                  max: CurrencyFormatter.parse(_targetController.text),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _LabeledDropdown<int>(
                // Rebuild when the product changes so the selection resets.
                key: ValueKey('duration_${product?.id}'),
                fieldKey: const Key('duration'),
                label: 'Duration',
                hint: 'Select duration',
                icon: Icons.schedule_rounded,
                initialValue: _durationMonths,
                enabled: !isSubmitting && (product == null || product.isFlexible),
                helperText: product != null && !product.isFlexible
                    ? 'Fixed at ${product.durationLabel.toLowerCase()} for ${product.name}'
                    : null,
                items: [
                  for (final months in durations)
                    DropdownMenuItem(value: months, child: Text('$months Months')),
                ],
                onChanged: (value) => setState(() => _durationMonths = value),
                validator: (v) => v == null ? 'Duration is required' : null,
              ),
              const SizedBox(height: AppSpacing.xl),
              ListenableBuilder(
                listenable: _contributionController,
                builder: (_, _) => _ProjectionCard(
                  product: product,
                  contribution: CurrencyFormatter.parse(_contributionController.text),
                  months: _durationMonths,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Creating a plan moves money, so it needs a live connection.
              if (isOffline) ...[const _OfflineNotice(), const SizedBox(height: AppSpacing.md)],
              AppButton(
                key: const Key('create_button'),
                label: 'Create',
                isLoading: isSubmitting,
                onPressed: isOffline ? null : _submit,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _LabeledDropdown<T> extends StatelessWidget {
  const _LabeledDropdown({
    super.key,
    required this.fieldKey,
    required this.label,
    required this.hint,
    required this.icon,
    required this.items,
    required this.onChanged,
    required this.validator,
    this.initialValue,
    this.enabled = true,
    this.helperText,
  });

  final Key fieldKey;
  final String label;
  final String hint;
  final IconData icon;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final FormFieldValidator<T> validator;
  final T? initialValue;
  final bool enabled;
  final String? helperText;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.labelLarge),
      const SizedBox(height: AppSpacing.sm),
      DropdownButtonFormField<T>(
        key: fieldKey,
        initialValue: initialValue,
        items: items,
        isExpanded: true,
        onChanged: enabled ? onChanged : null,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        borderRadius: AppRadius.input,
        decoration: InputDecoration(hintText: hint, helperText: helperText, prefixIcon: Icon(icon)),
      ),
    ],
  );
}

/// Live estimate of contributions and interest for the entered values.
class _ProjectionCard extends StatelessWidget {
  const _ProjectionCard({required this.product, required this.contribution, required this.months});

  final SavingsProduct? product;
  final int? contribution;
  final int? months;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ready = product != null && (contribution ?? 0) > 0 && months != null;
    final onContainer = theme.colorScheme.onSecondaryContainer;

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: !ready
          ? const SizedBox(width: double.infinity)
          : Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.6),
                borderRadius: AppRadius.card,
              ),
              child: Builder(
                builder: (context) {
                  final saved = SavingsCalculator.totalContributions(
                    monthlyContribution: contribution!,
                    months: months!,
                  );
                  final interest = SavingsCalculator.projectedInterest(
                    monthlyContribution: contribution!,
                    annualRatePercent: product!.interestRate,
                    months: months!,
                  );
                  TextStyle? style(FontWeight w) =>
                      theme.textTheme.bodyMedium?.copyWith(color: onContainer, fontWeight: w);
                  Widget row(String label, String value, {bool bold = false}) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    child: Row(
                      children: [
                        Expanded(child: Text(label, style: style(FontWeight.w400))),
                        Text(value, style: style(bold ? FontWeight.w700 : FontWeight.w600)),
                      ],
                    ),
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estimated returns',
                        style: theme.textTheme.titleSmall?.copyWith(color: onContainer),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      row('Total contributions', CurrencyFormatter.format(saved)),
                      row(
                        'Interest (${product!.interestLabel} p.a.)',
                        CurrencyFormatter.format(interest),
                      ),
                      const Divider(),
                      row('At maturity', CurrencyFormatter.format(saved + interest), bold: true),
                    ],
                  );
                },
              ),
            ),
    );
  }
}

class _OfflineNotice extends StatelessWidget {
  const _OfflineNotice();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: const Key('create_offline_notice'),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.6),
        borderRadius: AppRadius.input,
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, color: scheme.onErrorContainer),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              SavingsRepositoryImpl.offlineCreateMessage,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mirrors the form layout while products load.
class _FormSkeleton extends StatelessWidget {
  const _FormSkeleton();

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.all(AppSpacing.lg),
    child: ResponsiveCenter(
      child: SkeletonPulse(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < 5; i++) ...[
              const SkeletonBox(width: 120, height: 14, radius: 4),
              const SizedBox(height: AppSpacing.sm),
              const SkeletonBox(height: 56, radius: AppRadius.md),
              const SizedBox(height: AppSpacing.lg),
            ],
            const SizedBox(height: AppSpacing.md),
            const SkeletonBox(height: 52, radius: AppRadius.md),
          ],
        ),
      ),
    ),
  );
}
