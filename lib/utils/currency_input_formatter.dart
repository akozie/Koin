import 'package:flutter/services.dart';

import 'formatters.dart';

/// Formats a numeric text field with thousands separators as the user types
/// (`1500000` → `1,500,000`).
class CurrencyInputFormatter extends TextInputFormatter {
  const CurrencyInputFormatter({this.maxDigits = 12});

  final int maxDigits;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue();
    if (digits.length > maxDigits) return oldValue;

    final formatted = CurrencyFormatter.grouped(int.parse(digits));
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
