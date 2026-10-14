import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_spacing.dart';

/// Text field with its label rendered above the input.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.prefixIcon,
    this.prefixText,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.obscureText = false,
    this.inputFormatters,
    this.autofillHints,
    this.onFieldSubmitted,
    this.onChanged,
    this.focusNode,
    this.enabled = true,
    this.textCapitalization = TextCapitalization.none,
    this.helperText,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final IconData? prefixIcon;
  final String? prefixText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final bool enabled;
  final TextCapitalization textCapitalization;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          obscureText: obscureText,
          inputFormatters: inputFormatters,
          autofillHints: autofillHints,
          onFieldSubmitted: onFieldSubmitted,
          onChanged: onChanged,
          textCapitalization: textCapitalization,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            prefixText: prefixText,
            prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
