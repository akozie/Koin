import 'formatters.dart';

/// Form field validators. Each returns an error message or `null` if valid.
abstract final class Validators {
  static final _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)*\.[a-zA-Z]{2,}$');

  static const passwordMinLength = 8;

  static String? email(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Email address is required';
    if (!_emailPattern.hasMatch(input)) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    final input = value ?? '';
    if (input.isEmpty) return 'Password is required';
    if (input.length < passwordMinLength) {
      return 'Password must be at least $passwordMinLength characters';
    }
    return null;
  }

  static String? required(String? value, {required String field}) =>
      (value?.trim() ?? '').isEmpty ? '$field is required' : null;

  /// Validates a Naira amount entered with thousands separators.
  static String? amount(String? value, {required String field, int? min, int? max}) {
    if ((value?.trim() ?? '').isEmpty) return '$field is required';
    final amount = CurrencyFormatter.parse(value);
    if (amount == null || amount <= 0) return 'Enter a valid amount';
    if (min != null && amount < min) {
      return 'Minimum is ${CurrencyFormatter.format(min)}';
    }
    if (max != null && amount > max) {
      return 'Cannot exceed ${CurrencyFormatter.format(max)}';
    }
    return null;
  }
}
