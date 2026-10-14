import 'package:flutter_test/flutter_test.dart';
import 'package:koins/utils/savings_calculator.dart';

void main() {
  group('SavingsCalculator.projectedInterest', () {
    test('computes simple interest on monthly deposits', () {
      // 10,000 × (12% / 12) × (12 × 13 / 2) = 10,000 × 0.01 × 78 = 7,800
      expect(
        SavingsCalculator.projectedInterest(
          monthlyContribution: 10000,
          annualRatePercent: 12,
          months: 12,
        ),
        7800,
      );
    });

    test('returns 0 for non-positive inputs', () {
      expect(
        SavingsCalculator.projectedInterest(
          monthlyContribution: 0,
          annualRatePercent: 12,
          months: 12,
        ),
        0,
      );
      expect(
        SavingsCalculator.projectedInterest(
          monthlyContribution: 1000,
          annualRatePercent: 12,
          months: 0,
        ),
        0,
      );
    });
  });

  test('totalContributions multiplies contribution by months', () {
    expect(SavingsCalculator.totalContributions(monthlyContribution: 5000, months: 6), 30000);
  });
}
