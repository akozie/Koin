import 'package:flutter_test/flutter_test.dart';
import 'package:koins/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('requires a value', () {
      expect(Validators.email(null), 'Email address is required');
      expect(Validators.email('   '), 'Email address is required');
    });

    test('rejects malformed addresses', () {
      for (final input in ['john', 'john@', '@bank.com', 'john@bank', 'john bank@x.com']) {
        expect(Validators.email(input), 'Enter a valid email address', reason: input);
      }
    });

    test('accepts valid addresses', () {
      for (final input in ['test@bank.com', 'first.last+tag@koins.co.uk', ' a@b.io ']) {
        expect(Validators.email(input), isNull, reason: input);
      }
    });
  });

  group('Validators.password', () {
    test('requires a value', () {
      expect(Validators.password(''), 'Password is required');
    });

    test('enforces a minimum of 8 characters', () {
      expect(Validators.password('Pass123'), 'Password must be at least 8 characters');
      expect(Validators.password('Password'), isNull);
    });
  });

  group('Validators.amount', () {
    test('requires a value', () {
      expect(Validators.amount('', field: 'Target amount'), 'Target amount is required');
    });

    test('rejects zero', () {
      expect(Validators.amount('0', field: 'Amount'), 'Enter a valid amount');
    });

    test('enforces min and max', () {
      expect(Validators.amount('4,999', field: 'Amount', min: 5000), 'Minimum is ₦5,000');
      expect(Validators.amount('20,000', field: 'Amount', max: 10000), 'Cannot exceed ₦10,000');
      expect(Validators.amount('5,000', field: 'Amount', min: 5000, max: 10000), isNull);
    });
  });

  test('Validators.required names the field', () {
    expect(Validators.required(' ', field: 'Savings name'), 'Savings name is required');
    expect(Validators.required('Car', field: 'Savings name'), isNull);
  });
}
