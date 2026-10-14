import 'package:flutter_test/flutter_test.dart';
import 'package:koins/utils/currency_input_formatter.dart';
import 'package:koins/utils/formatters.dart';
import 'package:koins/utils/greeting.dart';

void main() {
  group('CurrencyFormatter', () {
    test('formats Naira without decimals', () {
      expect(CurrencyFormatter.format(850000), '₦850,000');
      expect(CurrencyFormatter.format(0), '₦0');
    });

    test('parses grouped and symbol-prefixed input', () {
      expect(CurrencyFormatter.parse('850,000'), 850000);
      expect(CurrencyFormatter.parse('₦ 1,200'), 1200);
      expect(CurrencyFormatter.parse(''), isNull);
      expect(CurrencyFormatter.parse(null), isNull);
    });
  });

  group('CurrencyInputFormatter', () {
    const formatter = CurrencyInputFormatter();

    TextEditingValue type(String text) =>
        formatter.formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: text));

    test('adds thousands separators as the user types', () {
      expect(type('1500000').text, '1,500,000');
    });

    test('strips non-digits', () {
      expect(type('12a3').text, '123');
    });

    test('keeps the cursor at the end', () {
      expect(type('12000').selection.baseOffset, '12,000'.length);
    });

    test('clears when no digits remain', () {
      expect(type('abc').text, isEmpty);
    });
  });

  group('DateFormatter.timestamp', () {
    final now = DateTime(2026, 10, 13, 18);

    test('shows only the time for today', () {
      expect(DateFormatter.timestamp(DateTime(2026, 10, 13, 10, 42), now: now), '10:42 AM');
    });

    test('includes the date for earlier days', () {
      expect(DateFormatter.timestamp(DateTime(2026, 10, 12, 21, 5), now: now), '12 Oct, 9:05 PM');
    });
  });

  group('Greeting', () {
    test('returns the right greeting for the time of day', () {
      expect(Greeting.forTime(DateTime(2026, 1, 1, 8)), 'Good Morning');
      expect(Greeting.forTime(DateTime(2026, 1, 1, 13)), 'Good Afternoon');
      expect(Greeting.forTime(DateTime(2026, 1, 1, 19)), 'Good Evening');
    });
  });
}
