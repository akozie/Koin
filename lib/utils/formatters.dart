import 'package:intl/intl.dart';

import '../core/constants/app_constants.dart';

abstract final class CurrencyFormatter {
  static final _naira = NumberFormat.currency(
    locale: AppConstants.currencyLocale,
    symbol: AppConstants.currencySymbol,
    decimalDigits: 0,
  );

  static final _grouped = NumberFormat.decimalPattern(AppConstants.currencyLocale);

  /// `850000` → `₦850,000`
  static String format(num amount) => _naira.format(amount);

  /// `850000` → `₦850K`, used where space is tight.
  static String compact(num amount) =>
      '${AppConstants.currencySymbol}${NumberFormat.compact(locale: 'en').format(amount)}';

  /// `850000` → `850,000` (no symbol), used in text inputs.
  static String grouped(num amount) => _grouped.format(amount);

  /// Parses `"850,000"` or `"₦850,000"` into `850000`. Returns `null` if empty.
  static int? parse(String? input) {
    final digits = input?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
    return digits.isEmpty ? null : int.tryParse(digits);
  }
}

abstract final class DateFormatter {
  static final _short = DateFormat('d MMM yyyy');

  static String short(DateTime date) => _short.format(date);

  static final _time = DateFormat('h:mm a');
  static final _dayTime = DateFormat('d MMM, h:mm a');

  /// `10:42 AM` for today, `12 Oct, 10:42 AM` otherwise.
  static String timestamp(DateTime date, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final sameDay = date.year == today.year && date.month == today.month && date.day == today.day;
    return (sameDay ? _time : _dayTime).format(date);
  }
}
